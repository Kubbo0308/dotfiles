#!/usr/bin/env python3
"""
Prompt Review - AI Conversation History Collector

Collects user prompts from various AI coding tools for analysis.
No external dependencies - uses Python standard library only.
No network requests - reads only local files.
"""

import argparse
import getpass
import json
import os
import re
import sqlite3
import stat
import sys
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path


# --- Constants ---

MAX_MESSAGE_LENGTH = 500

SHORT_AFFIRMATIONS = {
    "y", "yes", "ok", "sure", "proceed", "go ahead", "continue",
    "はい", "うん", "進めて", "お願い", "おk", "おけ", "了解",
}

# Cline/Roo Code inject tool results as role='user'; filter these out
TOOL_NOISE_PREFIXES = (
    "<tool_result>", "<environment_details>", "<attempt_completion>",
    "[tool:", "<feedback>", "<command>",
)

SECRET_PATTERNS = [
    (r"sk-[a-zA-Z0-9]{20,}", "OpenAI API Key"),
    (r"sk-ant-[a-zA-Z0-9\-]{20,}", "Anthropic API Key"),
    (r"ghp_[a-zA-Z0-9]{36,}", "GitHub Personal Access Token"),
    (r"gho_[a-zA-Z0-9]{36,}", "GitHub OAuth Token"),
    (r"github_pat_[a-zA-Z0-9_]{22,}", "GitHub Fine-Grained PAT"),
    (r"AIza[a-zA-Z0-9\-_]{35}", "Google API Key"),
    (r"AKIA[A-Z0-9]{16}", "AWS Access Key"),
    (r"xoxb-[0-9]{10,}-[a-zA-Z0-9]{20,}", "Slack Bot Token"),
    (r"xoxp-[0-9]{10,}-[a-zA-Z0-9]{20,}", "Slack User Token"),
    (r"-----BEGIN (?:RSA |EC |DSA )?PRIVATE KEY-----", "Private Key"),
    (r"postgres(?:ql)?://[^\s]+:[^\s]+@[^\s]+", "Database Connection String"),
    (r"mysql://[^\s]+:[^\s]+@[^\s]+", "Database Connection String"),
    (r"mongodb(?:\+srv)?://[^\s]+:[^\s]+@[^\s]+", "Database Connection String"),
    (r"Bearer\s+[a-zA-Z0-9\-._~+/]{20,}=*", "Bearer Token"),
    (r"[a-zA-Z0-9]{32,}\.apps\.googleusercontent\.com", "Google OAuth Client ID"),
]

_HOME_PATH = Path.home()
_HOME = str(_HOME_PATH)
_USERNAME = getpass.getuser()

ALLOWED_OUTPUT_PARENTS = [Path("/tmp"), _HOME_PATH / "reports"]


class Source:
    CLAUDE_CODE = "claude-code"
    COPILOT_CHAT = "copilot-chat"
    CLINE = "cline"
    ROO_CODE = "roo-code"
    WINDSURF = "windsurf"
    CODEX_CLI = "codex-cli"


class ExtensionID:
    CLINE = "saoudrizwan.claude-dev"
    ROO_CODE = "rooveterinaryinc.roo-cline"


# --- Helpers ---

def mask_secret(value: str) -> str:
    """Mask a secret value, showing at most first 4 chars."""
    visible = min(4, len(value) // 4)
    return value[:visible] + "*" * min(8, len(value) - visible)


def scan_secrets(text: str) -> list[dict]:
    """Scan text for potential secrets and return masked findings."""
    findings = []
    for pattern, label in SECRET_PATTERNS:
        for match in re.finditer(pattern, text):
            findings.append({
                "type": label,
                "masked_value": mask_secret(match.group()),
            })
    return findings


def truncate(text: str, max_len: int = MAX_MESSAGE_LENGTH) -> str:
    """Truncate text to max length."""
    if len(text) <= max_len:
        return text
    return text[:max_len] + "..."


def mask_username(path: str) -> str:
    """Replace the current user's home path and username in file paths."""
    path = path.replace(_HOME, "/home/<user>")
    return re.sub(rf"(^|/){re.escape(_USERNAME)}(/|$)", r"\1<user>\2", path)


def is_noise(text: str) -> bool:
    """Check if a message is noise (short affirmation or tool injection)."""
    stripped = text.strip()
    if stripped.lower() in SHORT_AFFIRMATIONS:
        return True
    if any(stripped.startswith(prefix) for prefix in TOOL_NOISE_PREFIXES):
        return True
    return False


def extract_text(content) -> str:
    """Extract plain text from a message content field.

    Handles both raw strings and Claude-style typed content arrays.
    """
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(
            p.get("text", "")
            for p in content
            if isinstance(p, dict) and p.get("type") == "text"
        )
    return ""


def safe_env_path(env_var: str, default: Path) -> Path:
    """Read a path from an environment variable, validating it stays under $HOME."""
    raw = os.environ.get(env_var)
    if raw is None:
        return default
    resolved = Path(raw).resolve()
    if not str(resolved).startswith(str(_HOME_PATH.resolve())):
        return default
    return resolved


def is_safe_path(path: Path) -> bool:
    """Check that a path is not a symlink (prevents redirect attacks)."""
    return not path.is_symlink()


def validate_output_path(raw: str) -> Path:
    """Validate that the output path is within an allowed directory."""
    resolved = Path(raw).resolve()
    if not any(
        str(resolved).startswith(str(p.resolve())) for p in ALLOWED_OUTPUT_PARENTS
    ):
        print(
            f"ERROR: Output path must be within: "
            f"{[str(p) for p in ALLOWED_OUTPUT_PARENTS]}",
            file=sys.stderr,
        )
        sys.exit(1)
    return resolved


def is_before_cutoff(ts, cutoff: datetime) -> bool:
    """Check if a timestamp is before the cutoff (message too old to include).

    Returns False on missing/unparseable timestamps to include the message by default.
    """
    if not ts:
        return False
    try:
        if isinstance(ts, (int, float)):
            msg_time = datetime.fromtimestamp(ts / 1000, tz=timezone.utc)
        else:
            msg_time = datetime.fromisoformat(str(ts).replace("Z", "+00:00"))
        return msg_time < cutoff
    except (ValueError, TypeError, OSError):
        return False  # Unknown format: include the message to avoid data loss


def build_message(source: str, project: str, text: str, ts: str) -> dict:
    """Build a standardized message dict.

    Note: scan_secrets intentionally runs on the full un-truncated text
    to catch secrets beyond the 500-char display limit.
    """
    return {
        "source": source,
        "project": mask_username(project),
        "text": truncate(text),
        "timestamp": str(ts),
        "secrets": scan_secrets(text),
    }


# --- Collectors ---

def collect_claude_code(cutoff: datetime, project_filter: str | None) -> dict:
    """Collect from Claude Code JSONL logs."""
    config_dir = safe_env_path("CLAUDE_CONFIG_DIR", _HOME_PATH / ".claude")
    projects_dir = config_dir / "projects"

    if not projects_dir.exists():
        return {"source": Source.CLAUDE_CODE, "messages": [], "projects": []}

    messages = []
    projects = set()

    for project_dir in projects_dir.iterdir():
        if not project_dir.is_dir():
            continue

        project_name = project_dir.name
        if project_filter and project_filter.lower() not in project_name.lower():
            continue

        for jsonl_file in project_dir.glob("*.jsonl"):
            if not is_safe_path(jsonl_file):
                continue
            try:
                with open(jsonl_file, "r", encoding="utf-8", errors="replace") as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            entry = json.loads(line)
                        except json.JSONDecodeError:
                            continue

                        if entry.get("type") != "user":
                            continue

                        ts = entry.get("timestamp", "")
                        if is_before_cutoff(ts, cutoff):
                            continue

                        # Claude Code format: {type: "user", message: {role: "user", content: "..."}}
                        message = entry.get("message", "")
                        if isinstance(message, dict):
                            text = extract_text(message.get("content", ""))
                        else:
                            text = extract_text(message)

                        if not text or is_noise(text):
                            continue

                        projects.add(project_name)
                        messages.append(
                            build_message(Source.CLAUDE_CODE, project_name, text, ts)
                        )
            except (OSError, PermissionError):
                continue

    return {
        "source": Source.CLAUDE_CODE,
        "messages": messages,
        "projects": [mask_username(p) for p in sorted(projects)],
    }


def collect_copilot_chat(cutoff: datetime, project_filter: str | None) -> dict:
    """Collect from GitHub Copilot Chat SQLite database."""
    possible_paths = [
        _HOME_PATH / "Library/Application Support/Code/User/globalStorage/github.copilot-chat/state.vscdb",
        _HOME_PATH / ".config/Code/User/globalStorage/github.copilot-chat/state.vscdb",
    ]

    db_path = None
    for p in possible_paths:
        if p.exists() and is_safe_path(p):
            db_path = p
            break

    if not db_path:
        return {"source": Source.COPILOT_CHAT, "messages": [], "projects": []}

    messages = []
    projects = set()

    try:
        conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True, timeout=5)
        cursor = conn.cursor()
        cursor.execute(
            "SELECT value FROM ItemTable WHERE key = 'chat.panel.conversations'"
        )
        row = cursor.fetchone()
        conn.close()

        if not row:
            return {"source": Source.COPILOT_CHAT, "messages": [], "projects": []}

        conversations = json.loads(row[0])
        if not isinstance(conversations, list):
            conversations = [conversations]

        for conv in conversations:
            for req in conv.get("requests", []):
                msg = req.get("message", "")
                if not msg or is_noise(msg):
                    continue

                ts = req.get("timestamp", "")
                if is_before_cutoff(ts, cutoff):
                    continue

                project = conv.get("workspaceFolder", "unknown")
                if project_filter and project_filter.lower() not in str(project).lower():
                    continue

                projects.add(str(project))
                messages.append(
                    build_message(Source.COPILOT_CHAT, str(project), msg, ts)
                )
    except (sqlite3.Error, json.JSONDecodeError, OSError):
        pass

    return {
        "source": Source.COPILOT_CHAT,
        "messages": messages,
        "projects": [mask_username(str(p)) for p in sorted(projects)],
    }


def collect_cline_or_roo(
    name: str, extension_id: str, cutoff: datetime, project_filter: str | None
) -> dict:
    """Collect from Cline or Roo Code JSON logs."""
    possible_bases = [
        _HOME_PATH / "Library/Application Support/Code/User/globalStorage" / extension_id,
        _HOME_PATH / ".config/Code/User/globalStorage" / extension_id,
    ]

    base_path = None
    for p in possible_bases:
        if p.exists():
            base_path = p
            break

    if not base_path:
        return {"source": name, "messages": [], "projects": []}

    messages = []
    projects = set()
    tasks_dir = base_path / "tasks"

    if not tasks_dir.exists():
        return {"source": name, "messages": [], "projects": []}

    for task_dir in tasks_dir.iterdir():
        if not task_dir.is_dir():
            continue

        project_name = task_dir.name
        if project_filter and project_filter.lower() not in project_name.lower():
            continue

        history_file = task_dir / "api_conversation_history.json"
        try:
            if not is_safe_path(history_file):
                continue
            with open(history_file, "r", encoding="utf-8", errors="replace") as f:
                conversation = json.load(f)

            if not isinstance(conversation, list):
                continue

            for entry in conversation:
                if entry.get("role") != "user":
                    continue

                text = extract_text(entry.get("content", ""))
                if not text or is_noise(text):
                    continue

                ts = entry.get("ts", entry.get("timestamp", ""))
                if is_before_cutoff(ts, cutoff):
                    continue

                projects.add(project_name)
                messages.append(
                    build_message(name, project_name, text, ts)
                )
        except (json.JSONDecodeError, OSError, PermissionError):
            continue

    return {
        "source": name,
        "messages": messages,
        "projects": sorted(projects),
    }


def collect_windsurf(cutoff: datetime, project_filter: str | None) -> dict:
    """Collect from Windsurf (Cascade) memory files.

    Note: Windsurf stores summaries, not raw conversation history.
    st_mtime is used as a proxy for conversation time.
    """
    memories_dir = _HOME_PATH / ".codeium/windsurf/memories"

    if not memories_dir.exists():
        return {"source": Source.WINDSURF, "messages": [], "projects": []}

    messages = []
    projects = set()

    for mem_file in memories_dir.glob("*.md"):
        if not is_safe_path(mem_file):
            continue
        try:
            file_time = datetime.fromtimestamp(mem_file.stat().st_mtime, tz=timezone.utc)
            if file_time < cutoff:
                continue

            text = mem_file.read_text(encoding="utf-8", errors="replace")
            if not text.strip() or is_noise(text.strip()):
                continue

            projects.add(mem_file.stem)
            messages.append(
                build_message(Source.WINDSURF, mem_file.stem, text, file_time.isoformat())
            )
        except (OSError, PermissionError):
            continue

    return {
        "source": Source.WINDSURF,
        "messages": messages,
        "projects": sorted(projects),
    }


def collect_codex_cli(cutoff: datetime, project_filter: str | None) -> dict:
    """Collect from OpenAI Codex CLI JSONL sessions."""
    codex_home = safe_env_path("CODEX_HOME", _HOME_PATH / ".codex")
    sessions_dir = codex_home / "sessions"

    if not sessions_dir.exists():
        return {"source": Source.CODEX_CLI, "messages": [], "projects": []}

    messages = []
    projects = set()

    for jsonl_file in sessions_dir.glob("**/*.jsonl"):
        if not is_safe_path(jsonl_file):
            continue
        try:
            with open(jsonl_file, "r", encoding="utf-8", errors="replace") as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        entry = json.loads(line)
                    except json.JSONDecodeError:
                        continue

                    if entry.get("role") != "user":
                        continue

                    text = extract_text(entry.get("content", ""))
                    if not text or is_noise(text):
                        continue

                    ts = entry.get("timestamp", "")
                    if is_before_cutoff(ts, cutoff):
                        continue

                    project = jsonl_file.parent.name
                    if project_filter and project_filter.lower() not in project.lower():
                        continue

                    projects.add(project)
                    messages.append(
                        build_message(Source.CODEX_CLI, project, text, ts)
                    )
        except (OSError, PermissionError):
            continue

    return {
        "source": Source.CODEX_CLI,
        "messages": messages,
        "projects": sorted(projects),
    }


# --- Main ---

def main():
    parser = argparse.ArgumentParser(
        description="Collect AI conversation history for prompt review"
    )
    parser.add_argument(
        "--days", type=int, default=7,
        help="Number of days to look back (default: 7)",
    )
    parser.add_argument(
        "--project", type=str, default=None,
        help="Filter by project name (substring match)",
    )
    parser.add_argument(
        "--output", type=str, default=None,
        help="Output file path (must be under /tmp or ~/reports)",
    )
    args = parser.parse_args()

    # Determine output path with security validation
    if args.output:
        output_path = validate_output_path(args.output)
    else:
        tmpdir = Path(tempfile.mkdtemp(prefix="prompt-review-"))
        os.chmod(tmpdir, stat.S_IRWXU)  # 0700 - owner only
        output_path = tmpdir / "data.json"

    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(days=args.days)
    print(f"Collecting prompts from the last {args.days} days...", flush=True)

    sources = [
        collect_claude_code(cutoff, args.project),
        collect_copilot_chat(cutoff, args.project),
        collect_cline_or_roo(Source.CLINE, ExtensionID.CLINE, cutoff, args.project),
        collect_cline_or_roo(Source.ROO_CODE, ExtensionID.ROO_CODE, cutoff, args.project),
        collect_windsurf(cutoff, args.project),
        collect_codex_cli(cutoff, args.project),
    ]

    total_messages = sum(len(s["messages"]) for s in sources)
    all_secrets = [
        secret
        for s in sources
        for m in s["messages"]
        for secret in m.get("secrets", [])
    ]
    active_sources = [s for s in sources if s["messages"]]

    secrets_truncated = len(all_secrets) > 50
    result = {
        "summary": {
            "collection_date": now.isoformat(),
            "days_back": args.days,
            "cutoff_date": cutoff.isoformat(),
            "project_filter": args.project,
            "total_messages": total_messages,
            "active_sources": len(active_sources),
            "secrets_detected": len(all_secrets),
            "secrets_truncated": secrets_truncated,
        },
        "sources": sources,
        "secret_warnings": all_secrets[:50],
    }

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    os.chmod(output_path, stat.S_IRUSR | stat.S_IWUSR)  # 0600 - owner only

    print(f"Done. {total_messages} messages from {len(active_sources)} sources.", flush=True)
    print(f"Output: {output_path}", flush=True)

    if all_secrets:
        msg = f"WARNING: {len(all_secrets)} potential secrets detected!"
        if secrets_truncated:
            msg += f" (showing 50 of {len(all_secrets)})"
        print(msg, flush=True)


if __name__ == "__main__":
    main()
