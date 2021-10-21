local e=require"nixio.fs"
local a="/tmp/zero.info"
f=SimpleForm("logview")
t=f:field(TextValue,"conf")
t.rmempty=true
t.rows=15
function t.cfgvalue()
luci.sys.exec("ifconfig $(ifconfig | grep zt | awk '{print $1}') > /tmp/zero.info")
return e.readfile(a)or""
end
t.readonly="readonly"
return f