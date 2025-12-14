# Draw.io XML Structure Reference

Draw.io files are XML-based with a specific hierarchy. Understanding this structure is essential for programmatic diagram generation.

## File Hierarchy

```
mxfile
└── diagram
    └── mxGraphModel
        └── root
            ├── mxCell (id="0") - Root cell
            ├── mxCell (id="1" parent="0") - Default parent
            ├── mxCell (edges/arrows) - Background elements
            └── mxCell (shapes/text) - Foreground elements
```

## mxfile Element

The root element containing metadata:

```xml
<mxfile host="app.diagrams.net"
        modified="2025-01-01T00:00:00.000Z"
        agent="Claude Code"
        version="22.1.0"
        type="device">
  <!-- diagram elements -->
</mxfile>
```

## diagram Element

Container for the graph model:

```xml
<diagram name="Page-1" id="unique-diagram-id">
  <!-- mxGraphModel -->
</diagram>
```

- `name`: Display name in draw.io tabs
- `id`: Unique identifier for the diagram

## mxGraphModel Attributes

The core configuration element:

```xml
<mxGraphModel dx="1000"
              dy="600"
              grid="1"
              gridSize="10"
              guides="1"
              tooltips="1"
              connect="1"
              arrows="1"
              fold="1"
              page="0"
              pageScale="1"
              background="none"
              math="0"
              shadow="0"
              defaultFontFamily="Noto Sans JP">
```

| Attribute | Description | Recommended Value |
|-----------|-------------|-------------------|
| `dx`, `dy` | Canvas dimensions | Adjust to content |
| `grid` | Show grid | `1` (enabled) |
| `gridSize` | Grid cell size | `10` |
| `page` | Page mode | `0` (no page bounds) |
| `background` | Background color | `none` (transparent) |
| `defaultFontFamily` | Default font | `Noto Sans JP` |

## mxCell Types

### Root Cells (Required)

Every diagram must start with these two cells:

```xml
<mxCell id="0"/>
<mxCell id="1" parent="0"/>
```

### Shape Cell

```xml
<mxCell id="shape-1"
        value="Label Text"
        style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Noto Sans JP;"
        vertex="1"
        parent="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

Key attributes:
- `id`: Unique identifier
- `value`: Display text (HTML allowed)
- `style`: Visual properties
- `vertex="1"`: Indicates this is a shape
- `parent="1"`: Reference to parent cell

### Edge Cell (Arrow/Connector)

```xml
<mxCell id="edge-1"
        style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;"
        edge="1"
        parent="1"
        source="shape-1"
        target="shape-2">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

Key attributes:
- `edge="1"`: Indicates this is a connector
- `source`: ID of source shape
- `target`: ID of target shape

### Edge with Label

```xml
<mxCell id="edge-with-label"
        value="Label"
        style="edgeStyle=orthogonalEdgeStyle;html=1;fontSize=14;fontFamily=Noto Sans JP;"
        edge="1"
        parent="1"
        source="shape-1"
        target="shape-2">
  <mxGeometry relative="1" as="geometry">
    <mxPoint as="offset" x="0" y="-20"/>
  </mxGeometry>
</mxCell>
```

Use `<mxPoint as="offset">` to position the label away from the line.

## ID Naming Conventions

Use descriptive IDs for maintainability:

```xml
<!-- Good: Descriptive IDs -->
<mxCell id="user-input-box" .../>
<mxCell id="processing-step" .../>
<mxCell id="arrow-input-to-process" .../>

<!-- Bad: Generic IDs -->
<mxCell id="2" .../>
<mxCell id="3" .../>
```

## Geometry Element

Defines position and size:

```xml
<mxGeometry x="100" y="200" width="150" height="80" as="geometry"/>
```

For edges with custom points:

```xml
<mxGeometry relative="1" as="geometry">
  <Array as="points">
    <mxPoint x="200" y="300"/>
    <mxPoint x="200" y="400"/>
  </Array>
</mxGeometry>
```

## Z-Order (Drawing Order)

**Elements are drawn in XML document order:**

- Earlier elements → drawn first → appear behind
- Later elements → drawn last → appear in front

Recommended order:
1. Root cells (id="0", id="1")
2. Edges/Arrows (background)
3. Shapes/Text (foreground)

```xml
<root>
  <mxCell id="0"/>
  <mxCell id="1" parent="0"/>
  <!-- Edges first (background) -->
  <mxCell id="arrow-1" edge="1" .../>
  <mxCell id="arrow-2" edge="1" .../>
  <!-- Shapes last (foreground) -->
  <mxCell id="box-1" vertex="1" .../>
  <mxCell id="box-2" vertex="1" .../>
</root>
```

