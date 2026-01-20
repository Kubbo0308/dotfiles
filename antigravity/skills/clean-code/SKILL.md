---
name: clean-code
description: MUST reference when writing code. Clean code principles for maintainable software - cohesion, coupling, naming, and architecture.
---

# Clean Code Principles

Apply these principles to create maintainable, readable, and high-quality software.

**Core Message**: Quality and speed are NOT a trade-off. High internal quality leads to higher development velocity.

## Quick Start

1. Aim for high cohesion (functional cohesion is best)
2. Minimize coupling (data coupling is best)
3. Use intention-revealing names
4. Follow single responsibility principle
5. Manage technical debt consciously

## Core Metrics

| Metric | Goal | Best Level |
|--------|------|------------|
| Cohesion | HIGH | Functional cohesion |
| Coupling | LOW | Data/Message coupling |
| Technical Debt | MINIMIZE | Avoid deliberate debt |

## How to Use

- `/clean-code` - Apply constraints to code in this conversation
- `/clean-code <file>` - Review file for violations

## References

- Cohesion levels: [cohesion.md](references/cohesion.md)
- Coupling levels: [coupling.md](references/coupling.md)
- Naming conventions: [naming-conventions.md](references/naming-conventions.md)
- Clean Architecture: [clean-architecture.md](references/clean-architecture.md)
- Technical debt: [technical-debt.md](references/technical-debt.md)

## Source

Based on [What is Good Code - CyberAgent Engineer Training](https://speakerdeck.com/moriatsushi/liang-ikodotohahe-ka-enziniaxin-zu-yan-xiu-suraidogong-kai) by Atsushi Mori.
