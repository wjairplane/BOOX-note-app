# DocumentCover (file-browser thumbnail overlay) - recovered from xochitl 3.27.1.0

Source: ARM disassembly of the stripped `xochitl` (Ghidra 11.3.2 + capstone). Class `13DocumentCover` is a
`QQuickPaintedItem` (QPainter, not scene graph). Functions (vaddr): `paint()` 0x5b77ec, draw core 0x5b4ca4,
rounded-book path 0x5b4a14, corner helper 0x7c7e08, ctor ~0x7c7ce4, qt_static_metacall 0x5a57c4.
Moc string table (0xdefa9a..) gives the property/enum names. Confidence: HIGH for geometry/order/colours
(read straight from instructions); MEDIUM for text-height-derived thumbnail heights.

## 1. Properties, defaults (ctor)

| idx | name | offset | default |
|---|---|---|---|
| 0 | documentType (enum Undefined=0, Notebook=1, Pdf=2, Ebook=3) | +0x10 | Undefined |
| 1 | borderWidth (double) | +0x18 | 1.0 |
| 2 | decorationScale (double) | +0x20 | 1.0 |
| 3 | backgroundColor | +0x28 | Qt::white |
| 4 | color | +0x48 | Qt::white |
| 5 | borderColor | +0x38 | Qt::black |
| 6 | fillMode (Transparent=0, Filled=1) | +0x58 | Transparent |
| 7 | smooth | +0x5c | true (QML sets `smooth: Values.desktopSimulator` = false on device) |
| 8 | cached | +0x5d | true |

The grid item (00d8d745.qml) sets only `color: white`, `borderColor: black`, `backgroundColor: selected ? black : white`,
`smooth`, `documentType`. So on device: borderWidth 1, decorationScale 1, fillMode Transparent, antialiasing OFF
(`setRenderHint(Antialiasing, QQuickPaintedItem::antialiasing())`, never set in QML => false), `smooth` false.
All 0.5 offsets below exist so 1 px non-AA pens land on whole pixels.

`cached=true`: paint() renders the same ops into a `QPixmap(ceil(w), ceil(h))` pre-filled transparent
(key `type:borderWidth:scale:colors:fillMode:WxH` in QPixmapCache) and `drawImage(0,0)`s it 1:1. No visual difference.

## 2. What the cover does NOT do
No drop shadow, no 2 px frame, no page-stack lines. The only frame is the 1 px border drawn by the cover itself
(pixels 0 and w-1/h-1, i.e. inside the item rect). The thumbnail image is a plain QML `Image` (PreserveAspectCrop
for portrait, mipmap) under the cover (00d8d745). `PageThumbnail` (native) is only used in page overview / older
00dba000 cards, with `borderColor: black; borderWidth: Values.hairlineSize (1)`; selection there inverts, no shadow.

## 3. Pen / brush
Pen = `QPen(borderColor, borderWidth, SolidLine, FlatCap, MiterJoin)`; if `borderWidth <= 0` => NoPen.
Pen is applied AFTER the fills of each shape. W,H = item width,height in px. `S = decorationScale` (=1).

Common shape "book" (used by Notebook and Ebook), `R = 18*S`:
```
P = M(0.5,0.5) L(W-0.5-R,0.5) Q[ctrl (W-0.5,0.5)] -> (W-0.5, R)   // note end y = R (not R+0.5)
    L(W-0.5, H-0.5-R) Q[ctrl (W-0.5,H-0.5)] -> (W-0.5-R, H-0.5)
    L(R, H-0.5) L(0.5, H-0.5) L(0.5,0.5)          // left side square, right corners rounded
```
Transparent fill mode (default): corner mask `Cm` filled with `color` (white), no stroke:
```
Cm = M(W,0) L(W-R,0) Q[ctrl (W,0)] -> (W,R) L(W,H-R) Q[ctrl (W,H)] -> (W-R,H) L(R,H) L(W,H) L(W,0)
```
(effectively the two cut-off right corners are painted white over the image). Filled mode: `fillPath(P, backgroundColor)`.
Then `drawPath(P)` with the border pen (brush is none).

## 4. Per documentType (draw order)
- **Undefined (0)**: pen only; `drawRect(0.5, 0.5, W-1, H-1)`. No brush.
- **Notebook (1)**: (a) Cm filled white; (b) stroke P; (c) spine: brush = `backgroundColor` (white, or BLACK when
  selected), pen = border pen; `drawRect(0.5, 0.5, 12*S-1, H-1)` = 12 px wide band (pixel cols 0..11), opaque,
  covering the image's left 12 px; outline cols 0 and 11, rows 0 and H-1.
- **Ebook (3)**: (a) Cm filled white; (b) stroke P. No spine.
- **Pdf (2)**, `F = 40*S`, `x = W-F-1`:
  1. brush = `color` (white). Transparent: pen = `color` (1 px), `drawPath` cut triangle
     A = (x,0.5) (W,0.5) (W,F)  (erases the image's top-right corner).
     Filled mode instead: `fillPath(M(0.5,0.5) L(x-1,0.5) L(W-1,F) L(W-1,H) L(0.5,H), backgroundColor)`.
  2. flap: pen = border pen, brush = SOLID WHITE (fixed, independent of selection);
     `drawPath` C = (x,0.5) (x,F) (W-1,F) closed (hypotenuse = the diagonal fold crease).
  3. if borderWidth>0, four `drawLines` with the border pen:
     (0.5,0.5)-(x,0.5); (W-1,F)-(W-1,H-1); (0.5,H-1)-(W-1,H-1); (0.5,0.5)-(0.5,H-1).

## 5. Selection
`backgroundColor` flips to black only affects the Notebook spine fill (and Filled mode). Border colour stays black,
`color` (corner masks / PDF cut) stays white. The whole cell turns black (ContentItemBase `background`) and text white.

## 6. Layout numbers (Values singleton 00d82ba4.qml; tokens 011295ae.qml = rM paper tablet)
- designGridMargin 15; designGridHorizontalSpacing 15; designGridHorizontalGutter 15; designGridHorizontalHeight 45;
  designGridVerticalGutter 33; designGridVerticalSpacing 30; designGridVerticalWidth 84 (portrait) / 123.
- navigatorContentGridItemLabelHeight 80 (95 accessibility) - only used by the legacy 00dba000 card and Values.gridSize;
  outlineSize 2, hairlineSize 1, archivedThumbnailOpacity 0.6, navigatorContentCollectionHeight = 45+2*15 = 75.
- Real grid (ContentGridView 00d8e613 + ThumbnailGridSize 0106262a.qml): spacing.small = 16 = thumbnailMargin.
  min thumb width: Small 197, Medium/List 244, Large 324 (accessibility: Small 244, Medium 324).
  `cols = floor(W / (minW + 32))`, `cellW = floor(W/cols)`, `cellH = ceil(cellW*4/3) + 80` (labelHeight = controlsHeight.small 80).
  W = grid width. At W=1404: Large 3 cols, cell 468x704; Medium 5 cols, 280x454; Small 6 cols, 234x392.
  (At 990 = sidebar open: Large 2 cols 495x740; Medium 3 cols 330x520; Small 4 cols 247x409.)
- Thumbnail rect (00d8d745): left/right/top margin 16, bottom = textColumn.top - 8; textColumn = 16 from cell bottom,
  height = label (25px*1.58 = ~39.5) + caption (22px, line 32) ~ 72 (MEDIUM confidence). So thumb ~ (cellW-32) x (cellH-112),
  e.g. Medium@1404: 248 x ~342. DocumentCover fills exactly this rect (no extra inset). Small grid hides the caption.
- Folder header (`header: GridView`, 00d8e613): cellWidth = same gridItemWidth, cellHeight = 75, non-interactive,
  height = contentHeight. Item = 00d8fe5c (MEDIUM-HIGH confidence it is ContentGridFolderItem): bg white/black(selected);
  RowLayout margins L/R 15, spacing 10: folder icon cell 48 wide (icon 48, centred, full item height), then title
  (SubheaderSmall, ElideMiddle, max 70% width), star icon (favourite), tags (fills), sync icon, caption "N items"
  (right); optional progress bar below the row; 1 px separator (hairline, itemColor) along the bottom full width.

## 7. Comparison with FilesScreen.kt `Thumb`
| Aspect | App now | Firmware |
|---|---|---|
| Frame | 2 px (Rm.Outline) border via `.border` | 1 px, inside rect, drawn by cover, non-AA |
| PDF fold | 56 px white tri + 4 px diagonal | 40 px; upper-right 1-px-outlined cut triangle (white), lower-left flap triangle white with 1 px black outline, no 4 px line |
| Notebook | 2 px line 14 px in | 12 px opaque band (white / black when selected), 1 px outline + divider at col 11, AND rounded right corners (quad, 18 px) |
| Ebook | treated as notebook (spine) | no spine; rounded right corners only |
| Other types | spine | plain 1 px rectangle |
| Selection | none in cover | spine fill turns black |
| AA | Compose default | off (use `isAntiAlias=false`, integer+0.5 coords) |

## 8. Drawing recipe (thumbnail-relative px, W,H = size, S=1, pen = 1 px black, miter, flat cap, AA off)
```
image (crop) fills rect
Undefined: strokeRect(0.5,0.5,W-1,H-1)
Notebook/Ebook (R=18):
  fill white: Cm = M(W,0) L(W-R,0) Q(W,0 -> W,R) L(W,H-R) Q(W,H -> W-R,H) L(R,H) L(W,H) close
  stroke P = M(.5,.5) L(W-.5-R,.5) Q(W-.5,.5 -> W-.5,R) L(W-.5,H-.5-R) Q(W-.5,H-.5 -> W-.5-R,H-.5) L(R,H-.5) L(.5,H-.5) L(.5,.5)
  Notebook only: fillRect(.5,.5,11,H-1, selected?black:white); strokeRect(.5,.5,11,H-1) black
Pdf (F=40, x=W-F-1):
  fill+stroke white: tri (x,.5)(W,.5)(W,F)
  fill white + stroke black: tri (x,.5)(x,F)(W-1,F)
  lines black: (.5,.5)-(x,.5); (W-1,F)-(W-1,H-1); (.5,H-1)-(W-1,H-1); (.5,.5)-(.5,H-1)
```
