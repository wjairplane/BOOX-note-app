"""Helpers to explore xochitl (ELF32 ARM, non-PIE ET_EXEC): vaddr<->offset, RTTI->vtable lookup, capstone disassembly (ARM/Thumb)."""
import sys, struct, re, os, bisect
PYLIBS = os.environ.get("PYLIBS", "/tmp/claude-0/-home-user-BOOX-note-app/49c791b8-36e3-5584-bfb4-b5d40653e991/scratchpad/pylibs")
sys.path.insert(0, PYLIBS)
from capstone import *
from capstone.arm import *
XO = os.environ.get("XOCHITL", "/tmp/claude-0/-home-user-BOOX-note-app/49c791b8-36e3-5584-bfb4-b5d40653e991/scratchpad/rootfs_out/xochitl")
D = open(XO, 'rb').read()
# (vaddr_start, file_off, size)
SEGS = [(0x10000, 0, 0x1377010), (0x1388a70, 0x1377a70, 0x1b538)]
def v2o(v):
    for a, o, s in SEGS:
        if a <= v < a + s: return v - a + o
    raise ValueError(hex(v))
def o2v(o):
    for a, fo, s in SEGS:
        if fo <= o < fo + s: return o - fo + a
    raise ValueError(hex(o))
def u32(v): o = v2o(v); return struct.unpack("<I", D[o:o+4])[0]
def f32(v): o = v2o(v); return struct.unpack("<f", D[o:o+4])[0]
def cstr(v, n=200):
    o = v2o(v); e = D.index(b"\0", o); return D[o:e].decode("latin1")
TEXT = (0x54080, 0x54080 + 0xc4fde4)
RODATA = (0xca3e70, 0xca3e70 + 0x657a90)
def find_all(b):
    i = 0
    while True:
        i = D.find(b, i)
        if i < 0: return
        yield i; i += 1
def words_eq(val, lo=RODATA[0], hi=RODATA[1]):
    """addresses (aligned) in [lo,hi) whose u32 == val"""
    b = struct.pack("<I", val); res = []
    for o in find_all(b):
        if o % 4: continue
        try: v = o2v(o)
        except ValueError: continue
        res.append(v)
    return res
def rtti(name):
    """name e.g. 'N8strokev214PencilPipelineE' -> (name_addr, typeinfo_addrs, vtables)"""
    out = []
    for o in find_all(name.encode() + b"\0"):
        na = o2v(o)
        tis = [a - 4 for a in words_eq(na)]
        for ti in tis:
            vts = [a - 4 for a in words_eq(ti)]  # slot 1 holds typeinfo; vtable start = slot-4 (offset-to-top)
            out.append((na, ti, vts))
    return out
def vtable_entries(vt, n=40):
    return [u32(vt + 8 + 4 * i) for i in range(n)]
cs_arm = Cs(CS_ARCH_ARM, CS_MODE_ARM); cs_arm.detail = False
cs_thb = Cs(CS_ARCH_ARM, CS_MODE_THUMB); cs_thb.detail = False
cs_arm.skipdata = True; cs_thb.skipdata = True
def disasm(addr, size=None, count=None, thumb=None):
    """addr: with bit0 set => thumb. returns list of (addr, mnemonic, ops)"""
    if thumb is None: thumb = bool(addr & 1)
    a = addr & ~1
    cs = cs_thb if thumb else cs_arm
    if size is None: size = 0x2000
    o = v2o(a)
    res = []
    for i in cs.disasm(D[o:o+size], a):
        res.append((i.address, i.mnemonic, i.op_str))
        if count and len(res) >= count: break
    return res
def show(addr, size=0x200, thumb=None, annotate=True):
    for a, m, o in disasm(addr, size, thumb=thumb):
        extra = ""
        if annotate:
            mm = re.search(r"\[pc, #(0x[0-9a-f]+|\d+)\]", o)
            if mm and (m.startswith("ldr") or m.startswith("vldr")):
                off = int(mm.group(1), 0); la = (a + 8 + off) if not (thumb if thumb is not None else bool(addr & 1)) else (((a + 4) & ~3) + off)
                try:
                    v = u32(la); extra = f"   ; [{la:x}]={v:#x} f={struct.unpack('<f',struct.pack('<I',v))[0]:.6g}"
                    if RODATA[0] <= v < RODATA[1]:
                        try:
                            s = cstr(v); 
                            if all(32 <= ord(c) < 127 for c in s[:40]) and len(s) > 2: extra += f' "{s[:60]}"'
                        except Exception: pass
                except Exception: pass
        print(f"{a:08x}: {m:8s} {o}{extra}")
if __name__ == "__main__":
    for r in rtti(sys.argv[1]): print([hex(x) if not isinstance(x, list) else [hex(y) for y in x] for x in r])
