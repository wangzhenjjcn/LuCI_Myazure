module("luci.controller.smartdns",package.seeall)
local a=require"luci.model.smartdns"
function index()
if not nixio.fs.access("/etc/config/smartdns")then
return
end
local e
e=entry({"admin","services","smartdns"},cbi("smartdns/smartdns"),_("SmartDNS"),60)
e.dependent=true
e=entry({"admin","services","smartdns","status"},call("act_status"))
e.leaf=true
e=entry({"admin","services","smartdns","upstream"},cbi("smartdns/upstream"),nil)
e.leaf=true
end
local function i()
return luci.sys.call("pidof smartdns >/dev/null")==0
end
function act_status()
local e={}
local o;
local t="none";
e.ipv6_works=2;
e.ipv4_works=2;
e.ipv6_server=1;
e.dnsmasq_forward=0;
t=a.get_config_option("smartdns","smartdns","redirect",nil);
if t=="redirect"then
e.redirect=1
elseif t=="dnsmasq-upstream"then
e.redirect=2
else
e.redirect=0
end
e.local_port=a.get_config_option("smartdns","smartdns","port",nil);
o=a.get_config_option("smartdns","smartdns","ipv6_server",nil);
if e.redirect==1 then
if e.local_port~=nil and e.local_port~="53"then
e.ipv4_works=luci.sys.call("iptables -t nat -nL PREROUTING 2>/dev/null | grep REDIRECT | grep dpt:53 | grep %q >/dev/null 2>&1"%e.local_port)==0
if o=="1"then
e.ipv6_works=luci.sys.call("ip6tables -t nat -nL PREROUTING 2>/dev/null| grep REDIRECT | grep dpt:53 | grep %q >/dev/null 2>&1"%e.local_port)==0
else
e.ipv6_works=2
end
else
e.redirect=0
end
elseif e.redirect==2 then
local t;
local a=luci.sys.exec("uci get dhcp.@dnsmasq[0].server")
if e.local_port~=nil then
t="127.0.0.1#"..e.local_port
if string.sub(a,1,string.len(t))==t then
e.dnsmasq_forward=1
end
end
end
e.running=i()
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
