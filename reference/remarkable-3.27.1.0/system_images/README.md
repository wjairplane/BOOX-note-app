# Device state screens, splash bitmaps, certification samples (3.27.1.0)

Full-screen 1404x1872 8-bit grayscale PNGs copied from `/usr/share/remarkable/`:
`starting` ("Paper tablet is loading"), `suspended` ("Paper tablet is sleeping"), `poweroff` ("Paper tablet is powered off / Hold the power button
to get started"), `rebooting` ("Paper tablet is restarting"; `restart-crashed.png` is a symlink to it), `batteryempty` ("Paper tablet is out of
battery / Charge with USB cable"), `overheating` ("Your reMarkable needs to cool down before you can use it again", device outline), `remotewipe`
(lock icon, "Remote wipe: the data on your paper tablet is being erased remotely by your employer..."), `factory` (handwritten "We designed
reMarkable to not get in your brain's way. To help you think." with logo, "Hold the power button to get started"). All are the logo at the top
centre + one or two lines of text in reMarkable Sans, no chrome.

## splash_*.png (decoded from `splash/*.dat`)
`.dat` format: 16-byte header = 4 little-endian uint32 `x, y, w, h` (a rectangle in the *native, rotated* framebuffer) followed by `w*h` bytes, one
byte per pixel with a 4-bit grey value 0..15 (15 = white; multiply by 17 for 8-bit). Verified: size = 16 + w*h for all three.
| file | x,y | w x h |
|---|---|---|
| batteryempty.dat | 1432,469 | 272x462 |
| recovery.dat | 1568,441 | 136x520 |
| splash.dat | 1568,517 | 136x367 |
Pixels are stored transposed (rotated 90deg and mirrored); the PNGs here are already corrected (`Image.transpose(TRANSVERSE)`).
Content: batteryempty "Paper tablet is out of battery / Charge with USB cable"; recovery "...is in recovery mode"; splash "Paper tablet is starting" (bootloader-time splash).
`zplash` (gzip of an 18432-byte ARM binary named `plash`) is the tiny early-boot program that draws these; not an image.

## certifications/
Only samples: `01-us.{svg,md,json}` (FCC statement text with `[modelId]`/`[fccId]` placeholders, svg = FCC mark) and `03-europe.{svg,json}` (CE).
Source dirs `rm110` (rM2) and `rm110m` have 17 regional svg+json (US, Canada (+md), Europe, Australia/NZ, Japan, India, Taiwan, Korea, Mexico, Singapore, UK, Thailand,
UAE, Saudi, Qatar, Philippines, South Africa) and are identical except the Taiwan/Korea marks; Thailand/Philippines svgs are ~0.3-0.5 MB, skipped.
