# E Ink waveforms (rM2, 3.27.1.0)

Sources: `/usr/share/remarkable/waveforms.tar.gz` and the swu's `waveforms-3.27.1.0-rm2-public.tar.gz`: identical contents (86 `.wbf` files, 272-291 KB each,
unpacked only in scratch, NOT stored here). The rootfs also ships one loose default: `320_R467_AF4731_ED103TC2C6_VB3300-KCD_TC.wbf` (287027 B).
File name = `320_R<fpl lot>_AF<id>_ED103TC2<VID>_VB3300-KCD_TC.wbf`: 10.3" ED103TC2 panel, FPL lot R259..R467, TFT VID C5 (13 files), C6 (31), M1 (13), U2 (27), U3 (2).
xochitl's built-in software TCON picks the file whose `fpl_lot` (u16 @0x0E) and VID (chars 0x18-0x19 of the XWIA string) match the panel.

## Format (E Ink WBF v3.x, as used by the rM2 swtcon; layout cross-checked against timower/rM2-stuff `libs/swtcon/wbf.cpp`)
- Header 0x30 B: u32 filesize @4, u16 fpl_lot @0xE, off24 XWIA text @0x1C (length-prefixed copy of the file name), off24 mode table @0x20, flags @0x24
  (bits 3:2 == 1 -> 32x32 grey-pair LUT, true for all files = 5-bit source/target levels), modeCount-1 @0x25 (=7), tempCount-1 @0x26 (=13),
  pad/terminator byte 0xFF @0x28, RLE run-toggle byte 0xFC @0x29. off24 = 3 LE bytes + 1 checksum byte.
- Temperature table @0x30: 15 bounds (deg C) + checksum: **0,3,6,9,12,15,18,21,24,27,30,33,38,43,48** -> 14 ranges (range i = [b[i], b[i+1])). Same in all 86 files.
- mode table -> 8 modes, each -> 14 off24 pointers (one per temperature range). Mode order: **0 INIT, 1 DU, 2 GC16, 3 GL16, 4 GC16_REGAL, 5 GL16_REGAL, 6 A2, 7 DU4**.
- Each (mode,temp) blob: RLE byte stream. Byte != 0xFC: in run mode it is followed by a count byte (run = count+1); 0xFC toggles run mode; 0xFF ends. Each
  decoded byte holds 4 two-bit drive codes (0 = no drive; 1/2/3 are the voltage levels, unverified which is black/white) for 4 consecutive (from,to) pairs; one phase = 1024 pairs
  = 256 decoded bytes. Hence **phases = decoded_bytes / 1024** (values below are integral, which validates the layout).
- Drive timing: the swtcon framebuffer (260x1408 @32bpp, pixclock 28800 ps, 263 x 1554 clocks incl. blanking) gives 11.77 ms/phase = **84.96 Hz**.

## Phases per mode / temperature range (default file R467 C6); ms = phases x 11.77
| mode | 0-3 | 3-6 | 6-9 | 9-12 | 12-15 | 15-18 | 18-21 | 21-24 | 24-27 | 27-30 | 30-33 | 33-38 | 38-43 | 43-48 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| INIT | 149 | 133 | 117 | 103 | 89 | 159 | 135 | 111 | 99 | 87 | 79 | 71 | 63 | 59 |
| DU | 73 | 65 | 57 | 50 | 43 | 37 | 31 | 25 | 22 | 19 | 17 | 15 | 13 | 12 |
| GC16 | 131 | 116 | 102 | 90 | 77 | 66 | 55 | 46 | 38 | 38 | 38 | 38 | 38 | 38 |
| GL16 | 131 | 116 | 102 | 90 | 77 | 66 | 55 | 46 | 38 | 38 | 38 | 38 | 38 | 38 |
| GC16_REGAL | 131 | 116 | 102 | 90 | 77 | 66 | 55 | 46 | 38 | 38 | 38 | 38 | 38 | 38 |
| GL16_REGAL | 131 | 116 | 102 | 90 | 77 | 66 | 55 | 46 | 38 | 38 | 38 | 38 | 38 | 38 |
| A2 | 35 | 31 | 28 | 24 | 21 | 17 | 15 | 12 | 10 | 10 | 10 | 10 | 10 | 10 |
| DU4 | 84 | 75 | 65 | 58 | 49 | 42 | 35 | 29 | 24 | 24 | 24 | 24 | 24 | 24 |

Examples at 24-27 deg C (index 8): DU 22 phases = 259 ms, A2 10 = 118 ms, DU4 24 = 282 ms, GC16/GL16/REGAL 38 = 447 ms, INIT 99 = 1165 ms.
At 15-18 deg C: DU 37 = 435 ms, A2 17 = 200 ms, GC16 66 = 777 ms. At 0-3 deg C: DU 73, GC16 131 (1.5 s), A2 35.

## Findings
- Phase counts are the same for GC16, GL16, GC16_REGAL, GL16_REGAL at every temperature (only the drive content differs; REGAL = anti-ghost "regal" variants).
- Across all 86 files only INIT length varies (e.g. 99-109 phases at 24-27 deg C, 87-169 at 15-18); the other 7 modes' phase counts are identical in every lot.
  21 distinct tables in total.
- Non-zero drive density at 24-27 deg C (fraction of 2-bit cells != 0): INIT 85 %, GC16/GL16 25 %, DU4 6 %, DU 2.9 %, A2 0.5 %.
- Relative speed ordering: A2 (10) < DU (22) < DU4 (24) < GC16/GL16 (38) < INIT (99) at room temperature.

## Mapping hint for BOOX (EpdController UpdateMode, Onyx SDK) -- inference, not from firmware
- pen/ink while writing: reMarkable UI uses fast monochrome DU-class updates -> BOOX `UpdateMode.DU` (or `HAND_WRITING_REPAINT_MODE` for stroke trails); A2 equivalent -> `UpdateMode.DU`/`ANIMATION` for scrolling, page slider.
- DU4 (4-level, 24 phases) -> `GU_FAST`/`DU4`-like partial for greyscale highlights; GL16 -> `GU` (partial, low flash); GC16 -> `GC`/`REGAL` full refresh for page turns and after-erase cleanup; INIT ~ full-screen clear ("flash") -> `GC` full refresh after a number of partials.
- Timing targets from above (room temperature): A2 ~120 ms, DU ~260 ms, GC16 ~450 ms, INIT ~1.2 s.

Files: `default_R467_C6_phases.json` (table above), `all_files_phases.csv` (all 86 files x 8 modes x 14 temps), `wbf_decode.py` (parser: `python3 -I wbf_decode.py <dir> out.json`).
