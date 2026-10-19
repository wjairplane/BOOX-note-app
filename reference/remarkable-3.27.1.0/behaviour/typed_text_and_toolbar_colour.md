# Typed text (notebook pages) and pen-toolbar colour indicator: firmware 3.27.1.0

Source: `xochitl` (ELF32 ARM, non-PIE, vaddrs below), QML in `ui/qml_all/*.qml` (hash-named), `ui/tokens/*.qml`, rmscene reads of the shipped `library/**.rm`.
Method: Ghidra 11.3.2 headless decompile (own project copy) + capstone disassembly (`tools/firmware/pens_lib.py`), constants read as raw doubles/UTF-16 from the image.
Tags: **[V]** read directly from code/data and unambiguous, **[I]** inferred from code structure, **[U]** not recovered.
No app code was touched, nothing committed.

---------------------------------------------------------------------------

## 1. TextWidthModel (the column-width grid in the Typing foldout)

Class `xofm::libs::toolbar::TextWidthModel`, QAbstractListModel; vtable `0xeaff80`; `rowCount` = `0x284b90` (always 3), `data` = `0x288490`, `roleNames` = `0x28ad00`, ctor with the table = `0x289dfc` (the push at `0x289dfc`; stores at `0x289e4c..0x289ef0`) [V].

### 1.1 Entries (fixed `std::array<Entry,3>`, entry = 24 bytes: `int layout @+0, double textWidth @+8, QUrl iconUrl @+16`) [V]

| row | layout enum | textWidth (page px, double) | iconUrl | name (nameForWidth) |
|---|---|---|---|---|
| 0 | **0** | **740.0** (`0x4087200000000000`) | `qrc:/ark/icons/column_narrow` | "Narrow column" |
| 1 | **1** | **936.0** (`0x408d400000000000`) | `qrc:/ark/icons/column_medium` | "Medium column" |
| 2 | **2** | **1152.0** (`0x4092000000000000`) | `qrc:/ark/icons/column_wide` | "Wide column" |

Roles: `0x101 layout`, `0x102 textWidth`, `0x103 iconUrl` (role names at `0x28ad00`: "layout", "textWidth", "iconUrl") [V].
Icons exist as `reference/.../icons/column_{narrow,medium,wide}.svg`.

Invokables (static_metacall `0x28b8c8`) [V]:
* `entriesCount()` returns **3**.
* `nameForWidth(int layout)`: 0 "Narrow column", 1 "Medium column", 2 "Wide column", **4 "Auto column"**, anything else (incl. 3) empty string. (It is passed a *layout*, despite the name.)
* `isAutoLayout(int layout)` = `layout == 4`.

### 1.2 The layout enum `SceneTextItem::PreferredLayout` [V unless noted]
`0 Narrow (740) | 1 Medium (936) | 2 Wide (1152) | 3 = "custom width" (item uses its own stored width, 0x238 field) | 4 Auto (reflow; only reachable with Experimental autoReflowTextColumns)`.
There is **no row for Auto** in the model; the "Auto column" string exists only for the foldout section header while auto-reflow is on.

### 1.3 Widths on the page
Page is 1404 px wide on RM2: narrow = 52.7 %, medium = 66.7 %, wide = 82.1 %.
Box is centred on the page's x = 0 (scene x), so scene left edge / page-px left edge (page left = 0, centre = 702):

| layout | width | scene x (pos_x) | left edge in page px | right edge |
|---|---|---|---|---|
| Narrow | 740 | -370 | 332 | 1072 |
| Medium | 936 | -468 | 234 | 1170 |
| Wide | 1152 | -576 | 126 | 1278 |

### 1.4 Default layout of a new/empty page
* The scene's root-text node constructor stores `layout = 1` (`mov r0,#1; str r0,[r4,#0x240]` at `0xa1d2e4`) and three property stores initialise a `double textWidth = 936.0` (`0x394248`, `0x7cf954`, `0x66c110`) [V].
* `TextColumn::resolvedWidth` falls back to 936 for layouts 1/3/4 and unknown (see 2.1) [V].
* Every `RootTextBlock` in the shipped library `.rm` files has `pos_x=-468.0, pos_y=234.0, width=936.0` (15 files, all identical) [V].
=> **Default = Medium, 936 px, x = -468, y = 234.**
* A new root document is created in QML (`00da96df.qml:1072-1084 enterTextMode`) with `sceneController.createRootDocument(ParagraphStyle.Type.Title)` (first paragraph = Title style) and no explicit width.

### 1.5 What "selected" means (QML `00ea90a7.qml`)
Default build (Experimental `autoReflowTextColumns` is off, so `autoReflowEnabled` false):
* The "Automatic reflow" FoldoutItem + divider (`00ea90a7.qml:61-86`) are `visible: root.autoReflowEnabled` -> hidden.
* Grid: `columns: textWidthModel.entriesCount` (3 columns), `Repeater{model: textWidthModel}`, each `ArkControls.FoldoutItem` with `iconSource: iconUrl` (`:94-135`).
* `selected` (`:104-111`): when auto-reflow is not enabled it is simply `root.textWidth === textWidth`, where `root.textWidth = toolbar.textWidth = textColumn.resolvedWidth(sceneController.rootDocumentTextWidth, sceneController.rootDocumentPreferredTextLayout)` (`00da96df.qml:1769`). So a cell is selected iff the *effective* width equals that row's exact double. A document with any other width (e.g. 1000) selects no cell.
* Extra underline (`:127-133`): `Rectangle{height 4, black, anchored bottom}` visible when `active` = `(autoReflowActive && root.textWidth === textWidth) || selected`.
* Section header text (`:87-91`): `qsTranslate("xofm::libs::toolbar::TextWidthModel", nameForWidth(currentlyActive ? currentlyActive.layout : columnTextWidth))`, i.e. the name of the selected column ("Medium column" by default).
* Tap (`:119`): `onPressed: root.textColumnWidthSelected(layout)` -> `00da96df.qml:1860-1865`: `if (sceneController.hasRootDocument) { sceneView.recenter(); sceneController.rootDocumentPreferredTextLayout = columnWidth; }`. With **no root document yet the tap does nothing** [V] (the `textWidthSelected(real)` path that would `createRootDocument(Title, width)` at `00da96df.qml:1852-1858` is wired but no item in `00ea90a7.qml` emits it). The `visible: !isAutoLayout(layout)` / `enabled: ... || !hasPageAnnotations` lines only matter for auto mode.
* Experimental auto mode (not default): toggle `Automatic reflow` = `isAutoLayout(columnTextWidth)`, disabled when the page has annotations (`toolbar.hasPageAnnotations`); `enableAutoReflow` -> `sceneController.enableAutoReflow()`; `disableAutoReflow(layout)` restores `currentlyActive.layout` (the last cell that matched).

Selected-cell look: toolbar token `foldout.grid.item`: cell height 112, icon 48, idle black-on-white, selected = black fill with white icon (`ui/tokens/toolbar.qml`).

---------------------------------------------------------------------------

## 2. TextColumn.resolvedWidth, setting the layout, and how the box is placed

### 2.1 `TextColumn::resolvedWidth(double textWidth, int layout)` [V] (fn `0x44a520`, QML invokable, metaobject `0x1043cac`, static_metacall `0x407750`)
```
if (textWidth > 0) return textWidth;          // stored width always wins
switch (layout) {
  case 0: return 740.0;
  case 2: return 1152.0;
  default /*1,3,4, unknown (logs "unknown preferred layout" to rm.ui.sceneview)*/: return 936.0;
}
```
(QML class `TextColumn` has property `preferredLayout` of type `SceneTextItem::PreferredLayout`, second overload `resolvedWidth()` uses it; "Should be injected on the view", not creatable.)

### 2.2 Setting the preferred layout `rootDocumentPreferredTextLayout = L` [V] (setter in SceneController static_metacall, case at `0x41cbe0..0x41ccf0`, command class `SceneSetRootDocumentTextPreferredLayoutAction`)
It creates an undoable action that sets BOTH layout and width:
* L=0 -> width **740.0**; L=2 -> **1152.0**; L=1 (and 3) -> **936.0**.
* L=4 (Auto): width taken from the *view's* preferred layout (`SceneController+0x2c8`, `viewPreferredTextLayout`): 0 -> 740, 2 -> 1152, 1 -> 936, 3/4 -> 0.0 (0 = "natural/auto width", see 2.4).
* The action's apply function (`0x414fcc`, vtable slot 3 of the action) swaps new/old values for undo; if no layout is stored it *derives* the layout from the width with `qFuzzyCompare` (`|a-b|*1e12 <= min(|a|,|b|)`): 740 -> 0, 936 -> 1, 1152 -> 2, anything else -> 4 (Auto). [V]
So loading a document with width 740/936/1152 shows the matching column; any other stored width is classed "Auto" (4) for the layout property.

### 2.3 Box placement [V]
* `SceneTextItem::setWidth(w)` (fn `0xa18bb8`): `setPos(-w/2, 234.0)` then `QTextDocument::setTextWidth(w)` (via `0xad8428`), then rescales inline-image blocks (char-format property `0x5010` = w).
  **x = -w/2 (box horizontally centred on scene x=0), y = 234.0 (constant top of the text box).** The `-w/2, 234` pair is also what the CRDT merge applies ("Updating text width from %f -> %f during merge", `0xad8850`: `width = float @+0x1c8`, then `setWidth`, `setPos(-0.5*w, 234.0)`). So on load/merge pos_x/pos_y in the file are effectively recomputed from `width`.
* Position helper for a text item without a parent document (`0xa1db54`, `0xa1dce0`, `0xa1e160`): layout 0 -> x -370, w 740; 1 -> -468, 936; 2 -> -576, 1152; 3 -> x = -w_custom/2; default/4 -> x -0.0, w 0.
* Effective doc width (`0xad72c8`, root item only): if layout == 3 use custom `+0x250`; else if stored width == 0: layout 0 -> 936 (sic), layout 2 -> 1152, otherwise 0; otherwise the stored width. (Note the narrow/0 asymmetry versus resolvedWidth; only matters for width-less legacy docs.) [V code, I intent]
* QTextDocument settings in the text-item ctor (`0xae2e68`): `setIndentWidth(48.0)`, default text option via `setDefaultTextOption`; **no** `setDocumentMargin` call anywhere near it (the only caller is `0x6b6868`, a different object) so documentMargin = Qt default **4.0** [I]. Font hinting: `QFont::setHintingPreference(PreferNoHinting)`.
* Screen scroll/recenter: QML calls `sceneView.recenter()` before changing the layout.

### 2.4 `.rm` storage [V from rmscene `scene_stream.py:785-836` + library files]
`RootTextBlock` value: `pos_x` float64, `pos_y` float64, `width` float32 (`write_float(4, width)`), plus the CRDT text/styles. Defaults written by the device: `pos_x = -width/2 = -468.0`, `pos_y = 234.0`, `width = 936.0`; the 740/1152 presets would give `-370/234/740` and `-576/234/1152` (derived, not observed in a shipped file) [I]. The in-memory width of the item is a `float` (`+0x1c8`) while the controller property is `double`.

---------------------------------------------------------------------------

## 3. Typed-text styling defaults on notebook pages

Style table object (`0xad4408`, called from the text-item ctor at `0xae3278`) builds one `QTextBlockFormat` + `QTextCharFormat` per paragraph style; font factory `0xad4118(style)`; block-format lookup `0xad386c`; cached line height `0xad39a0`; applying a block format `0xad3a44` [V]. Page unit = scene px (1404-wide page).

### 3.1 Fonts and sizes [V]
Font factory `0xad4118`: `QFont`, hinting preference = PreferNoHinting (1), pixel size set directly.

| UI name (QML `ParagraphStyle.Type`) | in-memory style | family | pixel size | weight (Qt6 scale) |
|---|---|---|---|---|
| Title (`formatting_title`) | heading tag, sub 1 (`0xa086ac`) = `.rm` HEADING(2) | **reMarkable Serif Small** | **64** | **300** (Light; the family only ships 400/700 so it renders Regular) |
| Subheading 1 (`text_t_heading`) | heading tag, sub 3 (`0xa07d78`) | reMarkable Serif Small | **46** | 400 |
| Subheading 2 (`formatting_subtitle`) | heading tag, sub 2 (`0xa08464`) = `.rm` BOLD(3) on load | **reMarkable Sans** | **36** | **500** (Medium) |
| Body text (`formatting_paragraph`) | paragraph tag (`0xa08528`) = `.rm` BASIC(0) (sub 0 = PLAIN(1) is also styled as body) | reMarkable Sans | **32** | 400 |
| Bullet / Numbered / Checkbox (+ indented variants) | list tag | reMarkable Sans (body font) | 32 | 400 |
| Checked checkbox | list tag, checked | same + **strikeout** (`QFont::setStrikeOut` when `0xa07238` true) | 32 | 400 |

Fonts are in `reference/remarkable-3.27.1.0/fonts/remarkable/` (`reMarkableSans-*.ttf`, `reMarkableSerifSmall-*.ttf`). Bold/italic character styles ("BoldStyle", "ItalicStyle" actions) are applied as char-format weight/italic on top of these [I, values not traced; bold = 700 per the generic painter `0xb52fe0`].
`.rm` mapping facts: `0xc24b78/0xc24c30` write HEADING=2 for Title, BOLD=3 for BOTH Subheading 1 and 2 (sub 2 and sub 3), PLAIN=1 for sub 0, BASIC=0 for paragraph; load of 3 gives Subheading 2 (sub 2) [V]. How Subheading 1 survives a save/load round trip is [U] (payload vector at style+8 not decoded).
Font metrics (hhea of all these TTFs: ascender 925, descender -255, lineGap 0, upem 1000): QFontMetricsF.height() unrounded = 1.18 x size: body 37.76, Title 75.52, Sub1 54.28, Sub2 42.48 (FreeType-rounded: 39 / 77 / 55 / 44) [V metrics, I rounding].

### 3.2 Paragraph spacing and line height [V]
All in px, QTextBlockFormat properties (`0x1030` TopMargin, `0x1048` LineHeight, `0x1049` LineHeightType, `0x1070` HeadingLevel):

| style | block top margin | extra line distance | heading level |
|---|---|---|---|
| Body (and every list style: they use the body block format, `0xad386c` falls through to base) | **24** (= 32 x 0.75) | LineDistanceHeight (type 4) of **0.2 x H_body** where H_body = QFontMetricsF(Sans 32).height() = 37.76 -> 7.55 px (line pitch ~45.3) | - |
| Title | **88** (= 32 x 2.75) | none (single line height) | 1 |
| Subheading 1 | **56** (= 32 x 1.75) | none | 2 |
| Subheading 2 | **40** (= 32 x 1.25) | none | 3 |
| bottom margin | not set (0) for every style | | |
(All margins are multiples of the *body* font's pixel size, 32.) Cached per-style "line height" (`+0x10, +0x28, +0x40, +0x58`) = font height (+ line-distance rule above) + top margin; used for cursor/selection rectangles and `+0x230 = max(topMargin,bottomMargin)+lineHeight(body)` row pitch [I].
Image blocks (tag 4) use a block-format copy of body with LineDistance **20.0** px and the body font (`0xad4838-0xad4890`). Whether Qt collapses adjacent margins (max) or adds them is Qt's standard block layout; not overridden here [I].
Empty document cursor/placeholder uses Title's margins (88) + Title line height (`0xadcd98-0xadcde4`) [V].

### 3.3 Lists: indents, markers [V]
* `QTextDocument::setIndentWidth(48.0)` (`0xae32e4`). A list paragraph's block format gets `BlockIndent (0x1040) = indentLevel + 1` (`0xad3a44`) => text starts **(level+1) x 48 px** from the box left (+ documentMargin 4 [I]); level 0 = 48, level 1 = 96, ...
* Markers are painted separately (paint fn `0xae1480`) at block-left + **level x 48**:
  * Bullet: UTF-16 glyph drawn with the bullet font, x = blockX + level*48 + **20**, baseline = blockY + ascent. Glyph by level: level 0 "•" U+2022, level 1 "◦" U+25E6, level 2 "-" U+002D, level >= 3 "•" (statics init `0x82bdc`, strings `0x119aa70/74/78`).
  * Checkbox: SVG `:/images/checkbox_unchecked.svg`, `checkbox_checked.svg`, `checkbox_indeterminate.svg` (third used for the indented variant, `0xa072a8`) rendered into a **40 x 40** rect at (blockX + level*48, blockY - 2.0). Hit-test rect (`0xa45cf0`, `0xa48038`): x = blockX - 5 + level*48, width/height padded by 10 (-5 each side). The SVGs are in the scratchpad `named/` set (also `reference/.../icons/checkbox_checked.svg`).
  * Numbered: label "N." (counter from `0xad9684`) drawn with the body font, right-aligned so that its right edge is at blockX + level*48 + **29**.
* Text colour: `QPainter::setPen(QColor(Qt::black))` (`QColor(2)` = Qt::black, `0xae1480`); selected text is drawn **white on black** (background brush `Qt::black`(2), foreground `Qt::white`(3), `0xae1480`). Hyperlink char format: anchor flag `0x2030`, underline style 1, foreground brush from static colour `0x11d94d0` = (alpha 0xffff, 0, 0, 0xffff) i.e. blue (0,0,255) if the Qt6 `QColor::Spec` field is 4 bytes [I]. Typed text has no per-document colour setting [V].

### 3.4 Not recovered [U]
Exact numbered-list label format beyond "N."; nested numbering style; bold/italic weight constants; whether Qt block margins collapse in this build; the `Subheading 1` file encoding.

---------------------------------------------------------------------------

## 4. Pen-toolbar colour indicator (pen buttons)

### 4.1 Answer in one paragraph
The colour of a pen button is **not** a tinted "tip" layer inside the glyph. The button shows the plain pen glyph (`<tool>_tip.svg`, 48x48, black or white depending on selection) and a **separate 28 x 28 filled circle drawn ABOVE the glyph** (higher z) in the button's top corner. The `*_tip.svg` files are byte-identical to the plain `<tool>.svg` files (checked for all nine: ballpoint, calligraphy_pen, fineliner, highlighter, marker, mechanical_pencil, paintbrush, pencil, shader), so "tip" is only the resource name that `PenToolModel` hands out (`qrc:/ark/icons/<tool>_tip`, table at `0x28ed14`, strings `0x119c0fc..0x119c2ec`); there is no coloured/tinted variant. Thickness is **not** shown on the toolbar button at all.

### 4.2 Structure and z-order [V]
* `00eaba89.qml` = `WritingToolMenu` (`PenTool`), `iconSource: toolModel.iconForTool(pen.tool)` (`:45`, returns `qrc:/ark/icons/<tool>_tip`), `content: Item{ id: indicator ... }` (`:48-148`).
* `ToolbarTool` base `00ea63db.qml`: the `ArkControls.ToolButton` is the Loader's item (`:94-115`, icon token size 48, black idle / white selected); `property Item content` is reparented into `_childrenContainer` (`:18-19`, `:147-151`) whose `z: root.item ? root.item.z + 1 : 0` => the indicator is above the button's icon and background.
* Button size = `ArkTokens.Style.variable.controlsHeight.large` = **112 x 112** (`00ea97ed.qml:18`, `tokens/rM-paper-tablet.json.qml:712`); toolbar `gestureMargin` = 20 (`00ea97ed.qml:182`), button `topInset = -gestureMargin` when the toolbar is on top (`00ea63db.qml:49`).

### 4.3 Exact geometry of the indicator circle (`00eaba89.qml:69-147`) [V]
```
Rectangle indicatorCircle { width: 28; height: 28; radius: width (=28, i.e. a full circle);
   anchors.top: parent.top; anchors.topMargin: root.topInset + 8        // margin = 8
   // horizontal: states "rightPosition" (when: true, default)  -> anchors.right = parent.right, rightMargin 8
   //             "leftPosition" (when toolbar.position === Right) -> anchors.left = parent.left, leftMargin 8
   color: indicator.bodyColor }
```
In a 112 px button this puts the circle at x = 76..104 (right anchored) or x = 8..36 (left anchored when the toolbar sits on the right edge), y = 8..36 (topInset 0) i.e. 8 px from the top; with the toolbar at the top edge `topInset = -20` so y = -12..16 relative to the button item (still 8 px below the toolbar's top screen edge). The 48 px glyph is centred in the 112 button (x 32..80, y 32..80, glyph art spans x 39..73 for a ballpoint) so the circle sits to the upper side of the glyph with ~3 px clearance and essentially no overlap [centring I].
* Second colour (stacked): `Item{ y: height; rotation 180; height: 14; width: 28; clip: true; visible: stackedColor != "transparent"; Rectangle{28x28, radius 14, color: stackedColor} }` => the lower half-disc is `stackedColor = Qt.darker(bodyColor)` (QML default factor 2.0) when `colorModel.isStacked(...)` (used by the Shader tool).
* Border (`:100-107`): `Rectangle{ anchors.fill: parent; color: transparent; radius: parent.radius; border.width: indicator.borderWidth; border.color: indicator.outlineColor }`; `borderWidth = colorModel.borderWidth(color, code)`.
* `outlineColor` (`:55-65`): not selected AND `bodyColor == "#ffffff"` -> `#000000` (white dot gets a black ring); selected (button turns black) AND `bodyColor == "#000000"` -> `#ffffff` (black dot gets a white ring); otherwise transparent.
* `Epaper.ScreenModeItem{ objectName: "pen-color"; anchors.margins: 4; mode: Content; visible: hasCapability(Color) }` inside the circle: on colour panels (Paper Pro) the inner 20 x 20 disc is a colour-refresh region. Not present on RM2 (no Color capability). In the foldout colour grid a mono-only `ScreenModeItem{ objectName: "pen-mono-dither"; mode: Mono }` is added on non-colour panels.
* Which side: selected pen is `toolbar.selectedPen === root` -> `implicitlySelected` (`:47`); the circle is drawn in both pens (primary / secondary buttons).

### 4.4 Colours per colour id (`PenColorModel`, `0xea0f204`, rebuild fn `0x28bf18`, full-colour table `0x28ba20`, lookups `0x286cb8`) [V]
Model entry (0x28 bytes): `QString displayName @0, QString colorString @0xc, int toolColor(id) @0x18, uint rgb(code) @0x1c, bool stacked @0x20, int borderWidth @0x24`; roles `0x101 displayColor` (QColor from `colorString` via `QColor::fromString`), `0x102 displayName`, `0x103 toolColor`, `0x104 rgb`, `0x105 stacked`, `0x106 borderWidth`. Lookup is by (toolColor id, rgb code) pair. Default colour = first row (`defaultColorEnum`/`defaultRgbCode`; `rgb` default 0xff000000).
Line colour ids used: 0 Black, 1 Gray, 2 White, 6 Blue, 7 Red, 9 = `Line.ArgbCode` (explicit ARGB carried in `rgb`), 10 Green, 11 Cyan, 12 Magenta, 13 Yellow.

**RM2 / mono panel (`enableFullColorSelection` false) and tool is a writing pen (not highlighter, not Shader):** 5 rows, all with borderWidth **4**, stacked false, rgb 0xff000000:
| id | name | colorString -> displayColor |
|---|---|---|
| 0 | Black | `black` -> #000000 |
| 1 | Gray | `gray` -> Qt named colour #808080 |
| 2 | White | `white` -> #ffffff |
| 6 | Blue | `#989898` (blue is shown as light grey) |
| 7 | Red | `#545454` (red is shown as dark grey) |
**Shader tool (id 0x17 = 23), mono:** a single row "Gray": id 9 (ArgbCode), rgb `0x40211e1c`, colorString `#7a7776`, **stacked = true**, borderWidth 0 (top half #7a7776, bottom half Qt.darker -> ~#3d3b3b).
**Highlighter tools (5 and 18), any panel:** 6 rows, id 9 (ArgbCode), stacked false, `borderWidth = (enableFullColorSelection ^ 1) << 2` = **4 on mono, 0 on colour**; displayColor = `QColor(argb).name(HexArgb)` of:
| name | ARGB (rgb code) |
|---|---|
| Yellow | 0xffffed75 |
| Blue | 0xffbeeafe |
| Pink | 0xfff29eff |
| Orange | 0xffffc38c |
| Green | 0xffacff85 |
| Gray | 0xffc7c7c6 |
**Full-colour panel (Paper Pro), non-highlighter pens:** Black #000000 (0), Gray **#909090** (1), White #ffffff (2), Blue #0000ff (6), Red #ff0000 (7), Green #00ff00 (10), Yellow #ffff00 (13), Cyan #00ffff (11), Magenta #ff00ff (12) (helper `0x791bb0` takes extra stack args, one of them 2 for black/white and 0 for the others, probably stacked/border; not decoded [U]); plus a "Gray" `#7a7776` row for the shader. The mono `black`/`gray`/`white` strings are used only on RM2.
The foldout swatch (`00eaba89.qml:359-369`) uses `ArkControls.ColorSwatch{ size: 39; color: displayColor; duoColor: stacked ? Qt.darker(displayColor, 1.6) : ""; duoOpacity 1; borderColor: selected ? "white" : "black"; borderWidth: model; rotation: stacked && borderWidth == 0 ? 90 : 0; antialiasing false }` inside a 112 x 112 `FoldoutGridItem` (icon spacing 8), 3 columns.
Highlighter/white handling summary: white is the only colour that needs a ring on an unselected (white) button; black needs a ring when the button is selected (black). The `borderWidth` from the model (4 on mono) is applied to ALL colours but the ring is only visible (non-transparent) in those two cases in the toolbar indicator; in the foldout swatch it is always visible (black ring, white ring when selected).

### 4.5 Thickness indication [V]
* Toolbar button: none.
* Foldout (`00eaba89.qml:315-333`): `ThicknessGrid` (3 columns; 1 column in the row layout), `PenThicknessModel` rows 1 "Thin" (`qrc:/ark/icons/stroke_thin`), 2 "Medium" (`stroke_medium`), 3 "Thick" (`stroke_thick`) (fn `0x28de20`; names `0x10eb1e0/e8/f0`); selected = `root.pen.thickness === thickness` (black cell, white icon). Section header shows `nameForThickness(pen.thickness)`. Hidden for the highlighter (`hasWidthOption` false for Highlighter/Highlighterv2).

---------------------------------------------------------------------------

## 5. Key code addresses (xochitl 3.27.1.0 ARM)
| thing | address |
|---|---|
| TextWidthModel metacall / ctor / data / roleNames | `0x28b8c8` / `0x289dfc` / `0x288490` / `0x28ad00` |
| TextColumn metaobject / static_metacall / resolvedWidth | `0x1043cac` / `0x407750` / `0x44a520` |
| layout->width setter (SceneController metacall), snap width->layout | `0x41cbe0`.. in fn `0x401b60` / `0x414fcc` |
| SceneTextItem::setWidth, setPos helper | `0xa18bb8` / `0xad80ec` |
| item position per layout (-370/-468/-576, 740/936/1152) | `0xa1db54`, `0xa1dce0`, `0xa1e160` |
| text-item ctor, setIndentWidth(48) | `0xae2e68`, call at `0xae32e4` |
| style table builder, font factory, block-format apply | `0xad4408`, `0xad4118`, `0xad3a44` |
| list marker painter | `0xae1480` |
| ParagraphStyle ctor / to-int | `0xc24950` / `0xc24b78` |
| PenColorModel rebuild / full-colour table / entry add (named, ARGB) | `0x28bf18` / `0x28ba20` / `0x791a68`, `0x772d28` |
| PenToolModel icon table, thickness model | `0x28ed14`, `0x28de20` |
