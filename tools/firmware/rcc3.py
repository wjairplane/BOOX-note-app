import re,struct,json,sys,collections
d=open(sys.argv[1],'rb').read()
u16=lambda o:struct.unpack(">H",d[o:o+2])[0]; u32=lambda o:struct.unpack(">I",d[o:o+4])[0]
def qhash(s):
    h=0
    for c in s:
        h=((h<<4)+ord(c))&0xffffffff; h^=(h&0xf0000000)>>23; h&=0x0fffffff
    return h
# name records: scan every even offset for a valid record
recs={}
for m in re.finditer(rb"\x00[a-zA-Z0-9_.\-]",d):
    pass
# faster: walk from each occurrence of a utf16 'fineliner_tip' back to its record, then walk the table contiguously
p=d.find("fineliner_tip".encode("utf-16-be"))-6
def rec(q):
    L=u16(q)
    if not 1<=L<=80: return None
    s=d[q+6:q+6+2*L]
    try: t=s.decode("utf-16-be")
    except Exception: return None
    return (t,q+6+2*L) if qhash(t)==u32(q+2) else None
# go backwards: find table start by trying to parse forward from candidate starts
start=p
while True:
    # find previous record end == start: try all L
    found=None
    for L in range(1,81):
        q=start-(6+2*L)
        r=rec(q) if q>0 else None
        if r and r[1]==start: found=q;break
    if not found: break
    start=found
N=start
q=N; names={}
while True:
    r=rec(q)
    if not r: break
    names[q-N]=r[0]; q=r[1]
print("names",len(names),"N",N)
json.dump(names,open(sys.argv[2]+".names","w"))
# file entries
svgpos={m.start()-4:m.start() for m in re.finditer(rb"<svg",d)}
pngpos=[m.start()-4 for m in re.finditer(rb"\x89PNG\r\n\x1a\n",d)]
blobs=set(svgpos)|set(pngpos)
cand=[]
for o in range(0,len(d)-22,2):
    n=u32(o)
    if n in names and u16(o+4) in (0,1,4,5):
        cand.append((o,n,u32(o+10)))
print("entries",len(cand))
votes=collections.Counter()
for o,n,do in cand:
    for b in list(blobs)[:0]: pass
# vote D: for each entry, D = blobpos - do for each blob would be O(n*m); restrict by checking that D candidates align
bl=sorted(blobs)
for o,n,do in cand:
    for b in bl:
        votes[b-do]+=1
D,c=votes.most_common(1)[0]; print("D",D,"votes",c)
out={}
for o,n,do in cand:
    b=D+do
    if b in blobs: out[names[n]]=b
json.dump(out,open(sys.argv[2],"w")); print("matched",len(out))
