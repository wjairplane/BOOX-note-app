#!/usr/bin/env python3 -I
"""Dump reMarkable Qt .qm translations + QML qsTr call sites to JSON.

Usage: python3 -I tools/firmware/qm_dump.py [ROOTFS] [OUTDIR] [QMLDIR]
Defaults point at the scratchpad extraction / reference dir.
Output: en/de/es/fr.json  {context: {source[ || comment]: text | [plural forms]}}
        qml_strings.json  [{file, kind, context, text, line}]
Format notes (Qt 5/6 lrelease): header 16B magic; sections tag(1) len(4,BE):
 0x42 hashes, 0x69 messages, 0x2f contexts, 0x88 numerus rules, 0x96 deps, 0xa7 language.
Message record: tags 1=End 3=Translation(UTF-16BE; repeated for plurals) 6=SourceText
 7=Context 8=Comment 4=Context16(legacy) 2=SourceText16(legacy) 5/9=obsolete.
Only the messages section is needed; hash/offset sections are redundant for a dump.
"""
import sys, os, re, json, struct, glob

MAGIC = bytes([0x3c,0xb8,0x64,0x18,0xca,0xef,0x9c,0x95,0xcd,0x21,0x1c,0xbf,0x60,0xa1,0xbd,0xdd])
DEF_ROOT = "/tmp/claude-0/-home-user-BOOX-note-app/49c791b8-36e3-5584-bfb4-b5d40653e991/scratchpad/rootfs_full"
DEF_OUT = "/home/user/BOOX-note-app/reference/remarkable-3.27.1.0/strings"
DEF_QML = "/home/user/BOOX-note-app/reference/remarkable-3.27.1.0/ui/qml_all"

def parse_qm(data):
    assert data[:16] == MAGIC, "bad magic"
    i = 16; sections = {}
    while i + 5 <= len(data):
        t = data[i]; n = struct.unpack(">I", data[i+1:i+5])[0]
        sections[t] = data[i+5:i+5+n]; i += 5 + n
    msgs = []
    m = sections.get(0x69, b"")
    p = 0
    cur = dict(tr=[], src="", ctx="", cmt="")
    def u8(b): return b.decode("utf-8", "replace")
    while p < len(m):
        t = m[p]; p += 1
        if t == 1:
            msgs.append(cur); cur = dict(tr=[], src="", ctx="", cmt=""); continue
        n = struct.unpack(">I", m[p:p+4])[0]; p += 4
        if n == 0xFFFFFFFF:  # null string (untranslated; en source-language files)
            if t == 3: cur["tr"].append(None)
            continue
        b = m[p:p+n]; p += n
        if t == 3: cur["tr"].append(b.decode("utf-16-be"))
        elif t == 6: cur["src"] = u8(b)
        elif t == 7: cur["ctx"] = u8(b)
        elif t == 8: cur["cmt"] = u8(b)
        elif t == 2: cur["src"] = b.decode("utf-16-be")
        elif t == 4: cur["ctx"] = b.decode("utf-16-be")
        elif t in (5, 9): pass
        else: raise ValueError("unknown tag %d at %d" % (t, p))
    lang = sections.get(0xa7, b"").decode("utf-8", "replace")
    return lang, msgs, sections

def to_json(msgs):
    out = {}
    for m in msgs:
        key = m["src"]
        if m["cmt"]: key += " || " + m["cmt"]
        tr = [x for x in m["tr"]]
        if all(x is None for x in tr): tr = [m["src"]]  # untranslated -> source text
        tr = [m["src"] if x is None else x for x in tr]
        val = tr[0] if len(tr) == 1 else tr
        out.setdefault(m["ctx"], {})[key] = val
    return out

QS = re.compile(r'\b(qsTr|qsTrId|qsTranslate|QT_TR_NOOP|QT_TRID_NOOP|QT_TRANSLATE_NOOP)\s*\(\s*("(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\')(?:\s*,\s*("(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'))?')
def unq(s):
    s = s[1:-1]
    return re.sub(r'\\(u[0-9a-fA-F]{4}|.)', lambda m: {"n":"\n","t":"\t"}.get(m.group(1), chr(int(m.group(1)[1:],16)) if m.group(1)[0]=="u" and len(m.group(1))==5 else m.group(1)), s)

def scan_qml(d):
    res = []
    for f in sorted(glob.glob(os.path.join(d, "*.qml"))):
        txt = open(f, encoding="utf-8", errors="replace").read()
        for mm in QS.finditer(txt):
            line = txt.count("\n", 0, mm.start()) + 1
            kind, a, b = mm.group(1), unq(mm.group(2)), mm.group(3)
            if "Translate" in kind or "TRANSLATE" in kind:
                ctx, text = a, unq(b) if b else ""
            elif "Id" in kind or "ID" in kind:
                ctx, text = "", a
            else:
                ctx, text = "", a
            res.append(dict(file=os.path.basename(f), line=line, kind=kind, context=ctx, text=text))
    return res

def main():
    root = sys.argv[1] if len(sys.argv) > 1 else DEF_ROOT
    out = sys.argv[2] if len(sys.argv) > 2 else DEF_OUT
    qml = sys.argv[3] if len(sys.argv) > 3 else DEF_QML
    os.makedirs(out, exist_ok=True)
    tdir = os.path.join(root, "usr/share/remarkable/xochitl/translations")
    parsed = {}
    for lg in ("en", "de", "es", "fr"):
        parsed[lg] = parse_qm(open(os.path.join(tdir, "reMarkable_%s.qm" % lg), "rb").read())
    # reMarkable_en.qm omits many messages (English is the source language), so the
    # complete English table is the union of source texts over all four files.
    en_all = {}
    for lg in ("en", "de", "es", "fr"):
        for m in parsed[lg][1]:
            k = (m["ctx"], m["src"], m["cmt"])
            if k not in en_all:
                en_all[k] = dict(ctx=m["ctx"], src=m["src"], cmt=m["cmt"], tr=[m["src"]] * max(1, len(m["tr"])))
            elif len(m["tr"]) > len(en_all[k]["tr"]):
                en_all[k]["tr"] = [m["src"]] * len(m["tr"])
    for lg in ("en", "de", "es", "fr"):
        lang, msgs, sec = parsed[lg]
        j = to_json(list(en_all.values()) if lg == "en" else msgs)
        if lg == "en": msgs = list(en_all.values()); en_json = j
        json.dump(j, open(os.path.join(out, lg + ".json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, sort_keys=True)
        print(lg, lang, "messages:", len(msgs), "contexts:", len(j), "sections:", {hex(k): len(v) for k, v in sec.items()})
    q = scan_qml(qml)
    # carved QML files have hash names, so the qsTr context (original file name) is lost;
    # recover candidate contexts by looking the source text up in the .qm tables.
    idx = {}
    for c, d in en_json.items():
        for k in d: idx.setdefault(k.split(" || ")[0], []).append(c)
    for x in q:
        if not x["context"]:
            x["qm_contexts"] = sorted(set(idx.get(x["text"], [])))
        x["in_qm"] = bool(idx.get(x["text"]) or x["context"])
    json.dump(q, open(os.path.join(out, "qml_strings.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("qml call sites:", len(q))

if __name__ == "__main__":
    main()
