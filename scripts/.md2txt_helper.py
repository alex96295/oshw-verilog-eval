import sys, importlib.util, importlib.machinery
loader = importlib.machinery.SourceFileLoader("specgen", "scripts/spec-gen")
spec = importlib.util.spec_from_loader("specgen", loader)
m = importlib.util.module_from_spec(spec)
try:
    loader.exec_module(m)
    md_to_txt = m.md_to_txt
except Exception as e:
    import re
    def md_to_txt(md):
        txt = md
        txt = re.sub(r"```[\s\S]*?```", lambda mm: re.sub(r"^```.*\n|\n```$","",mm.group(0),flags=re.M), txt)
        txt = re.sub(r"^#{1,6}\s*","",txt,flags=re.M)
        txt = txt.replace("**","").replace("*","")
        txt = txt.replace("`","")
        txt = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r"\1 (\2)", txt)
        txt = txt.replace("|"," ")
        txt = re.sub(r"^\s*>\s?","",txt,flags=re.M)
        txt = re.sub(r"\n{3,}","\n\n",txt).strip()
        return txt
md = open(sys.argv[1]).read()
out = md_to_txt(md)
open(sys.argv[2],"w").write(out + ("" if out.endswith("\n") else "\n"))
print("OK", sys.argv[2])
