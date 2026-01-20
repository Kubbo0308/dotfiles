---
name: drawio
description: "Create and edit draw.io diagrams using XML. Use when generating flowcharts, architecture diagrams, sequence diagrams, or any visual diagrams in draw.io format."
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash(drawio:*)
  - Bash(ls:*)
---

# Draw.io Diagram Skill

Generate high-quality draw.io diagrams using XML format with proper Japanese font support and best practices.

## Quick Start

1. Understand the diagram requirements (type, elements, relationships)
2. Apply the XML structure template
3. Ensure all text elements have explicit fontFamily
4. Place arrows before shapes in XML (for z-order)
5. Convert to PNG and verify output

## Key Rules

| Rule | Description |
|------|-------------|
| **fontFamily必須** | 全テキスト要素に`fontFamily=Noto Sans JP;`を明示 |
| **矢印の描画順** | XMLで矢印を先に記述すると背面に描画される |
| **フォントサイズ** | 標準の1.5倍（18px）を推奨 |
| **テキスト幅** | 日本語は1文字あたり30-40px確保 |
| **背景透明** | `background="none"`を設定 |
| **page設定** | `page="0"`で余白を最小化 |

## XML Structure Template

```xml
<mxfile host="app.diagrams.net" modified="2025-01-01T00:00:00.000Z" agent="Claude" version="22.1.0">
  <diagram name="Page-1" id="unique-id">
    <mxGraphModel dx="1000" dy="600" grid="1" gridSize="10" guides="1"
                  tooltips="1" connect="1" arrows="1" fold="1" page="0"
                  pageScale="1" background="none" math="0" shadow="0"
                  defaultFontFamily="Noto Sans JP">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- 矢印を先に配置（背面描画のため） -->
        <!-- 図形を後に配置 -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

## Common Element Styles

### テキストボックス
```xml
<mxCell value="テキスト" style="text;html=1;fontSize=18;fontFamily=Noto Sans JP;align=center;verticalAlign=middle;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="200" height="40" as="geometry"/>
</mxCell>
```

### 矩形
```xml
<mxCell value="ボックス" style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Noto Sans JP;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

### 矢印
```xml
<mxCell style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;fontSize=14;fontFamily=Noto Sans JP;" edge="1" parent="1" source="source-id" target="target-id">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

## PNG Conversion

```bash
drawio -x -f png -s 2 -t -o output.png input.drawio
```

| Option | Description |
|--------|-------------|
| `-x` | Export mode |
| `-f png` | PNG format |
| `-s 2` | Scale 2x (高解像度) |
| `-t` | Transparent background |
| `-o` | Output file |

## Output Checklist

- [ ] 全テキストに`fontFamily=Noto Sans JP;`が設定されている
- [ ] フォントサイズが十分（18px推奨）
- [ ] 矢印がXMLで先に記述されている（背面配置）
- [ ] 矢印ラベルが矢印から20px以上離れている
- [ ] テキストが改行されていない（幅を十分確保）
- [ ] PNG出力で視覚確認済み

## References

- XML structure details: [xml-structure.md](references/xml-structure.md)
- Font configuration: [font-settings.md](references/font-settings.md)
- Arrow best practices: [arrow-placement.md](references/arrow-placement.md)

