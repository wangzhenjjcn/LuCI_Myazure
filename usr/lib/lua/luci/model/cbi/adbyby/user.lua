local e=require"nixio.fs"
local a="/usr/share/adbyby/rules.txt"
f=SimpleForm("custom")
t=f:field(TextValue,"conf")
t.rmempty=true
t.rows=13
function t.cfgvalue()
return e.readfile(a)or""
end
function f.handle(i,o,t)
if o==FORM_VALID then
if t.conf then
e.writefile(a,t.conf:gsub("\r\n","\n"))
luci.sys.call("/etc/init.d/adbyby restart")
end
end
return true
end
return f
