"""Oracle for the RECORDING side: runs xochitl's LineBuilder::addSample (0xb63490; new-style tools via 0xb62de4) under Unicorn.
rec = Recorder(tool, thickness); rec.add(x, y, pressure01, tiltX_rad, tiltY_rad, zoom=1.0, rot_deg=0.0, hand=0) -> appends one 14-byte point;
rec.points() -> [dict(x,y,speed_raw,width_raw,direction_raw,pressure_raw)]"""
import sys, struct
sys.path.insert(0, "/home/user/BOOX-note-app/tools/firmware")
import pens_emu
from pens_emu import *
class Recorder:
    def __init__(self, tool, thickness=1.0, style=0):
        e = self.e = pens_emu.Emu(64, 64, 32)
        self.B = e.alloc(0x400)
        e.w32(self.B, tool); e.wd(self.B + 8, thickness); e.uc.mem_write(self.B + 0x88, bytes([style]))
        self.buf = e.alloc(14 * 8192)
        e.w32(self.B + 0x50, self.buf); e.w32(self.B + 0x54, 0)
        e.w32(self.B + 0x40, tool)                  # embedded Line.tool (used by Line::maxWidth)
        e.wd(self.B + 0x58, thickness)             # the embedded Line (at +0x40) keeps its own thickness double at +0x18
        self.sample = e.alloc(64)
        e.uc.hook_add(UC_HOOK_CODE, self._push, begin=0xb6072c, end=0xb6072c + 4)
    def _push(self, uc, a, s, u):
        line = uc.reg_read(UC_ARM_REG_R0); pt = uc.reg_read(UC_ARM_REG_R1)
        n = self.e.r32(line + 0x14)
        uc.mem_write(self.buf + 14 * n, bytes(uc.mem_read(pt, 14)))
        self.e.w32(line + 0x14, n + 1)
        self.e._ret()
    def add(self, x, y, pressure, tx=0.0, ty=0.0, zoom=1.0, rot_deg=0.0, hand=0, flag=0):
        e = self.e
        for i, v in enumerate((x, y, pressure, tx, ty)): e.wf(self.sample + 4 * i, v)
        e.call(0xb63490, [self.B, self.sample, flag, hand], fargs=[zoom, rot_deg])
    def points(self):
        n = self.e.r32(self.B + 0x54); out = []
        for i in range(n):
            x, y, sp, w, d, p = struct.unpack("<ffHHBB", bytes(self.e.uc.mem_read(self.buf + 14 * i, 14)))
            out.append(dict(x=x, y=y, speed=sp, width=w, direction=d, pressure=p))
        return out
if __name__ == "__main__":
    import math
    for tool, T in ((15, 2.0), (14, 2.0), (16, 2.0), (4, 2.0), (17, 2.0), (18, 1.0), (21, 2.0), (23, 2.0), (13, 3.0), (12, 2.0)):
        r = Recorder(tool, T)
        for i in range(8):
            r.add(100 + i * 6.0, 100 + math.sin(i / 2) * 5, 0.2 + 0.1 * i, 0.3, 0.1)
        print(tool, T, [(p["width"] / 4, p["pressure"], p["speed"], p["direction"]) for p in r.points()][:6])
