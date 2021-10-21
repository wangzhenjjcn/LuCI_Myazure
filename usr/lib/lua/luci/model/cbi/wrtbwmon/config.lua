local t=Map("wrtbwmon",translate("Details"))
local e=t:section(NamedSection,"general","wrtbwmon",translate("General settings"))
local e=e:option(Flag,"persist",translate("Persist database"),
translate("Check this to persist the database file"))
e.rmempty=false
function e.write(t,a,e)
if e=='1'then
luci.sys.call("mv /tmp/usage.db /etc/config/usage.db")
elseif e=='0'then
luci.sys.call("mv /etc/config/usage.db /tmp/usage.db")
end
return Flag.write(t,a,e)
end
return t
