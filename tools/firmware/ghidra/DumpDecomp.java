// Headless Ghidra script: decompile functions listed in a text file (one hex address per line, optional "name" after) to OUTDIR.
// Usage: analyzeHeadless PROJDIR xochitl -process xochitl -noanalysis -postScript DumpDecomp.java ADDRLIST OUTDIR
import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;
public class DumpDecomp extends GhidraScript {
  @Override public void run() throws Exception {
    String[] a = getScriptArgs();
    List<String> lines = Files.readAllLines(Paths.get(a[0]));
    File out = new File(a[1]); out.mkdirs();
    DecompInterface di = new DecompInterface(); di.openProgram(currentProgram);
    for (String ln : lines) {
      ln = ln.trim(); if (ln.isEmpty() || ln.startsWith("#")) continue;
      String[] p = ln.split("\\s+"); long addr = Long.parseLong(p[0], 16); String nm = p.length > 1 ? p[1] : String.format("f_%08x", addr);
      Address ad = toAddr(addr);
      Function f = getFunctionAt(ad);
      if (f == null) { disassemble(ad); f = createFunction(ad, null); }
      if (f == null) { println("no function at " + ad); continue; }
      DecompileResults r = di.decompileFunction(f, 120, monitor);
      String c = r.decompileCompleted() ? r.getDecompiledFunction().getC() : ("// decompile failed: " + r.getErrorMessage());
      Files.write(Paths.get(out.getPath(), String.format("%08x_%s.c", addr, nm)), c.getBytes());
      println("dumped " + ad + " " + nm);
    }
  }
}
