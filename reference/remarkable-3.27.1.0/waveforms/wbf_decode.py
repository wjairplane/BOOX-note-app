import struct,sys,os,json,glob
MODES=["INIT","DU","GC16","GL16","GC16_REGAL","GL16_REGAL","A2","DU4"]
def o24(d,o): return d[o]|d[o+1]<<8|d[o+2]<<16
def parse(path):
    d=open(path,'rb').read()
    assert struct.unpack_from('<I',d,4)[0]==len(d)
    lot=struct.unpack_from('<H',d,0xe)[0]
    xo=o24(d,0x1c); xw=d[xo+1:xo+1+d[xo]].decode('latin1')
    mt=o24(d,0x20); flags,mc,tc,_,pad,run=d[0x24],d[0x25],d[0x26],d[0x27],d[0x28],d[0x29]
    temps=list(d[0x30:0x30+tc+2])
    mw=32 if (flags&0xc)==4 else 16
    res={'file':os.path.basename(path),'xwia':xw,'fpl_lot':lot,'flags':flags,'mode_width':mw,'temp_bounds_C':temps,'modes':{}}
    for m in range(mc+1):
        base=o24(d,mt+4*m); name=MODES[m] if m<len(MODES) else 'mode%d'%m
        row=[]
        for t in range(tc+1):
            off=o24(d,base+4*t)
            if d[off]==pad: row.append(None); continue
            n=0;i=off;inrun=True;cur=d[i];vals=[]
            while cur!=pad:
                if cur==run: inrun=not inrun
                else:
                    r=1
                    if inrun: i+=1; r=d[i]+1
                    vals.append((cur,r)); n+=r
                i+=1; cur=d[i]
            # n entries each 4 bytes => bytes=4n ; phases = 4n/1024
            nbytes=4*n
            phases=nbytes/1024
            # activity: fraction of nonzero 2-bit cells
            nz=0
            for cur,r in vals:
                f=[cur&3,(cur&0xf)>>2,(cur&0x3f)>>4,cur>>6]
                nz+=r*sum(1 for x in f if x)
            row.append({'phases':phases,'bytes':len(d[off:i]),'active_frac':round(nz/(4*n),4)})
        res['modes'][name]=row
    return res
if __name__=='__main__':
    out=[parse(f) for f in sorted(glob.glob(sys.argv[1]+'/*.wbf'))]
    json.dump(out,open(sys.argv[2],'w'),indent=1)
