dsp=require"luci.dispatcher"
uci=require"uci"
function interfaceWarnings(a,o,t)
local e=""
if o<=t then
e=string.format("<strong>%s</strong><br />",
translatef("There are currently %d of %d supported interfaces configured",o,t)
)
else
e=string.format("<strong>%s</strong><br />",
translatef("WARNING: %d interfaces are configured exceeding the maximum of %d!",o,t)
)
end
for t,o in pairs(a)do
if a[t]["network"]==false then
e=e..string.format("<strong>%s</strong><br />",
translatef("WARNING: Interface %s are not found in /etc/config/network",t)
)
end
if a[t]["default_route"]==false then
e=e..string.format("<strong>%s</strong><br />",
translatef("WARNING: Interface %s has no default route in the main routing table",t)
)
end
if a[t]["reliability"]==false then
e=e..string.format("<strong>%s</strong><br />",
translatef("WARNING: Interface %s has a higher reliability "..
"requirement than tracking hosts (%d)",t,a[t]["tracking"])
)
end
if a[t]["duplicate_metric"]==true then
e=e..string.format("<strong>%s</strong><br />",
translatef("WARNING: Interface %s has a duplicate metric %s configured",t,a[t]["metric"])
)
end
end
return e
end
function configCheck()
local t={}
local i=0
local o={}
uci.cursor():foreach("mwan3","interface",
function(e)
local a=uci.cursor(nil,"/var/state")
local e=e[".name"]
t[e]={}
i=i+1
local i=a:get("network",e)
t[e]["network"]=false
if i~=nil then
t[e]["network"]=true
local i=a:get("network",e,"ifname")
if i~=nil then
t[e]["device"]=i
end
local a=a:get("network",e,"metric")
if a~=nil then
t[e]["metric"]=a
t[e]["duplicate_metric"]=false
for i,o in ipairs(o)do
if o==a then
t[e]["duplicate_metric"]=true
end
end
table.insert(o,a)
end
local a=require("luci.util").ubus("network.interface.%s"%e,"status",{})
t[e]["default_route"]=false
if a and a.route then
local o,o
for o,i in ipairs(a.route)do
if a.route[o].target=="0.0.0.0"then
t[e]["default_route"]=true
end
end
end
end
local o=a:get("mwan3",e,"track_ip")
t[e]["tracking"]=0
if o and#o>0 then
t[e]["tracking"]=#o
t[e]["reliability"]=false
local a=tonumber(a:get("mwan3",e,"reliability"))
if a and a<=#o then
t[e]["reliability"]=true
end
end
end
)
function bit(e)
return 2^(e-1)
end
function hasbit(t,e)
return t%(e+e)>=e
end
function setbit(e,t)
return hasbit(e,t)and e or e+t
end
local e=require("uci").cursor(nil,"/var/state")
local e=e:get("mwan3","globals","mmx_mask")or"0x3F00"
local o=tonumber(e,16)
local a=0
local e=0
for t=1,16 do
if hasbit(o,bit(t))then
a=a+1
e=setbit(e,bit(a))
end
end
e=e-3
return t,i,e
end
m5=Map("mwan3",translate("MWAN - Interfaces"),
interfaceWarnings(configCheck()))
mwan_interface=m5:section(TypedSection,"interface",nil,
translate("MWAN supports up to 252 physical and/or logical interfaces<br />"..
"MWAN requires that all interfaces have a unique metric configured in /etc/config/network<br />"..
"Names must match the interface name found in /etc/config/network<br />"..
"Names may contain characters A-Z, a-z, 0-9, _ and no spaces<br />"..
"Interfaces may not share the same name as configured members, policies or rules"))
mwan_interface.addremove=true
mwan_interface.dynamic=false
mwan_interface.sectionhead=translate("Interface")
mwan_interface.sortable=false
mwan_interface.template="cbi/tblsection"
mwan_interface.extedit=dsp.build_url("admin","network","mwan","interface","%s")
function mwan_interface.create(t,e)
TypedSection.create(t,e)
m5.uci:save("mwan3")
luci.http.redirect(dsp.build_url("admin","network","mwan","interface",e))
end
enabled=mwan_interface:option(DummyValue,"enabled",translate("Enabled"))
enabled.rawhtml=true
function enabled.cfgvalue(e,t)
if e.map:get(t,"enabled")=="1"then
return translate("Yes")
else
return translate("No")
end
end
track_method=mwan_interface:option(DummyValue,"track_method",translate("Tracking method"))
track_method.rawhtml=true
function track_method.cfgvalue(e,t)
local a=e.map:get(t,"track_ip")
if a then
return e.map:get(t,"track_method")or"ping"
else
return"&#8212;"
end
end
reliability=mwan_interface:option(DummyValue,"reliability",translate("Tracking reliability"))
reliability.rawhtml=true
function reliability.cfgvalue(e,t)
local a=e.map:get(t,"track_ip")
if a then
return e.map:get(t,"reliability")or"1"
else
return"&#8212;"
end
end
interval=mwan_interface:option(DummyValue,"interval",translate("Ping interval"))
interval.rawhtml=true
function interval.cfgvalue(t,e)
local a=t.map:get(e,"track_ip")
if a then
local e=t.map:get(e,"interval")
if e then
return e.."s"
else
return"5s"
end
else
return"&#8212;"
end
end
down=mwan_interface:option(DummyValue,"down",translate("Interface down"))
down.rawhtml=true
function down.cfgvalue(e,t)
local a=e.map:get(t,"track_ip")
if a then
return e.map:get(t,"down")or"3"
else
return"&#8212;"
end
end
up=mwan_interface:option(DummyValue,"up",translate("Interface up"))
up.rawhtml=true
function up.cfgvalue(e,t)
local a=e.map:get(t,"track_ip")
if a then
return e.map:get(t,"up")or"3"
else
return"&#8212;"
end
end
metric=mwan_interface:option(DummyValue,"metric",translate("Metric"))
metric.rawhtml=true
function metric.cfgvalue(t,e)
local t=uci.cursor(nil,"/var/state")
local e=t:get("network",e,"metric")
if e then
return e
else
return"&#8212;"
end
end
return m5
