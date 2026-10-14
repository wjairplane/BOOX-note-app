import sys, os
src, dst = sys.argv[1], os.path.realpath(sys.argv[2])
d = open(src, 'rb').read(); p = 0
while True:
    assert d[p:p+6] in (b'070701', b'070702'), 'bad magic'
    f = [int(d[p+6+8*i:p+14+8*i], 16) for i in range(13)]
    size, nl = f[6], f[11]
    name = d[p+110:p+110+nl-1].decode(); p = (p+110+nl+3) & ~3
    if name == 'TRAILER!!!': break
    data = d[p:p+size]; p = (p+size+3) & ~3
    out = os.path.realpath(os.path.join(dst, name))
    if not out.startswith(dst + os.sep) or (f[1] & 0o170000) != 0o100000:
        print('skip', name); continue
    open(out, 'wb').write(data); print(name, size)
