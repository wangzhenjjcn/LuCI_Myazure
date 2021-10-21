module("luci.controller.wrtbwmon",package.seeall)
function index()
entry({"admin","nlbw","usage"},alias("admin","nlbw","usage","details"),_("Usage"),60)
entry({"admin","nlbw","usage","details"},template("wrtbwmon"),_("Details"),10).leaf=true
entry({"admin","nlbw","usage","config"},cbi("wrtbwmon/config"),_("Configuration"),20).leaf=true
entry({"admin","nlbw","usage","custom"},form("wrtbwmon/custom"),_("User file"),30).leaf=true
entry({"admin","nlbw","usage","check_dependency"},call("check_dependency")).dependent=true
entry({"admin","nlbw","usage","usage_data"},call("usage_data")).dependent=true
entry({"admin","nlbw","usage","usage_reset"},call("usage_reset")).dependent=true
end
function usage_database_path()
local e=luci.model.uci.cursor()
if e:get("wrtbwmon","general","persist")=="1"then
return"/etc/config/usage.db"
else
return"/tmp/usage.db"
end
end
function check_dependency()
local e="0"
if require("luci.model.ipkg").installed('iptables')then
e="1"
end
luci.http.prepare_content("text/plain")
luci.http.write(e)
end
function usage_data()
local e=usage_database_path()
local t="wrtbwmon publish "..e.." /tmp/usage.htm /etc/config/wrtbwmon.user"
local e="wrtbwmon update "..e.." && "..t.." && cat /tmp/usage.htm"
luci.http.prepare_content("text/html")
luci.http.write(luci.sys.exec(e))
end
function usage_reset()
local e=usage_database_path()
local e=luci.sys.call("wrtbwmon update "..e.." && rm "..e)
luci.http.status(204)
end
