import re, sys, os, zlib, hashlib
src, out = sys.argv[1], sys.argv[2]
d = open(src,'rb').read(); seen = {}
def save(kind, off, b):
    h = hashlib.sha1(b).hexdigest()[:10]
    if h in seen: return
    seen[h] = 1
    open(f"{out}/{kind}_{off:08x}_{h}.{kind}", 'wb').write(b)
for m in re.finditer(rb"<svg", d):
    e = d.find(b"</svg>", m.start())
    if e < 0 or e - m.start() > 200000: continue
    b = d[m.start():e+6]
    if b.count(b"<svg") == 1: save("svg", m.start(), b)
for m in re.finditer(rb"\x89PNG\r\n\x1a\n", d):
    e = d.find(b"IEND\xaeB`\x82", m.start())
    if e > 0: save("png", m.start(), d[m.start():e+8])
nz = 0
for m in re.finditer(rb"\x78[\x01\x5e\x9c\xda]", d):
    try: b = zlib.decompressobj().decompress(d[m.start():m.start()+400000])
    except Exception: continue
    if b[:4] == b"\x89PNG": save("png", m.start(), b); nz += 1
    elif b"<svg" in b[:2000]: save("svg", m.start(), b); nz += 1
print("zlib-compressed icons:", nz, "unique total:", len(seen))
