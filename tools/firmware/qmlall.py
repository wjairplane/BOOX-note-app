"""Carve every zstd/zlib-compressed QML source out of xochitl: usage qmlall.py <xochitl> <outdir>. Files are named by offset."""
import sys, os, re, zlib, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "pylibs"))
import zstandard
d = open(sys.argv[1], "rb").read(); out = sys.argv[2]; os.makedirs(out, exist_ok=True)
MAGIC = b"\x28\xb5\x2f\xfd"
QML = re.compile(rb"^\s*(//[^\n]*\n|/\*.*?\*/\s*)*(pragma |import |[A-Z]\w+(\.\w+)* \{)", re.S)
n = 0; pos = 0
dctx = zstandard.ZstdDecompressor()
while True:
    i = d.find(MAGIC, pos)
    if i < 0: break
    pos = i + 4
    try:
        r = dctx.decompressobj().decompress(d[i:i + 4_000_000])
    except Exception:
        continue
    if len(r) > 40 and QML.match(r[:400]) and b"{" in r:
        open(os.path.join(out, f"{i:08x}.qml"), "wb").write(r); n += 1
# zlib (Qt rcc compressed entries): 4-byte size + zlib stream
for m in re.finditer(rb"\x78[\x01\x5e\x9c\xda]", d):
    i = m.start()
    try: r = zlib.decompressobj().decompress(d[i:i + 2_000_000])
    except Exception: continue
    if len(r) > 40 and QML.match(r[:400]) and b"{" in r:
        open(os.path.join(out, f"{i:08x}.z.qml"), "wb").write(r); n += 1
print(n, "files")
