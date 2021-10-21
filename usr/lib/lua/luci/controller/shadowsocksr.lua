module("luci.controller.shadowsocksr",package.seeall)
function index()
if not nixio.fs.access("/etc/config/shadowsocksr")then
return
end
entry({"admin","services","shadowsocksr"},alias("admin","services","shadowsocksr","client"),_("ShadowSocksR Plus+"),10).dependent=true
entry({"admin","services","shadowsocksr","client"},cbi("shadowsocksr/client"),_("SSR Client"),10).leaf=true
entry({"admin","services","shadowsocksr","servers"},arcombine(cbi("shadowsocksr/servers",{autoapply=true}),cbi("shadowsocksr/client-config")),_("Severs Nodes"),20).leaf=true
entry({"admin","services","shadowsocksr","control"},cbi("shadowsocksr/control"),_("Access Control"),30).leaf=true
entry({"admin","services","shadowsocksr","advanced"},cbi("shadowsocksr/advanced"),_("Advanced Settings"),50).leaf=true
entry({"admin","services","shadowsocksr","server"},arcombine(cbi("shadowsocksr/server"),cbi("shadowsocksr/server-config")),_("SSR Server"),60).leaf=true
entry({"admin","services","shadowsocksr","status"},form("shadowsocksr/status"),_("Status"),70).leaf=true
entry({"admin","services","shadowsocksr","check"},call("check_status"))
entry({"admin","services","shadowsocksr","refresh"},call("refresh_data"))
entry({"admin","services","shadowsocksr","subscribe"},call("subscribe"))
entry({"admin","services","shadowsocksr","checkport"},call("check_port"))
entry({"admin","services","shadowsocksr","log"},form("shadowsocksr/log"),_("Log"),80).leaf=true
entry({"admin","services","shadowsocksr","run"},call("act_status")).leaf=true
entry({"admin","services","shadowsocksr","ping"},call("act_ping")).leaf=true
end
function subscribe()
luci.sys.call("/usr/bin/lua /usr/share/shadowsocksr/subscribe.lua >> /tmp/ssrplus.log 2>&1")
luci.http.prepare_content("application/json")
luci.http.write_json({ret=1})
end
function act_status()
local e={}
e.running=luci.sys.call("busybox ps -w | grep ssr-retcp | grep -v grep >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function act_ping()
local e={}
local t=luci.http.formvalue("domain")
local o=luci.http.formvalue("port")
e.index=luci.http.formvalue("index")
local i=luci.sys.call(" ipset add ss_spec_wan_ac "..t.." 2>/dev/null")
local a=nixio.socket("inet","stream")
a:setopt("socket","rcvtimeo",3)
a:setopt("socket","sndtimeo",3)
e.socket=a:connect(t,o)
a:close()
e.ping=luci.sys.exec("ping -c 1 -W 1 %q 2>&1 | grep -o 'time=[0-9]*.[0-9]' | awk -F '=' '{print$2}'"%t)
if(e.ping=="")then
e.ping=luci.sys.exec(string.format("echo -n $(tcpping -c 1 -i 1 -p %s %s 2>&1 | grep -o 'ttl=[0-9]* time=[0-9]*.[0-9]' | awk -F '=' '{print$3}') 2>/dev/null",o,t))
end
if(i==0)then
luci.sys.call(" ipset del ss_spec_wan_ac "..t)
end
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function check_status()
local e="/usr/bin/ssr-check www."..luci.http.formvalue("set")..".com 80 3 1"
sret=luci.sys.call(e)
if sret==0 then
retstring="0"
else
retstring="1"
end
luci.http.prepare_content("application/json")
luci.http.write_json({ret=retstring})
end
function refresh_data()
local t=luci.http.formvalue("set")
local a=luci.model.uci.cursor()
local n=0
local i=0
local function o(s,t,e,a)
local o=1
refresh_cmd="wget-ssl --no-check-certificate -t 3 -T 10 -O- "..s.." > /tmp/ssr-update."..e
sret=luci.sys.call(refresh_cmd.." 2>/dev/null")
if sret==0 then
if e=="gfw_data"then
luci.sys.call("/usr/bin/ssr-gfw "..e)
o=2
end
if e=="ad_data"then
luci.sys.call("/usr/bin/ssr-ad "..e)
end
local h=luci.sys.exec("echo -n $([ -f '/tmp/ssr-update."..e.."' ] && md5sum /tmp/ssr-update."..e.." | awk '{print $1}')")
local s=luci.sys.exec("echo -n $([ -f '"..t.."' ] && md5sum "..t.." | awk '{print $1}')")
if h==s then
i="0"
else
n=luci.sys.exec("cat /tmp/ssr-update."..e.." | wc -l")
luci.sys.exec("cp -f /tmp/ssr-update."..e.." "..t)
if a then luci.sys.exec("cp -f /tmp/ssr-update."..e.." "..a)end
i=tostring(tonumber(n)/o)
if e=="gfw_data"or e=="ad_data"then
luci.sys.exec("/usr/share/shadowsocksr/gfw2ipset.sh gfw_data")
else
luci.sys.exec("/etc/init.d/shadowsocksr restart &")
end
end
else
i="-1"
end
luci.sys.exec("rm -f /tmp/ssr-update."..e)
end
if t=="gfw_data"then
o(a:get_first("shadowsocksr","global","gfwlist_url","https://cdn.jsdelivr.net/gh/gfwlist/gfwlist/gfwlist.txt"),"/etc/ssr/gfw_list.conf",t,"/tmp/dnsmasq.ssr/gfw_list.conf")
end
if t=="ip_data"then
o(a:get_first("shadowsocksr","global","chnroute_url","https://ispip.clang.cn/all_cn.txt"),"/etc/ssr/china_ssr.txt",t)
end
if t=="ad_data"then
o(a:get_first("shadowsocksr","global","adblock_url","https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt"),"/etc/ssr/ad.conf",t,"/tmp/dnsmasq.ssr/ad.conf")
end
if t=="nfip_data"then
o(a:get_first("shadowsocksr","global","nfip_url","https://raw.githubusercontent.com/QiuSimons/Netflix_IP/master/NF_only.txt"),"/etc/ssr/netflixip.list",t)
end
luci.http.prepare_content("application/json")
luci.http.write_json({ret=i,retcount=n})
end
function check_port()
local e=""
local t="<br /><br />"
local e
local a=""
local e=luci.model.uci.cursor()
local o=1
e:foreach("shadowsocksr","servers",function(e)
if e.alias then
a=e.alias
elseif e.server and e.server_port then
a="%s:%s"%{e.server,e.server_port}
end
o=luci.sys.call("ipset add ss_spec_wan_ac "..e.server.." 2>/dev/null")
socket=nixio.socket("inet","stream")
socket:setopt("socket","rcvtimeo",3)
socket:setopt("socket","sndtimeo",3)
ret=socket:connect(e.server,e.server_port)
if tostring(ret)=="true"then
socket:close()
t=t.."<font color = 'green'>["..a.."] OK.</font><br />"
else
t=t.."<font color = 'red'>["..a.."] Error.</font><br />"
end
if o==0 then
luci.sys.call("ipset del ss_spec_wan_ac "..e.server)
end
end)
luci.http.prepare_content("application/json")
luci.http.write_json({ret=t})
end
