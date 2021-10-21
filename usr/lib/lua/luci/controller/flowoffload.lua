module("luci.controller.flowoffload",package.seeall)
function index()
if not nixio.fs.access("/etc/config/flowoffload")then
return
end
local e
e=entry({"admin","network","flowoffload"},cbi("flowoffload"),_("Turbo ACC Center"),101)
e.i18n="flowoffload"
e.dependent=true
entry({"admin","network","flowoffload","status"},call("action_status"))
end
local function a()
return luci.sys.call("[ `cat /sys/module/xt_FLOWOFFLOAD/refcnt 2>/dev/null` -gt 0 ] 2>/dev/null")==0
end
local function t()
return luci.sys.call("[ `cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null` = bbr ] 2>/dev/null")==0
end
local function e()
return luci.sys.call("[ `cat /sys/module/xt_FULLCONENAT/refcnt 2>/dev/null` -gt 0 ] 2>/dev/null")==0
end
local function o()
return luci.sys.call("pgrep dnscache >/dev/null")==0
end
function action_status()
luci.http.prepare_content("application/json")
luci.http.write_json({
run_state=a(),
down_state=t(),
up_state=e(),
dns_state=o()
})
end
