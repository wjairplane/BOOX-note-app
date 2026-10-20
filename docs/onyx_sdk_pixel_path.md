# Onyx SDK: is there a fast path for the app's own pixels?

Scope: onyxsdk-pen 1.5.4.4 (+ onyxsdk-device 1.3.5.3, onyxsdk-base 1.8.5.5, onyxsdk-penbrush 1.1.1.2, onyxsdk-pennative 1.0.5), read from the Gradle cache with `javap -c -p`, `readelf`, `strings` (nothing executed). Scratch extraction: `/tmp/claude-0/-home-user-BOOX-note-app/49c791b8-36e3-5584-bfb4-b5d40653e991/scratchpad/sdk_research/`.

Legend: **[V]** verified in the jars/.so files; **[I]** inferred from names or structure; **[?]** guess, needs the device.

## 0. Verdict

**No documented or fully verified custom-pixel fast path exists.** The SDK's live ink is drawn by the Android framework / panel service (`android.onyx.*` classes inside the firmware), not by the SDK. The SDK only passes it `style`, `width` and `colour` ints/floats plus pen state. [V] Nothing in the SDK hands a framebuffer, Surface or ANativeWindow to the panel driver.

There is, however, **one public-but-obscure candidate** that nobody should assume works until tried on the device:

`EpdController.drawScreenHandWritingBitmap(Bitmap, Point): boolean` [V]. It exists in `EpdController` (public static), is forwarded to `BaseDevice`, and is implemented only by `SDMDevice` (Qualcomm boards: msm8953, sdm660, bengal, msmnile, lito, volcano). It reflects into the firmware method `android.onyx.hardware.DeviceController.drawScreenHandWritingBitmap(Bitmap, Point)`, and the SDK logs "drawScreenHandWritingBitmap failed" on exception. On RK32/RK33/IMX/base devices it is a stub returning `false` [V]. The SDK itself never calls it [V], so its semantics (which layer, which waveform, whether it needs pen state active, whether it is erased by pen-up) are **unknown** [?]. Whether the Note Air 5C is an SDM-class device must be checked at runtime (`Device.getBoardPlatform()`, `Device.currentDevice()` class).

Related hidden stubs of the same family, all no-ops on non-SDM devices and reflected into firmware on SDM: `handwritingRepaint(View, l,t,r,b)`, `setScreenHandWritingRegionConfig(Rect, StrokeConfig[])`, `clearScreenHandWritingRegionConfig()`, `setEpdTurbo(int)`, `applyTransientUpdate(UpdateMode)`, `set/getStrokeParameters(int style, float[])`. [V]

## 1. Draw APIs and layers

### 1.1 How the stock live ink works [V]

`TouchHelper.create(view, cb)` chooses a feature mask: if `DeviceFeatureUtil.hasStylus` then `FEATURE_SF_TOUCH_RENDER` (2) else `FEATURE_APP_TOUCH_RENDER` (1). Masks: 1 = `AppTouchRender`, 2 = `SFTouchRender`, 4 = `AppPenTouchRender`; `create(view, int features, cb[, bool])` lets the app pick.

- **SFTouchRender** (default on BOOX): `openDrawing()` calls `RawInputManager.startRawInputReader()` (native `/dev/input/eventN` reader, thread `readTouchEventLoop`) and `EpdPenManager.startDrawing()` = `EpdController.setScreenHandWritingPenState(view, 1)`. `resume`=2, `pause`=3, `quit`=0 (EpdPenManager `PEN_START/DRAWING/PAUSE/STOP`; `PEN_ERASING`=4). Stroke style/width/colour are pushed with `EpdController.setStrokeStyle/Width/Color` into firmware. No pixel is produced by the SDK; the framework draws the ink on a handwriting layer ("SF" = SurfaceFlinger-side) while the native reader only reports `TouchPoint`s back to Java through `RawInputReader.onTouchPointReceived(FFIIIZZZIJ)V`.
- `setRawDrawingRenderEnabled(false)` (what PenSurface uses in Exact + SDK input) on SF render calls `Device.setBrushRawDrawingEnabled(false)` (reflected firmware method `setBrushRawDrawingEnabled`) so the pen is tracked but not drawn. [V]
- **AppTouchRender** (feature 1): input from `MotionEvent`s (`AppTouchInputReader`), draws by calling `EpdController.moveTo(view,x,y,width)` / `quadTo(view,x,y,UpdateMode[,pressure])` / `lineTo` / `penUp()` / `enablePost(view,0|1)`. These are vector commands executed by firmware (reflected `moveTo/lineTo/quadTo/penUp`), not bitmaps. `enablePost(view,0)` while drawing, `enablePost(view,1)` when render is disabled/closed: it gates whether the normal view updates are posted to the panel. [V for calls; meaning of the int is [I]]
- **AppPenTouchRender** (feature 4): same as AppTouchRender plus `EpdPenManager` resume/pause (pen-state 2/3). [V]
- Also reflected: `startStroke/addStrokePoint/finishStroke(float x6)` returning float (x, y, pressure, size, and two more; names unknown), `setPainterStyle(boolean, Paint.Style, Join, Cap)`, `setScreenHandWritingRegionLimit/Exclude/Mode`. [V that they exist; arg meaning [?]]

### 1.2 What can be customised (limits)

| Item | API | Limit |
|---|---|---|
| Style | `TouchHelper.setStrokeStyle(int)` -> `EpdController.setStrokeStyle(int)` | Fixed integer enum (section 3). No bitmap brush, no RGBA texture. |
| Width | `TouchHelper.setStrokeWidth(float)` -> `RawInputReader.nativeSetStrokeWidth` AND `EpdController.setStrokeWidth` | One constant width in screen px. The native reader also has `PenManager::setMaxPressure` / `normalizePressure` / `resetStrokeWidth` [V symbols]. |
| Colour | `TouchHelper.setStrokeColor(int)` -> `EpdPenManager.setStrokeColor` -> `EpdController.setStrokeColor` and stored in `RawInputReader.k` | A plain int passed straight to firmware, no SDK-side processing [V]. ARGB vs RGB, and alpha handling are firmware-defined [?]. |
| Pressure curve | none in the public API | Only `getMaxTouchPressure()`, `EpdController.MAX_TOUCH_PRESSURE`. Possibly via `setStrokeParameters` (below). |
| Per-region/per-pen-button config | `EpdController.setScreenHandWritingRegionConfig(Rect, StrokeConfig[])` | SDM only; `StrokeConfig{penButton:String, strokeStyle:int, strokeWidth:float, strokeColor:int, params:float[], eraserRawDrawingEnabled:boolean, eraserRawDrawingPainter:int}`. Converted into firmware `android.onyx.handwriting.StrokeConfig` / `PenConfig` / `PenButton` Parcelables. `params` is the only free-form knob and its layout is not in the SDK. |
| Style parameter tables | `Device.currentDevice().setStrokeParameters(int style, float[])` / `getStrokeParameters(int style)` | SDM only, not exposed on `EpdController`, base returns `float[0]`. This is the only thing in the SDK that looks like a "stroke style table". Layout unknown [?]. Dump it on the device: `getStrokeParameters(0..7)`. |
| Eraser as pen | `TouchHelper.setEraserRawDrawingEnabled(bool,int)` | SDM only (firmware method). |
| Pen-up refresh | `setPenUpRefreshEnabled/TimeMs`, `RawInputCallback.onPenUpRefresh(RectF)` | Controls the SDK's own post-stroke refresh, not content. |

### 1.3 App-side renderer (separate from the panel path) [V]

`onyxsdk-penbrush` (`NeoPen`, `NeoPencilPen`, `NeoBallpointPen`, `NeoFountainPen(V2)`, `NeoMarkerPen(V2)`, `NeoBrushPen`, `NeoCharcoalPen(V2)`, `NeoSquarePen`) and `onyxsdk-pennative` (`NeoPenNative.nativeCreatePen/OnPenDown/OnPenMove/OnPenUp`, JNI `libneopen_jni.so`) are the SDK's *stored-stroke* renderers: input points (double[]) -> `PenInkResult{realInk, predictionInk}` where `PenInk` = `float[] points` + `int[] pointSizeArray` + `Bitmap[] bitmaps`, drawn by the app into its own Canvas (`NeoPenRenderWrapper.render(Canvas, Paint)`, `PenRenderArgs`). `libneopen_jni.so` links `libjnigraphics.so` (writes into bitmaps) but has **no** EPD or surface calls. This is how an app would reproduce the firmware-like look in its own bitmap; it is not a fast path to the panel. Config (`PenConfig`): type (BRUSH 1, FOUNTAIN 2, MARKER 3, CHARCOAL 4, CHARCOAL_V2 5, FOUNTAIN_V2 6, **PENCIL 7, BALLPOINT 8**, SQUARE 9, BRUSH_SIGN 10), `fastMode`, color, width, minWidth, rotateAngle, tilt, brushSpacing/shape/ratio/angle, pressure/velocity sensitivity, smoothLevel, endThinningRate, etc.

## 2. Native libraries

### libonyx_pen_touch_reader.so (arm64/armv7/x86/x86_64)

JNI exports, all on `com.onyx.android.sdk.pen.RawInputReader` [V]:
`nativeRawReader()V`, `nativeRawClose()V`, `nativeIsValid()Z`, `static nativeDebug(Z)V`, `nativeSetStrokeWidth(F)V`, `nativeSetLimitRegion([F)V`, `nativeSetExcludeRegion([F)V`, `nativeSetPenState(I)V`, `nativePausePen()V`, `nativeSetRegionMode(I)V`, `nativeEnableSideBtnErase(Z)V`.

Internals (C++ symbols/strings): `android::TouchReader` (opens `/dev/input/event%d`, matches device names "onyx_emp", "Wacom", "hanvon", `ioctl`, `poll`, eventfd), `PenManager` (`moveTo`, `quadTo`, `finishQuadTo`, `inLimitRegion`, `inExcludeRegion`, `normalizePressure`, `setMaxPressure`), readers `DrawReader/EraseReader/SideEraseReader/BtnReader`, `EventQueue`, `ColorUtils`. It calls back only `RawInputReader.onTouchPointReceived(FFIIIZZZIJ)V` and a few `android/onyx/hardware/DeviceController` static `()Z` / `()I` queries. Undefined imports: libc/libm/liblog only (no libEGL/libandroid/libgui/ANativeWindow, no SurfaceControl, no ioctl on fb). **Conclusion: it is an input reader with region filtering; it submits no pixels.** [V]

### libneopen_jni.so (pennative)

JNI exports on `NeoPenNative`: `nativeCreateLogger`, `nativeRegisterLogger`, `nativeSetLogLevel`, `nativeCreatePen(I, PenConfig)J`, `nativeDestroyPen(J)`, `nativeOnPenDown(J,[D,Z)PenInkResult`, `nativeOnPenMove(J,[D,[D,Z)`, `nativeOnPenUp(J,[D,Z)`, plus `nativeSetBitmapColor`. NEEDED: libjnigraphics, liblog, libm, libc++_shared. Pure software brush renderer. [V]

### Java-level "post" paths that reach the panel

The only things that talk to the panel service are the reflected firmware calls in `onyxsdk-device` (`BaseDevice` subclasses SDM/RK33/RK32/RK31/IMX6/IMX7), through `android.onyx.ViewUpdateHelper`, `android.onyx.hardware.DeviceController`, `android.onyx.optimization.EInkHelper`: `refreshScreen`, `refreshScreenRegion(View,x,y,w,h,mode)`, `postInvalidate(view, mode)`, `invalidate(view[,rect], mode)`, `setViewDefaultUpdateMode`, `enableScreenUpdate`, `holdDisplay(bool, mode, int)`, `byPass(int)`, `repaintEveryThing`, `applyGCOnce`, `waitForUpdateFinished`, `setUpdListSize(int)`, `setAutoSyncBufEnable(bool)`, `useGCForNewSurface(bool)`, `applyAppScopeUpdate(pkg,bool,bool,mode,int)`, `applySysScopeUpdate(mode,scheme,int)`, `applyTransientUpdate(mode)` (SDM/RK32 only), `applySystemFastMode(bool)`, `setDisplayScheme(int)`. None takes pixels; they steer the update of what the Android compositor already put in the surface. [V]

## 3. Stroke styles (what Hybrid sets)

`TouchHelper` (pen 1.5.4.4) constants [V]:

| id | TouchHelper | StrokeStyle | EpdController (older set) | Comment |
|---|---|---|---|---|
| 0 | STROKE_STYLE_PENCIL | PENCIL | STROKE_STYLE_PENCIL | what PenSurface uses for FINELINER, MECHANICAL_PENCIL, BALLPOINT |
| 1 | FOUNTAIN | FOUNTAIN | STROKE_STYLE_BRUSH | pressure-width pen; PenSurface default |
| 2 | MARKER | MARKER | MARKER | used for MARKER, HIGHLIGHTER |
| 3 | NEO_BRUSH | NEO_BRUSH | NEO_BRUSH | PAINTBRUSH |
| 4 | CHARCOAL | CHARCOAL | CHARCOAL | PENCIL (the reMarkable "pencil") |
| 5 | DASH | DASH | - | lasso |
| 6 | CHARCOAL_V2 | CHARCOAL_V2 | - | not used yet |
| 7 | SQUARE_PEN | SQUARE_PEN | - | CALLIGRAPHY |
| 8 | - | SOFT_ERASER | - | not a TouchHelper constant |

Parameters per style are **not** visible in the SDK; they live in firmware. Setters available to tune the live look: `setStrokeStyle`, `setStrokeWidth` (px, constant), `setStrokeColor` (int; see below), and on SDM only `setStrokeParameters(style, float[])` / `StrokeConfig.params`. [V]

To match PENCIL / mechanical pencil: choose the id, pass the page-scaled width (already done), and pass a *mid-grey* colour instead of pure black to imitate a thinner/lighter graphite. Whether firmware honours an ARGB grey or maps it to black/white is [?]. Alternative that is certain to work: keep style 0, tune only the width, and accept the fixed pressure behaviour. For a reMarkable look the app-side renderer in 1.3 (PENCIL 7 / BALLPOINT 8 configs) can draw the matching final bitmap.

`TouchHelper.setStrokeColor` on a colour panel: the value is not post-processed, so any darkening/lightening comes from the firmware's colour pipeline (below), not the SDK. [V for SDK side]

## 4. Latency levers inside the SurfaceView path

All reflected into firmware [V that they exist; effect [?] until measured]:

1. **Update mode per call**: `refreshScreenRegion(view, x,y,w,h, mode)`. UpdateMode values: None, DU, DU4, GU, GU_FAST, GC, GCC, DEEP_GC, ANIMATION, ANIMATION_QUALITY, ANIMATION_MONO, ANIMATION_X, GC4, REGAL, REGAL_D, REGAL_PLUS, DU_QUALITY, HAND_WRITING_REPAINT_MODE. SDM maps them to firmware ids `UI_DU_MODE, UI_DU_QUALITY_MODE, UI_GU_MODE, UI_GC_MODE, UI_GCC_MODE, UI_DEEP_GC_MODE, UI_A2_QUALITY_MODE, UI_MONO_A2_MODE, UI_X_A2_MODE, UI_GC4_MODE, UI_REGAL_MODE, UI_REGAL_PLUS_MODE, UI_DU4_MODE, HAND_WRITING_REPAINT_MODE`. Candidates for lowest latency, in order to try: `ANIMATION_MONO` (A2 mono), `ANIMATION_X`, `DU4`, `ANIMATION`, `DU`. The app currently uses ANIMATION for live and DU for final. `HAND_WRITING_REPAINT_MODE` is what the firmware uses for `handwritingRepaint`; try it as the live mode.
2. **View default mode**: `setViewDefaultUpdateMode(view, mode)` / `resetViewUpdateMode` makes every normal `unlockCanvasAndPost` use that mode, so no extra `refreshScreenRegion` call is needed. This halves the number of binder calls per frame.
3. **Scoped fast mode**: `applyAppScopeUpdate(pkg, true, true, UpdateMode.X, int)`, `setAppScopeRefreshMode(UpdateOption.FAST|FAST_X|FAST_QUALITY|REGAL|NORMAL)`, `applySystemFastMode(true)`, `EpdController.useFastScheme()` (= `setDisplayScheme(SCHEME_START=1)`; schemes: NORMAL 1, KEYBOARD 2, SCRIBBLE 3, APPLICATION_ANIMATION 4, SYSTEM_ANIMATION 5), `setDisplayScheme(SCHEME_SCRIBBLE)` or `SCHEME_APPLICATION_ANIMATION`. `isInFastMode()`, `inSystemFastMode()` report the state. Always clear the scope in `onPause` (`clearAppScopeUpdate(true)`).
4. **Queue behaviour**: `setUpdListSize(int)` (update list depth), `setAutoSyncBufEnable(bool)`, `holdDisplay(true, mode, ms)` + `waitForUpdateFinished()`, `UpdateScheme` {SNAPSHOT, QUEUE, QUEUE_AND_MERGE} used by `applySysScopeUpdate` (SDM). A small list / merge avoids the panel lagging behind fast input.
5. **Region size**: keep the dirty rect to the last segment's bounding box (+ stroke width), 8/16-px aligned; the rM2 firmware does the same (refresh_policy.md section 3).
6. **Canvas type**: Onyx's own `SurfaceViewKt.lock(SurfaceView, Rect, hardware)` uses `lockHardwareCanvas` when API allows else `lockCanvas(Rect)`; PenSurface forces a software canvas with a dirty rect for Exact mode on purpose. Measure both.
7. **Mono/dither/colour**: `enableDither(bool)`, `applyMonoLevel(int)`, `applyGammaCorrection(bool,int)`, `applyColorFilter(int)`, `enableColorCU(bool)` / `enableColorAdjust(bool)`, `applySaturation(int)`, `applyBrightness(int)`, `enableRegal/disableRegal`, `setUpRegalPlus(view)`, `enableNightMode`. These are system-wide colour pipeline switches; they are where SDK ink and normal canvas ink can diverge in darkness (firmware ink is drawn in the panel's mono pen path, canvas ink goes through dither/colour filter). Not measurable from the jars.
8. **Ghost control**: `applyGCOnce()`, `repaintEveryThing([mode])`, `refreshScreen(view, GC)` for the periodic clear (already in the app), `useGCForNewSurface(bool)`.

## 5. Experiments for the device (in priority order)

1. **Probe**: log `Device.getBoardPlatform()`, `Device.currentDevice().javaClass`, `EpdController.getMaxTouchPressure()`, and `Device.currentDevice().getStrokeParameters(0..7)` (print the arrays). If the class is not `SDMDevice`, the hidden calls are no-ops and the only option is faster refresh modes.
2. **drawScreenHandWritingBitmap**: with raw drawing open and the pen state active (`penEnabled`), call `EpdController.drawScreenHandWritingBitmap(bmp, Point(x, y))` with a small bitmap (e.g. a 200x200 pencil stroke patch) and see: returns true? appears on screen? survives pen-up / next refresh? what latency (Choreographer timestamps vs. pen event)? Try with `bmp` ARGB_8888 grey/alpha and with colour. If it works, the rendering recipe is: take the app's own PENCIL renderer output for the last segment, draw it into a small bitmap, call it from `onRawDrawingTouchPointMoveReceived`, and on `onRawDrawingTouchPointListReceived` commit to the page bitmap normally.
3. **Latency of the existing path with a better mode**: in `refreshRect(live=true)` replace `ANIMATION` with `ANIMATION_MONO` / `DU4` / `HAND_WRITING_REPAINT_MODE`, use `setViewDefaultUpdateMode` once instead of `refreshScreenRegion` per frame, and add `applyAppScopeUpdate`/`setDisplayScheme(SCHEME_SCRIBBLE)` while the pen is down. Compare the numbers already exposed by `latencyListener`.
4. **Hybrid colour match**: with Hybrid on, read the grey the SDK ink actually produces (screenshot/camera) for style 0 with colours Black / DKGRAY / 0xFF555555; same for style 4 (CHARCOAL), then pick colour+width per `PenTool` so the preview matches the rendered stroke.
5. **setStrokeParameters**: if experiment 1 returns non-empty arrays, change one element at a time and observe (width? pressure gain? grey level?).

## 6. Caveats

- Everything in section 1.1-1.2 about what firmware does with the values is inferred from method names; the firmware side (`/system/framework`, `android.onyx.*`) is not in the repo. Pulling `framework.jar`/`services.jar` from the tablet (`adb pull`) and running `javap` on `android/onyx/hardware/DeviceController` and `android/onyx/handwriting/*` would settle the signatures and argument meanings.
- `drawScreenHandWritingBitmap` returning `false` on non-SDM devices is certain; success on a given SDM firmware is not.
- The SDK version coded into the app is 1.5.4.4; newer Onyx SDKs may change these hidden methods.
