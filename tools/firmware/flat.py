import re,sys
def flat(path):
    out=[];stack=[]
    for line in open(path,encoding="utf8"):
        m=re.match(r"\s*property var (\w+): (?:QtObject|Type) \{",line)
        if m: stack.append(m.group(1)); continue
        m=re.match(r"\s*property \w+ (\w+) ?: ?(.*)$",line)
        if m:
            v=m.group(2).strip()
            c=re.search(r'Qt\.color\("(#[0-9a-fA-F]+)"\)\)? ?$|: Qt\.color\("(#\w+)"\)',v)
            col=re.findall(r'Qt\.color\("(#\w+)"\)',v)
            out.append((".".join(stack+[m.group(1)]), col[-1] if col else v.strip('"')))
            continue
        if re.match(r"\s*\}\s*$",line) and stack: stack.pop()
    return out
for p in sys.argv[1:]:
    print("##",p)
    for k,v in flat(p): print(f"  {k} = {v}")
