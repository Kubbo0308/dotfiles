# Draw.io Arrow Placement

Proper arrow configuration is essential for clear, readable diagrams.

## Z-Order: Arrows Behind Shapes

**Key Principle:** XML document order determines drawing order.

- Elements written first → drawn first → appear behind
- Elements written last → drawn last → appear in front

### Recommended XML Structure

```xml
<root>
  <mxCell id="0"/>
  <mxCell id="1" parent="0"/>

  <!-- 1. ARROWS FIRST (background layer) -->
  <mxCell id="arrow-1" edge="1" parent="1" source="box-a" target="box-b"
          style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;">
    <mxGeometry relative="1" as="geometry"/>
  </mxCell>
  <mxCell id="arrow-2" edge="1" parent="1" source="box-b" target="box-c"
          style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;">
    <mxGeometry relative="1" as="geometry"/>
  </mxCell>

  <!-- 2. SHAPES LAST (foreground layer) -->
  <mxCell id="box-a" vertex="1" parent="1" value="Step A"
          style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Noto Sans JP;">
    <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
  </mxCell>
  <mxCell id="box-b" vertex="1" parent="1" value="Step B"
          style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Noto Sans JP;">
    <mxGeometry x="300" y="100" width="120" height="60" as="geometry"/>
  </mxCell>
</root>
```

## Edge Styles

### Orthogonal (Right Angle)

Best for structured diagrams like flowcharts:

```xml
style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"
```

### Entity Relation

For ER diagrams with multiple connections:

```xml
style="edgeStyle=entityRelationEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"
```

### Straight Line

For simple connections:

```xml
style="edgeStyle=none;rounded=0;html=1;"
```

### Curved

For organic-looking diagrams:

```xml
style="edgeStyle=orthogonalEdgeStyle;rounded=1;curved=1;html=1;"
```

## Arrow Endpoints

### Arrow Types

| Style Property | Arrow Type |
|----------------|------------|
| `endArrow=classic` | Standard arrow |
| `endArrow=block` | Filled triangle |
| `endArrow=open` | Open arrow |
| `endArrow=oval` | Circle |
| `endArrow=diamond` | Diamond |
| `endArrow=none` | No arrow |

### Start Arrow

```xml
style="startArrow=classic;endArrow=classic;html=1;"
```

## Arrow Labels

### Basic Label

```xml
<mxCell id="labeled-arrow"
        value="ラベル"
        style="edgeStyle=orthogonalEdgeStyle;html=1;fontSize=14;fontFamily=Noto Sans JP;"
        edge="1" parent="1" source="box-1" target="box-2">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

### Label Positioning

**Critical:** Labels should be at least 20px away from the arrow line.

```xml
<mxCell id="arrow-with-offset-label"
        value="処理中"
        style="edgeStyle=orthogonalEdgeStyle;html=1;fontSize=14;fontFamily=Noto Sans JP;"
        edge="1" parent="1" source="box-1" target="box-2">
  <mxGeometry relative="1" as="geometry">
    <!-- Offset label 25px above the line -->
    <mxPoint as="offset" x="0" y="-25"/>
  </mxGeometry>
</mxCell>
```

### Label Position Along Edge

Use `relative` positioning (0 = source, 1 = target, 0.5 = middle):

```xml
<mxGeometry x="0.3" relative="1" as="geometry">
  <mxPoint as="offset" x="0" y="-20"/>
</mxGeometry>
```

## Connection Points

### Auto-Connection (Recommended)

Let draw.io determine the best connection point:

```xml
<mxCell edge="1" source="box-1" target="box-2"
        style="edgeStyle=orthogonalEdgeStyle;html=1;">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

### Explicit Connection Points

For precise control, use exit/entry coordinates:

```xml
style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;"
```

| Property | Value Range | Description |
|----------|-------------|-------------|
| `exitX` | 0-1 | Horizontal position on source (0=left, 1=right) |
| `exitY` | 0-1 | Vertical position on source (0=top, 1=bottom) |
| `entryX` | 0-1 | Horizontal position on target |
| `entryY` | 0-1 | Vertical position on target |

### Fixed Coordinates (Most Reliable)

When connecting to text elements, use explicit geometry:

```xml
<mxCell edge="1" parent="1"
        style="edgeStyle=orthogonalEdgeStyle;html=1;">
  <mxGeometry relative="1" as="geometry">
    <mxPoint x="220" y="130" as="sourcePoint"/>
    <mxPoint x="300" y="130" as="targetPoint"/>
  </mxGeometry>
</mxCell>
```

## Waypoints

For complex routing:

```xml
<mxGeometry relative="1" as="geometry">
  <Array as="points">
    <mxPoint x="200" y="150"/>
    <mxPoint x="200" y="250"/>
    <mxPoint x="350" y="250"/>
  </Array>
</mxGeometry>
```

## Common Arrow Patterns

### Bidirectional Arrow

```xml
style="edgeStyle=orthogonalEdgeStyle;startArrow=classic;endArrow=classic;html=1;"
```

### Dashed Arrow (Optional Flow)

```xml
style="edgeStyle=orthogonalEdgeStyle;dashed=1;html=1;"
```

### Thick Arrow (Main Flow)

```xml
style="edgeStyle=orthogonalEdgeStyle;strokeWidth=2;html=1;"
```

### Colored Arrow

```xml
style="edgeStyle=orthogonalEdgeStyle;strokeColor=#FF0000;html=1;"
```

## Arrow Checklist

- [ ] Arrows are placed before shapes in XML (for z-order)
- [ ] Labels have offset to avoid overlapping the line
- [ ] fontFamily is set for arrow labels
- [ ] Font size is readable (14px minimum for labels)
- [ ] Arrow style matches diagram type (orthogonal for flowcharts)

