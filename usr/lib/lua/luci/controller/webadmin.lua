module("luci.controller.webadmin",package.seeall)
function index()
if not nixio.fs.access("/etc/config/uhttpd")then
return
end
local e
e=entry({"admin","system","webadmin"},cbi("webadmin"),_("Web Admin"),1)
e.leaf=true
end
