"""Extract every resource of one Qt resource table (names + tree + data) by anchor name, handling raw, zlib and zstd entries."""
import re,struct,json,sys,collections,zlib,os
sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),"..","pylibs"))
import zstandard
d=open(sys.argv[1],'rb').read(); anchor=sys.argv[2]; out=sys.argv[3]
u16=lambda o:struct.unpack(">H",d[o:o+2])[0]; u32=lambda o:struct.unpack(">I",d[o:o+4])[0]
def qhash(s):
    h=0
    for c in s:
        h=((h<<4)+ord(c))&0xffffffff; h^=(h&0xf0000000)>>23; h&=0x0fffffff
    return h
def rec(q):
    L=u16(q)
    if not 1<=L<=120: return None
    try: t=d[q+6:q+6+2*L].decode("utf-16-be")
    except Exception: return None
    return (t,q+6+2*L) if qhash(t)==u32(q+2) else None
p=d.find(anchor.encode("utf-16-be"))-6
assert rec(p), "anchor not a name record"
start=p
while True:
    found=None
    for L in range(1,121):
        q=start-(6+2*L)
        r=rec(q) if q>0 else None
        if r and r[1]==start: found=q;break
    if not found: break
    start=found
N=start; q=N; names={}
while True:
    r=rec(q)
    if not r: break
    names[q-N]=r[0]; q=r[1]
print("names",len(names))
# tree entries (22 bytes): name u32, flags u16, ...; file entries: country u16, lang u16, data offset u32
good=lambda o: o>=0 and o+22<=len(d) and u32(o) in names and u32(o)!=0 and u16(o+4) in (0,1,2,4,5)
found=set()
for o in range(0,len(d)-22,2):
    if good(o) and good(o+22) and good(o+44): found.add(o)
ph=collections.Counter(o%22 for o in found).most_common(1)[0][0]
ents=[o for o in sorted(found) if o%22==ph]
files=[(u32(o),u16(o+4),u32(o+10)) for o in ents if u16(o+4)&2==0]
print("files",len(files))
# data base D: the offset where length-prefixed raw blobs line up
cands=[m.start()-4 for m in re.finditer(rb"<svg",d)]+[m.start()-4 for m in re.finditer(rb"\x89PNG\r\n\x1a\n",d)]+[m.start()-4 for m in re.finditer(rb"\x28\xb5\x2f\xfd",d)]
votes=collections.Counter()
for n,f,do in files:
    for b in cands: votes[b-do]+=1
D,c=votes.most_common(1)[0]; print("D",D,c)
os.makedirs(out,exist_ok=True); zs=zstandard.ZstdDecompressor(); got=0
for n,f,do in files:
    pos=D+do
    if pos<0 or pos+4>len(d): continue
    L=u32(pos); blob=d[pos+4:pos+4+L]
    try:
        if f&4: data=zs.decompressobj().decompress(blob)
        elif f&1: data=zlib.decompress(blob[4:])
        else: data=blob
    except Exception: continue
    name=names[n]
    ext="svg" if data[:300].lstrip().startswith((b"<svg",b"<?xml")) else "png" if data[:4]==b"\x89PNG" else "bin"
    if ext=="bin": continue
    open(f"{out}/{name}.{ext}","wb").write(data); got+=1
print("extracted",got)
