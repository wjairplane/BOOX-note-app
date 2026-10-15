"""Unicorn harness that runs xochitl's stroke::v2 pen code (ARM, VFP/NEON) with stubbed libc/Qt PLT calls.
Usage: import pens_emu; e=Emu(); e.call(addr,[args])"""
import sys, struct, pickle, os, math
sys.path.insert(0, "/home/user/BOOX-note-app/tools/firmware")
from pens_lib import *
from unicorn import *
from unicorn.arm_const import *
HERE = os.environ.get("PENS_SCRATCH", "/tmp/claude-0/-home-user-BOOX-note-app/49c791b8-36e3-5584-bfb4-b5d40653e991/scratchpad")
PLT = pickle.load(open(os.path.join(HERE, "plt.pkl"), "rb"))
HEAP = 0x20000000; STACK = 0x7e000000; STACK_SZ = 0x400000
def _cf(f):
    return lambda *a: float(f(*a))
MATH1F = {"sqrtf": math.sqrt, "sinf": math.sin, "cosf": math.cos, "tanf": math.tan, "atanf": math.atan, "floorf": math.floor,
          "ceilf": math.ceil, "fabsf": abs, "expf": math.exp, "logf": math.log, "roundf": lambda x: math.floor(x + 0.5) if x >= 0 else -math.floor(-x + 0.5),
          "truncf": math.trunc, "acosf": math.acos, "asinf": math.asin}
MATH2F = {"atan2f": math.atan2, "powf": math.pow, "fmodf": math.fmod, "hypotf": math.hypot}
MATH1D = {"ceil": math.ceil, "floor": math.floor, "sqrt": math.sqrt, "sin": math.sin, "cos": math.cos, "round": lambda x: float(math.floor(x + 0.5)) if x >= 0 else -float(math.floor(-x + 0.5)), "fabs": abs, "exp": math.exp, "log": math.log, "trunc": math.trunc}
class Emu:
    def __init__(self, W=256, H=256, depth=32):
        self.uc = uc = Uc(UC_ARCH_ARM, UC_MODE_ARM)
        uc.mem_map(0x10000, 0x1388000 - 0x10000)
        uc.mem_write(0x10000, D[0:0x1377010])
        uc.mem_map(0x1388000, 0x30000)
        uc.mem_write(0x1388a70, D[0x1377a70:0x1377a70 + 0x1b538])
        uc.mem_map(HEAP, 0x10000000); uc.mem_map(STACK, STACK_SZ)
        self.brk = HEAP + 0x1000
        # enable VFP/NEON
        uc.reg_write(UC_ARM_REG_C1_C0_2, 0xf00000)
        uc.reg_write(UC_ARM_REG_FPEXC, 0x40000000)
        self.W, self.H, self.depth = W, H, depth
        self.bpl = W * depth // 8
        self.fb = self.alloc(self.bpl * H)
        self.img = self.alloc(64)   # fake QImage object
        self.xform = [1, 0, 0, 0, 1, 0, 0, 0, 1]  # m11 m12 m13 m21 m22 m23 m31 m32 m33
        self.log = []
        self.zero = self.alloc(256)
        uc.hook_add(UC_HOOK_CODE, self._plt_hook, begin=0x4b080, end=0x4b080 + 0x8ffc)
        uc.hook_add(UC_HOOK_CODE, self._fn_hook, begin=0xb6618c, end=0xb6618c + 4)
        self._color_h = uc.hook_add(UC_HOOK_CODE, self._color_hook, begin=0x14cea0, end=0x14cea0 + 4)
        self.color_fn = lambda tool, color, argb: argb
        self.trace_plt = False
        self.unknown = set()
    # ---- memory helpers
    def alloc(self, n):
        n = (n + 15) & ~15
        a = self.brk; self.brk += n + 16
        return a
    def w32(self, a, v): self.uc.mem_write(a, struct.pack("<I", v & 0xffffffff))
    def r32(self, a): return struct.unpack("<I", bytes(self.uc.mem_read(a, 4)))[0]
    def wf(self, a, v): self.uc.mem_write(a, struct.pack("<f", v))
    def rf(self, a): return struct.unpack("<f", bytes(self.uc.mem_read(a, 4)))[0]
    def wd(self, a, v): self.uc.mem_write(a, struct.pack("<d", v))
    def rd(self, a): return struct.unpack("<d", bytes(self.uc.mem_read(a, 8)))[0]
    def reg(self, r): return self.uc.reg_read(r)
    def cstr(self, a):
        s = b""
        while True:
            c = bytes(self.uc.mem_read(a, 1))
            if c == b"\0": return s.decode("latin1")
            s += c; a += 1
    # ---- hooks
    def _ret(self, r0=None):
        uc = self.uc
        if r0 is not None: uc.reg_write(UC_ARM_REG_R0, r0 & 0xffffffff)
        uc.reg_write(UC_ARM_REG_PC, uc.reg_read(UC_ARM_REG_LR))
    def _fn_hook(self, uc, addr, size, ud):   # 0xb6618c: log-config accessor -> pointer to zeroed block
        self._ret(self.zero)
    def _color_hook(self, uc, addr, size, ud):
        r = [uc.reg_read(x) for x in (UC_ARM_REG_R0, UC_ARM_REG_R1, UC_ARM_REG_R2, UC_ARM_REG_R3)]
        self._ret(self.color_fn(r[1], r[2], r[3]))
    def _plt_hook(self, uc, addr, size, ud):
        name = PLT.get(addr)
        if name is None: return
        R = lambda i: uc.reg_read(UC_ARM_REG_R0 + i)
        if self.trace_plt: print("plt", name, hex(R(0)), hex(R(1)), hex(R(2)))
        if name in ("_Znwj", "malloc", "_Znaj"):
            self._ret(self.alloc(R(0)))
        elif name == "calloc": self._ret(self.alloc(R(0) * R(1)))
        elif name in ("_ZdlPvj", "free", "_ZdlPv", "_ZdaPv", "_ZdaPvj"): self._ret(0)
        elif name == "memset":
            uc.mem_write(R(0), bytes([R(1) & 0xff]) * R(2)); self._ret(R(0))
        elif name in ("memcpy", "memmove"):
            n = R(2)
            if n: uc.mem_write(R(0), bytes(uc.mem_read(R(1), n)))
            self._ret(R(0))
        elif name == "sincosf":
            a = struct.unpack("<f", struct.pack("<I", uc.reg_read(UC_ARM_REG_S0)))[0]
            self.wf(R(0), math.sin(a)); self.wf(R(1), math.cos(a)); self._ret(0)
        elif name == "_ZNK6QImage4bitsEv" or name == "_ZN6QImage4bitsEv" or name == "_ZNK6QImage9constBitsEv": self._ret(self.fb)
        elif name == "_ZNK6QImage5widthEv": self._ret(self.W)
        elif name == "_ZNK6QImage6heightEv": self._ret(self.H)
        elif name == "_ZNK6QImage5depthEv": self._ret(self.depth)
        elif name == "_ZNK6QImage12bytesPerLineEv": self._ret(self.bpl)
        elif name == "_ZN6QImage6detachEv": self._ret(0)
        elif name == "_ZNK6QImage6isNullEv": self._ret(0)
        elif name == "_ZNK7QRegion7isEmptyEv": self._ret(0)
        elif name in ("_ZN7QRegionC1Ev", "_ZN7QRegionC1ERKS_"):
            self.w32(R(0), 0); self._ret(R(0))
        elif name == "_ZN7QRegionD1Ev": self._ret(0)
        elif name == "_ZNK10QTransform3mapERK7QPointF":
            x = self.rd(R(1)); y = self.rd(R(1) + 8)
            m = [self.rd(R(0) + 8 * i) for i in range(9)]
            w = m[2] * x + m[5] * y + m[8]
            xr = m[0] * x + m[3] * y + m[6]; yr = m[1] * x + m[4] * y + m[7]
            if w != 1 and w != 0: xr /= w; yr /= w
            uc.reg_write(UC_ARM_REG_D0, struct.unpack("<Q", struct.pack("<d", xr))[0])
            uc.reg_write(UC_ARM_REG_D1, struct.unpack("<Q", struct.pack("<d", yr))[0])
            self._ret()
        elif name in MATH1F or name in MATH2F or name in MATH1D:
            gf = lambda r: struct.unpack("<f", struct.pack("<I", uc.reg_read(r)))[0]
            gd = lambda r: struct.unpack("<d", struct.pack("<Q", uc.reg_read(r)))[0]
            if name in MATH1F:
                uc.reg_write(UC_ARM_REG_S0, struct.unpack("<I", struct.pack("<f", MATH1F[name](gf(UC_ARM_REG_S0))))[0])
            elif name in MATH2F:
                uc.reg_write(UC_ARM_REG_S0, struct.unpack("<I", struct.pack("<f", MATH2F[name](gf(UC_ARM_REG_S0), gf(UC_ARM_REG_S1))))[0])
            else:
                uc.reg_write(UC_ARM_REG_D0, struct.unpack("<Q", struct.pack("<d", MATH1D[name](gd(UC_ARM_REG_D0))))[0])
            self._ret()
        elif name == "_ZNK7QRegion5beginEv":
            if not hasattr(self, "_rects"):
                self._rects = self.alloc(64)
                for i, v in enumerate((0, 0, self.W - 1, self.H - 1)): self.w32(self._rects + 4 * i, v)
            self._ret(self._rects)
        elif name == "_ZNK7QRegion3endEv":
            self.call_end = True
            if not hasattr(self, "_rects"):
                self._rects = self.alloc(64)
                for i, v in enumerate((0, 0, self.W - 1, self.H - 1)): self.w32(self._rects + 4 * i, v)
            self._ret(self._rects + 16)
        elif name == "__cxa_guard_acquire":
            self._ret(1)          # run function-local static initialisers (e.g. the SHADING_NORMAL_BLEND env lookup)
        elif name.startswith("_Z27qEnvironmentVariableIsEmpty"):
            self._ret(1)          # env vars (e.g. SHADING_NORMAL_BLEND) are unset on a real device
        elif name in ("_ZN7QRegionaSERKS_",):
            self._ret(R(0))
        else:
            self.unknown.add(name); self._ret(0)
    def call(self, addr, args=(), stack=(), maxins=200_000_000, fargs=None):
        uc = self.uc
        sp = STACK + STACK_SZ - 0x1000
        st = list(stack)
        sp -= 4 * len(st); sp &= ~7
        for i, v in enumerate(st): self.w32(sp + 4 * i, v)
        for i, v in enumerate(args[:4]): uc.reg_write(UC_ARM_REG_R0 + i, v & 0xffffffff)
        if fargs:
            for i, v in enumerate(fargs):
                uc.reg_write(UC_ARM_REG_S0 + i, struct.unpack("<I", struct.pack("<f", v))[0])
        uc.reg_write(UC_ARM_REG_SP, sp)
        RET = 0x20000000 + 0xff000   # sentinel
        uc.reg_write(UC_ARM_REG_LR, RET)
        uc.emu_start(addr, RET, count=maxins)
        return uc.reg_read(UC_ARM_REG_R0)

    def use_real_palette(self, mode):
        """Run the firmware's own colour function (0x14cea0) instead of the stub; mode = word at renderer+0x18 (1 = grayscale conversion)."""
        self.uc.hook_del(self._color_h); self.palette_mode = mode
        self.w32(self.renderer + 0x18, mode)
    def make_renderer(self, scale=1.0, xform=None, flag_extra=0):
        """Build the render context ("config") like 0xb66218 does and run the StrokeRenderer ctor (0xb7f438)."""
        C = self.alloc(0x100)
        m = xform or [1, 0, 0, 0, 1, 0, 0, 0, 1]
        self.wf(C, scale)
        for i, v in enumerate(m): self.wd(C + 8 + 8 * i, v)
        for i, v in enumerate((0, 0, self.W - 1, self.H - 1)): self.w32(C + 0x58 + 4 * i, v)
        self.w32(C + 0x68, 0)
        self.uc.mem_write(C + 0x6c, bytes([flag_extra, 1]))
        for i, v in enumerate((self.img, self.fb, self.W, self.H, self.depth, self.bpl)): self.w32(C + 0x70 + 4 * i, v)
        self.holder = self.alloc(16)
        self.call(0xb7f438, [self.holder, C])
        self.renderer = self.r32(self.holder)
        return self.renderer
    def make_line(self, tool, color, points, thickness_scale=0.0, argb=0, thickness=1.0):
        """points: list of dict(x,y,speed,width,direction,pressure) in raw file units (width raw = width*4 for u16)."""
        L = self.alloc(0x40); P = self.alloc(14 * len(points) + 16)
        for i, p in enumerate(points):
            self.uc.mem_write(P + 14 * i, struct.pack("<ffHHBB", p["x"], p["y"], p["speed"], p["width"], p["direction"], p["pressure"]))
        self.w32(L, tool); self.w32(L + 4, color); self.w32(L + 8, argb)
        self.w32(L + 0x10, P); self.w32(L + 0x14, len(points)); self.wd(L + 0x18, thickness)           # double thickness_scale (only used by legacy max-width / bounds code)
        self.wf(L + 0x20, thickness_scale)     # float starting_length (NOT thickness!): initial path length of the texture phase
        return L
