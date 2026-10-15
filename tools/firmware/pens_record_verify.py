"""Compare pens_record_port.record() with the firmware recorder (pens_recorder.Recorder) on random samples for all tools. Run: python3 -I pens_record_verify.py"""
import sys; sys.path.insert(0,'/home/user/BOOX-note-app/tools/firmware')
from pens_recorder import Recorder
from pens_record_port import record
import random, math
rng=random.Random(11)
def samples(n,sc=1.0):
    x,y=100,100; out=[]
    for i in range(n):
        x+=rng.uniform(-6,9)*sc; y+=rng.uniform(-6,9)*sc
        out.append((x,y,rng.random(),rng.uniform(-1.1,1.1),rng.uniform(-1.1,1.1)))
    return out
allbad=0
for tool in (0,12,1,2,3,4,17,5,18,6,22,7,8,10,11,13,14,15,16,19,20,21,23):
    bad={}; tot=0
    for T in (0.5,1.0,1.5,2.0,3.0):
        for flagA in (0,1):
            for style in (0,1):
                for hand in (0,1):
                    S=samples(25,rng.choice([0.2,1,4]))
                    r=Recorder(tool,T,style=style)
                    zoom=rng.choice([1.0,1.0,2.0]); rot=rng.choice([0,90,180])
                    for s in S: r.add(*s,hand=hand,zoom=zoom,rot_deg=rot,flag=flagA)
                    o=r.points(); m=record(tool,T,S,zoom=zoom,rot_deg=rot,hand=hand,style=style,flagA=flagA)
                    for a,b in zip(o,m):
                        tot+=1
                        for k in ('speed','width','direction','pressure'):
                            if a[k]!=b[k]:
                                bad[k]=bad.get(k,0)+1
                                if bad[k]<=1: print('  ',tool,T,flagA,style,hand,k,a[k],b[k])
    allbad+=sum(bad.values())
    print(tool,'mismatch',bad,'/',tot)
print('total bad',allbad)
