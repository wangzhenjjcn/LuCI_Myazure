dsp=require"luci.dispatcher"
m5=Map("mwan3",translate("MWAN - Members"))
mwan_member=m5:section(TypedSection,"member",nil,
translate("Members are profiles attaching a metric and weight to an MWAN interface<br />"..
"Names may contain characters A-Z, a-z, 0-9, _ and no spaces<br />"..
"Members may not share the same name as configured interfaces, policies or rules"))
mwan_member.addremove=true
mwan_member.dynamic=false
mwan_member.sectionhead=translate("Member")
mwan_member.sortable=true
mwan_member.template="cbi/tblsection"
mwan_member.extedit=dsp.build_url("admin","network","mwan","member","%s")
function mwan_member.create(t,e)
TypedSection.create(t,e)
m5.uci:save("mwan3")
luci.http.redirect(dsp.build_url("admin","network","mwan","member",e))
end
interface=mwan_member:option(DummyValue,"interface",translate("Interface"))
interface.rawhtml=true
function interface.cfgvalue(t,e)
return t.map:get(e,"interface")or"&#8212;"
end
metric=mwan_member:option(DummyValue,"metric",translate("Metric"))
metric.rawhtml=true
function metric.cfgvalue(t,e)
return t.map:get(e,"metric")or"1"
end
weight=mwan_member:option(DummyValue,"weight",translate("Weight"))
weight.rawhtml=true
function weight.cfgvalue(e,t)
return e.map:get(t,"weight")or"1"
end
return m5
