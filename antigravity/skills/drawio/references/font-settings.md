# Draw.io Font Settings

Proper font configuration is critical for Japanese text rendering in draw.io diagrams.

## The Font Family Trap

**Critical Issue:** Setting `defaultFontFamily` at the mxGraphModel level is NOT sufficient.

```xml
<!-- This alone is NOT enough! -->
<mxGraphModel defaultFontFamily="Noto Sans JP" ...>
```

**Solution:** Each text element must explicitly include `fontFamily` in its style attribute.

## Correct Font Configuration

### mxGraphModel Level (Base Setting)

```xml
<mxGraphModel dx="1000" dy="600" grid="1" gridSize="10"
              guides="1" tooltips="1" connect="1" arrows="1"
              fold="1" page="0" pageScale="1" background="none"
              math="0" shadow="0"
              defaultFontFamily="Noto Sans JP">
```

### Per-Element Style (Required)

```xml
<!-- Text element with explicit fontFamily -->
<mxCell value="日本語テキスト"
        style="text;html=1;fontSize=18;fontFamily=Noto Sans JP;align=center;"
        vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="200" height="40" as="geometry"/>
</mxCell>

<!-- Shape with text - also needs fontFamily -->
<mxCell value="ボタン"
        style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Noto Sans JP;fillColor=#dae8fc;"
        vertex="1" parent="1">
  <mxGeometry x="100" y="200" width="120" height="60" as="geometry"/>
</mxCell>
```

## Recommended Fonts

### Japanese Text

| Font | Use Case |
|------|----------|
| `Noto Sans JP` | General purpose (recommended) |
| `Noto Serif JP` | Formal documents |
| `M PLUS 1p` | Technical diagrams |

### English/Code Text

| Font | Use Case |
|------|----------|
| `Noto Sans` | General purpose |
| `Roboto Mono` | Code snippets |
| `Courier New` | Monospace text |

## Font Size Guidelines

Standard draw.io font size is often too small. Recommended sizes:

| Element Type | Recommended Size |
|--------------|------------------|
| Title | 24px |
| Heading | 20px |
| Body text | 18px |
| Labels | 16px |
| Annotations | 14px |

### Style Example

```xml
style="text;html=1;fontSize=18;fontFamily=Noto Sans JP;"
```

## Text Width Calculation

Japanese characters require more width than Latin characters:

| Character Type | Width per Character |
|----------------|---------------------|
| Japanese (日本語) | 30-40px at 18px font |
| English | 10-15px at 18px font |

### Width Formula

```
Width = (Japanese chars × 35) + (English chars × 12) + padding
```

### Example

For text "ユーザー入力" (6 characters):
- Width = 6 × 35 = 210px
- With padding: 230px minimum

```xml
<mxGeometry x="100" y="100" width="230" height="40" as="geometry"/>
```

## Preventing Text Wrapping

To prevent unwanted line breaks:

1. **Calculate proper width** based on text content
2. **Use `whiteSpace=wrap`** only when wrapping is desired
3. **Set adequate geometry width**

```xml
<!-- Prevent wrapping with sufficient width -->
<mxCell value="データ処理システム"
        style="text;html=1;fontSize=18;fontFamily=Noto Sans JP;whiteSpace=nowrap;"
        vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="280" height="40" as="geometry"/>
</mxCell>
```

## Font Checklist

Before exporting your diagram:

- [ ] `defaultFontFamily` is set in mxGraphModel
- [ ] Every `<mxCell>` with text has `fontFamily` in style
- [ ] Font sizes are readable (18px minimum for body text)
- [ ] Text widths are sufficient to prevent wrapping
- [ ] Japanese fonts are web-safe (Noto Sans JP recommended)

## Common Issues

### Issue: Garbled Japanese Text

**Cause:** Missing fontFamily in element style
**Fix:** Add `fontFamily=Noto Sans JP;` to every text element's style

### Issue: Text Cut Off

**Cause:** Geometry width too small
**Fix:** Calculate width based on character count (30-40px per Japanese char)

### Issue: Inconsistent Font Rendering

**Cause:** Mixed font declarations
**Fix:** Use the same fontFamily consistently across all elements

