local a="/etc/config/wrtbwmon.user"
local o=require"nixio.fs"
local t=SimpleForm("wrtbwmon",
translate("Usage - Custom User File"),
translate("This file is used to match users with MAC addresses and it must have the following format: 00:aa:bb:cc:ee:ff,username"))
local e=t:field(Value,"_custom")
e.template="cbi/tvalue"
e.rows=20
function e.cfgvalue(e,e)
return o.readfile(a)
end
function e.write(t,t,e)
e=e:gsub("\r\n?","\n")
o.writefile(a,e)
end
return t
