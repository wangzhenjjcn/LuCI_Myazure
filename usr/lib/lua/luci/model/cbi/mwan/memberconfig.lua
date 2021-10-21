dsp=require"luci.dispatcher"
arg[1]=arg[1]or""
m5=Map("mwan3",translatef("MWAN Member Configuration - %s",arg[1]))
m5.redirect=dsp.build_url("admin","network","mwan","member")
mwan_member=m5:section(NamedSection,arg[1],"member","")
mwan_member.addremove=false
mwan_member.dynamic=false
interface=mwan_member:option(Value,"interface",translate("Interface"))
m5.uci:foreach("mwan3","interface",
function(e)
interface:value(e['.name'],e['.name'])
end
)
metric=mwan_member:option(Value,"metric",translate("Metric"),
translate("Acceptable values: 1-256. Defaults to 1 if not set"))
metric.datatype="range(1, 256)"
weight=mwan_member:option(Value,"weight",translate("Weight"),
translate("Acceptable values: 1-1000. Defaults to 1 if not set"))
weight.datatype="range(1, 1000)"
return m5
