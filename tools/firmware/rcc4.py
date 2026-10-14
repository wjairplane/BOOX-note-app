import re,struct,json,sys,collections
d=open(sys.argv[1],'rb').read(); names={int(k):v for k,v in json.load(open(sys.argv[2]+".names")).items()}
u16=lambda o:struct.unpack(">H",d[o:o+2])[0]; u32=lambda o:struct.unpack(">I",d[o:o+4])[0]
good=lambda o: o>=0 and o+22<=len(d) and u32(o) in names and u32(o)!=0 and u16(o+4) in (0,1,2)
runs=[]; o=0; found=set()
for o in range(0,len(d)-22,2):
    if good(o) and good(o+22) and good(o+44): found.add(o)
ents=sorted(found); print("chain entries",len(ents))
# cluster by stride phase
phase=collections.Counter(o%22 for o in ents); print(phase.most_common(3))
ph=phase.most_common(1)[0][0]
ents=[o for o in ents if o%22==ph]
files=[(o,u32(o),u16(o+4),u16(o+6),u16(o+8),u32(o+10)) for o in ents if u16(o+4)&2==0]
print("files",len(files))
bl=sorted([m.start()-4 for m in re.finditer(rb"<svg",d)]+[m.start()-4 for m in re.finditer(rb"\x89PNG\r\n\x1a\n",d)])
bs=set(bl)
votes=collections.Counter()
for f in files:
    for b in bl: votes[b-f[5]]+=1
D,c=votes.most_common(1)[0]; print("D",D,c)
out={}
for f in files:
    b=D+f[5]
    if b in bs: out[names[f[1]]]=b
print("matched",len(out)); json.dump(out,open(sys.argv[2],"w"))
print({k:out.get(k) for k in ["ballpoint","fineliner","marker","pencil","eraser","undo","redo"]})
