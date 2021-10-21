dsp=require"luci.dispatcher"
uci=require"uci"
function policyCheck()
local e={}
uci.cursor():foreach("mwan3","policy",
function(t)
e[t[".name"]]=false
if string.len(t[".name"])>15 then
e[t[".name"]]=true
end
end
)
return e
end
function policyError(t)
local e=""
for a,o in pairs(t)do
if t[a]==true then
e=e..string.format("<strong>%s</strong><br />",
translatef("WARNING: Policy %s has exceeding the maximum name of 15 characters",a)
)
end
end
return e
end
m5=Map("mwan3",translate("MWAN - Policies"),
policyError(policyCheck()))
mwan_policy=m5:section(TypedSection,"policy",nil,
translate("Policies are profiles grouping one or more members controlling how MWAN distributes traffic<br />"..
"Member interfaces with lower metrics are used first<br />"..
"Member interfaces with the same metric will be load-balanced<br />"..
"Load-balanced member interfaces distribute more traffic out those with higher weights<br />"..
"Names may contain characters A-Z, a-z, 0-9, _ and no spaces<br />"..
"Names must be 15 characters or less<br />"..
"Policies may not share the same name as configured interfaces, members or rules"))
mwan_policy.addremove=true
mwan_policy.dynamic=false
mwan_policy.sectionhead=translate("Policy")
mwan_policy.sortable=true
mwan_policy.template="cbi/tblsection"
mwan_policy.extedit=dsp.build_url("admin","network","mwan","policy","%s")
function mwan_policy.create(t,e)
TypedSection.create(t,e)
m5.uci:save("mwan3")
luci.http.redirect(dsp.build_url("admin","network","mwan","policy",e))
end
use_member=mwan_policy:option(DummyValue,"use_member",translate("Members assigned"))
use_member.rawhtml=true
function use_member.cfgvalue(e,t)
local t,e=e.map:get(t,"use_member"),""
if t then
for a,t in pairs(t)do
e=e..t.."<br />"
end
return e
else
return"&#8212;"
end
end
last_resort=mwan_policy:option(DummyValue,"last_resort",translate("Last resort"))
last_resort.rawhtml=true
function last_resort.cfgvalue(e,t)
local e=e.map:get(t,"last_resort")
if e=="blackhole"then
return translate("blackhole (drop)")
elseif e=="default"then
return translate("default (use main routing table)")
else
return translate("unreachable (reject)")
end
end
return m5
