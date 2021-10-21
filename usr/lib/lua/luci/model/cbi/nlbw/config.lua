local c=require"luci.util"
local e=require"luci.sys"
local y=require"nixio.fs"
local b=require"luci.ip"
local g=require"luci.model.network"
local e,t,o,l,i,n,a,s,d,w,p,f,m,h,u,v,r
t=Map("nlbwmon",translate("Netlink Bandwidth Monitor - Configuration"),
translate("The Netlink Bandwidth Monitor (nlbwmon) is a lightweight, efficient traffic accounting program keeping track of bandwidth usage per host and protocol."))
g.init(luci.model.uci.cursor_state())
e=t:section(TypedSection,"nlbwmon")
e.anonymous=true
e.addremove=false
e:tab("general",translate("General Settings"))
e:tab("advanced",translate("Advanced Settings"))
e:tab("protocol",translate("Protocol Mapping"),
translate("Protocol mappings to distinguish traffic types per host, one mapping per line. The first value specifies the IP protocol, the second value the port number and the third column is the name of the mapped protocol."))
o=e:taboption("general",ListValue,"_period",translate("Accounting period"),
translate("Choose \"Day of month\" to restart the accounting period monthly on a specific date, e.g. every 3rd. Choose \"Fixed interval\" to restart the accounting period exactly every N days, beginning at a given date."))
o:value("relative",translate("Day of month"))
o:value("absolute",translate("Fixed interval"))
o.write=function(s,e,s)
if o:formvalue(e)=="relative"then
t:set(e,"database_interval",a:formvalue(e))
else
t:set(e,"database_interval","%s/%s"%{
i:formvalue(e),
n:formvalue(e)
})
end
end
o.cfgvalue=function(a,e)
local e=t:get(e,"database_interval")or""
if e:match("^%d%d%d%d%-%d%d%-%d%d/%d+$")then
return"absolute"
end
return"relative"
end
l=e:taboption("general",DummyValue,"_warning",translate("Warning"))
l.default=translatef("Changing the accounting interval type will invalidate existing databases!<br /><strong><a href=\"%s\">Download backup</a></strong>.",luci.dispatcher.build_url("admin/nlbw/backup"))
l.rawhtml=true
if(t.uci:get_first("nlbwmon","nlbwmon","database_interval")or""):match("^%d%d%d%d-%d%d-%d%d/%d+$")then
l:depends("_period","relative")
else
l:depends("_period","absolute")
end
a=e:taboption("general",Value,"_interval",translate("Due date"),
translate("Day of month to restart the accounting period. Use negative values to count towards the end of month, e.g. \"-5\" to specify the 27th of July or the 24th of Februrary."))
a.datatype="or(range(1,31),range(-31,-1))"
a.placeholder="1"
a:value("1",translate("1 - Restart every 1st of month"))
a:value("-1",translate("-1 - Restart every last day of month"))
a:value("-7",translate("-7 - Restart a week before end of month"))
a.rmempty=false
a:depends("_period","relative")
a.write=o.write
a.cfgvalue=function(a,e)
local e=t:get(e,"database_interval")
return e and tonumber(e)
end
i=e:taboption("general",Value,"_date",translate("Start date"),
translate("Start date of the first accounting period, e.g. begin of ISP contract."))
i.datatype="dateyyyymmdd"
i.placeholder="2016-03-15"
i.rmempty=false
i:depends("_period","absolute")
i.write=o.write
i.cfgvalue=function(a,e)
local e=t:get(e,"database_interval")or""
return(e:match("^(%d%d%d%d%-%d%d%-%d%d)/%d+$"))
end
n=e:taboption("general",Value,"_days",translate("Interval"),
translate("Length of accounting interval in days."))
n.datatype="min(1)"
n.placeholder="30"
n.rmempty=false
n:depends("_period","absolute")
n.write=o.write
n.cfgvalue=function(a,e)
local e=t:get(e,"database_interval")or""
return(e:match("^%d%d%d%d%-%d%d%-%d%d/(%d+)$"))
end
s=e:taboption("general",Value,"_ifaces",translate("Local interfaces"),
translate("Only conntrack streams from or to any of these networks are counted."))
s.template="cbi/network_netlist"
s.widget="checkbox"
s.nocreate=true
s.cfgvalue=function(a,e)
return t:get(e,"local_network")
end
s.write=function(e,a)
local e
local e={}
for t in c.imatch(d:formvalue(a))do
e[#e+1]=t
end
for a in c.imatch(s:formvalue(a))do
e[#e+1]=a
end
t:set(a,"local_network",e)
end
d=e:taboption("general",DynamicList,"_subnets",translate("Local subnets"),
translate("Only conntrack streams from or to any of these subnets are counted."))
d.datatype="ipaddr"
d.cfgvalue=function(a,e)
local a
local a={}
for e in c.imatch(t:get(e,"local_network"))do
e=b.new(e)
a[#a+1]=e and e:string()
end
return a
end
d.write=s.write
w=e:taboption("advanced",Value,"database_limit",translate("Maximum entries"),
translate("The maximum amount of entries that should be put into the database, setting the limit to 0 will allow databases to grow indefinitely."))
w.datatype="uinteger"
w.placeholder="10000"
p=e:taboption("advanced",Flag,"database_prealloc",translate("Preallocate database"),
translate("Whether to preallocate the maximum possible database size in memory. This is mainly useful for memory constrained systems which might not be able to satisfy memory allocation after longer uptime periods."))
p:depends({["database_limit"]="0",["!reverse"]=true})
f=e:taboption("advanced",Flag,"database_compress",translate("Compress database"),
translate("Whether to gzip compress archive databases. Compressing the database files makes accessing old data slightly slower but helps to reduce storage requirements."))
f.default=f.enabled
m=e:taboption("advanced",Value,"database_generations",translate("Stored periods"),
translate("Maximum number of accounting periods to keep, use zero to keep databases forever."))
m.datatype="uinteger"
m.placeholder="10"
h=e:taboption("advanced",Value,"commit_interval",translate("Commit interval"),
translate("Interval at which the temporary in-memory database is committed to the persistent database directory."))
h.placeholder="24h"
h:value("24h",translate("24h - least flash wear at the expense of data loss risk"))
h:value("12h",translate("12h - compromise between risk of data loss and flash wear"))
h:value("10m",translate("10m - frequent commits at the expense of flash wear"))
h:value("60s",translate("60s - commit minutely, useful for non-flash storage"))
u=e:taboption("advanced",Value,"refresh_interval",translate("Refresh interval"),
translate("Interval at which traffic counters of still established connections are refreshed from netlink information."))
u.placeholder="30s"
u:value("30s",translate("30s - refresh twice per minute for reasonably current stats"))
u:value("5m",translate("5m - rarely refresh to avoid frequently clearing conntrack counters"))
v=e:taboption("advanced",Value,"database_directory",translate("Database directory"),
translate("Database storage directory. One file per accounting period will be placed into this directory."))
v.placeholder="/var/lib/nlbwmon"
r=e:taboption("protocol",TextValue,"_protocols")
r.rows=50
r.cfgvalue=function(e,e)
return y.readfile("/usr/share/nlbwmon/protocols")
end
r.write=function(t,t,e)
y.writefile("/usr/share/nlbwmon/protocols",(e or""):gsub("\r\n","\n"))
end
r.remove=r.write
return t
