module("luci.controller.watchcat",package.seeall)
function index()
if not nixio.fs.access("/etc/config/system")then
return
end
entry({"admin","services","watchcat"},cbi("watchcat/watchcat"),_("Watchcat"),90)
end
