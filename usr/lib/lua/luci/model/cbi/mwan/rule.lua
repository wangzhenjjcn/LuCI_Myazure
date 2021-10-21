dsp=require"luci.dispatcher"
uci=require"uci"
function ruleCheck()
local t={}
uci.cursor():foreach("mwan3","rule",
function(e)
t[e[".name"]]=false
local a=uci.cursor(nil,"/var/state")
local i=a:get("mwan3",e[".name"],"src_port")
local o=a:get("mwan3",e[".name"],"dest_port")
if i~=nil or o~=nil then
local a=a:get("mwan3",e[".name"],"proto")
if a==nil or a=="all"then
t[e[".name"]]=true
end
end
end
)
return t
end
function ruleWarn(a)
local e=""
for t,o in pairs(a)do
if a[t]==true then
e=e..string.format("<strong>%s</strong><br />",
translatef("WARNING: Rule %s have a port configured with no or improper protocol specified!",t)
)
end
end
return e
end
m5=Map("mwan3",translate("MWAN - Rules"),
ruleWarn(ruleCheck())
)
mwan_rule=m5:section(TypedSection,"rule",nil,
translate("Rules specify which traffic will use a particular MWAN policy<br />"..
"Rules are based on IP address, port or protocol<br />"..
"Rules are matched from top to bottom<br />"..
"Rules below a matching rule are ignored<br />"..
"Traffic not matching any rule is routed using the main routing table<br />"..
"Traffic destined for known (other than default) networks is handled by the main routing table<br />"..
"Traffic matching a rule, but all WAN interfaces for that policy are down will be blackholed<br />"..
"Names may contain characters A-Z, a-z, 0-9, _ and no spaces<br />"..
"Rules may not share the same name as configured interfaces, members or policies"))
mwan_rule.addremove=true
mwan_rule.anonymous=false
mwan_rule.dynamic=false
mwan_rule.sectionhead=translate("Rule")
mwan_rule.sortable=true
mwan_rule.template="cbi/tblsection"
mwan_rule.extedit=dsp.build_url("admin","network","mwan","rule","%s")
function mwan_rule.create(t,e)
TypedSection.create(t,e)
m5.uci:save("mwan3")
luci.http.redirect(dsp.build_url("admin","network","mwan","rule",e))
end
src_ip=mwan_rule:option(DummyValue,"src_ip",translate("Source address"))
src_ip.rawhtml=true
function src_ip.cfgvalue(t,e)
return t.map:get(e,"src_ip")or"&#8212;"
end
src_port=mwan_rule:option(DummyValue,"src_port",translate("Source port"))
src_port.rawhtml=true
function src_port.cfgvalue(t,e)
return t.map:get(e,"src_port")or"&#8212;"
end
dest_ip=mwan_rule:option(DummyValue,"dest_ip",translate("Destination address"))
dest_ip.rawhtml=true
function dest_ip.cfgvalue(t,e)
return t.map:get(e,"dest_ip")or"&#8212;"
end
dest_port=mwan_rule:option(DummyValue,"dest_port",translate("Destination port"))
dest_port.rawhtml=true
function dest_port.cfgvalue(e,t)
return e.map:get(t,"dest_port")or"&#8212;"
end
proto=mwan_rule:option(DummyValue,"proto",translate("Protocol"))
proto.rawhtml=true
function proto.cfgvalue(t,e)
return t.map:get(e,"proto")or"all"
end
use_policy=mwan_rule:option(DummyValue,"use_policy",translate("Policy assigned"))
use_policy.rawhtml=true
function use_policy.cfgvalue(t,e)
return t.map:get(e,"use_policy")or"&#8212;"
end
return m5
