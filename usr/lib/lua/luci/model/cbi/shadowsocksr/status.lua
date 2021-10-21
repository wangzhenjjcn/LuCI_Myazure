require"nixio.fs"
require"luci.sys"
require"luci.model.uci"
local t,e,a
local f=0
local i=0
local d=0
local n=0
local m=0
local a=0
local u=0
local c=0
local l=0
local s=0
local h=luci.model.uci.cursor()
local r="shadowsocksr"
font_blue=[[<font color="green">]]
font_off=[[</font>]]
bold_on=[[<strong>]]
bold_off=[[</strong>]]
local a=translate("Unknown")
local o="/usr/bin/kcptun-client"
if not nixio.fs.access(o)then
a=translate("Not exist")
else
if not nixio.fs.access(o,"rwx","rx","rx")then
nixio.fs.chmod(o,755)
end
a=luci.sys.exec(o.." -v | awk '{printf $3}'")
if not a or a==""then
a=translate("Unknown")
end
end
if nixio.fs.access("/etc/ssr/gfw_list.conf")then
u=tonumber(luci.sys.exec("cat /etc/ssr/gfw_list.conf | wc -l"))/2
end
if nixio.fs.access("/etc/ssr/ad.conf")then
c=tonumber(luci.sys.exec("cat /etc/ssr/ad.conf | wc -l"))
end
if nixio.fs.access("/etc/ssr/china_ssr.txt")then
l=tonumber(luci.sys.exec("cat /etc/ssr/china_ssr.txt | wc -l"))
end
if nixio.fs.access("/etc/ssr/netflixip.list")then
s=tonumber(luci.sys.exec("cat /etc/ssr/netflixip.list | wc -l"))
end
local o=luci.sys.exec("busybox ps -w | grep ssr-reudp |grep -v grep| wc -l")
if tonumber(o)>0 then
i=1
else
o=luci.sys.exec("busybox ps -w | grep ssr-retcp |grep \"\\-u\"|grep -v grep| wc -l")
if tonumber(o)>0 then
i=1
end
end
if luci.sys.call("busybox ps -w | grep ssr-retcp | grep -v grep >/dev/null")==0 then
f=1
end
if luci.sys.call("busybox ps -w | grep ssr-local | grep -v ssr-socksdns |grep -v grep >/dev/null")==0 then
d=1
end
if luci.sys.call("pidof kcptun-client >/dev/null")==0 then
m=1
end
if luci.sys.call("busybox ps -w | grep ssr-server | grep -v grep >/dev/null")==0 then
n=1
end
if luci.sys.call("pidof pdnsd >/dev/null")==0 or(luci.sys.call("busybox ps -w | grep ssr-dns |grep -v grep >/dev/null")==0 and luci.sys.call("pidof dns2socks >/dev/null")==0)then
pdnsd_run=1
end
t=SimpleForm("Version")
t.reset=false
t.submit=false
e=t:field(DummyValue,"redir_run",translate("Global Client"))
e.rawhtml=true
if f==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=translate("Not Running")
end
e=t:field(DummyValue,"reudp_run",translate("Game Mode UDP Relay"))
e.rawhtml=true
if i==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=translate("Not Running")
end
if h:get_first(r,'global','pdnsd_enable','0')~='0'then
e=t:field(DummyValue,"pdnsd_run",translate("DNS Anti-pollution"))
e.rawhtml=true
if pdnsd_run==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=translate("Not Running")
end
end
e=t:field(DummyValue,"sock5_run",translate("Global SOCKS5 Proxy Server"))
e.rawhtml=true
if d==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=translate("Not Running")
end
e=t:field(DummyValue,"server_run",translate("Local Servers"))
e.rawhtml=true
if n==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=translate("Not Running")
end
if nixio.fs.access("/usr/bin/kcptun-client")then
e=t:field(DummyValue,"kcp_version",translate("KcpTun Version"))
e.rawhtml=true
e.value=a
e=t:field(DummyValue,"kcptun_run",translate("KcpTun"))
e.rawhtml=true
if m==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=translate("Not Running")
end
end
e=t:field(DummyValue,"google",translate("Google Connectivity"))
e.value=translate("No Check")
e.template="shadowsocksr/check"
e=t:field(DummyValue,"baidu",translate("Baidu Connectivity"))
e.value=translate("No Check")
e.template="shadowsocksr/check"
e=t:field(DummyValue,"gfw_data",translate("GFW List Data"))
e.rawhtml=true
e.template="shadowsocksr/refresh"
e.value=u.." "..translate("Records")
e=t:field(DummyValue,"ip_data",translate("China IP Data"))
e.rawhtml=true
e.template="shadowsocksr/refresh"
e.value=l.." "..translate("Records")
e=t:field(DummyValue,"nfip_data",translate("Netflix IP Data"))
e.rawhtml=true
e.template="shadowsocksr/refresh"
e.value=s.." "..translate("Records")
if h:get_first(r,'global','adblock','0')=='1'then
e=t:field(DummyValue,"ad_data",translate("Advertising Data"))
e.rawhtml=true
e.template="shadowsocksr/refresh"
e.value=c.." "..translate("Records")
end
e=t:field(DummyValue,"check_port",translate("Check Server Port"))
e.template="shadowsocksr/checkport"
e.value=translate("No Check")
return t
