local e=require("nixio.fs")
local i=Map("uhttpd",translate("Web Admin Settings"),
translate("Web Admin Settings Page"))
local t=i:section(TypedSection,"uhttpd")
t.addremove=false
t.anonymous=true
lhttp=t:option(DynamicList,"listen_http",translate("HTTP listeners (address:port)"),translate("Bind to specific interface:port (by specifying interface address"))
lhttp.datatype="list(ipaddrport(1))"
function lhttp.validate(i,n,e)
local a=false
local t=false
if lhttp and lhttp:formvalue(e)and(#(lhttp:formvalue(e))>0)then
for a,e in pairs(lhttp:formvalue(e))do
if e and(e~="")then
t=true
break
end
end
end
if lhttps and lhttps:formvalue(e)and(#(lhttps:formvalue(e))>0)then
for t,e in pairs(lhttps:formvalue(e))do
if e and(e~="")then
a=true
break
end
end
end
if not(t or a)then
return nil,"must listen on at list one address:port"
end
return DynamicList.validate(i,n,e)
end
o=t:option(Flag,"redirect_https",translate("Redirect all HTTP to HTTPS"))
o.default=o.enabled
o.rmempty=false
o.description=translate("Redirect all HTTP to HTTPS when SSl cert was installed")
o=t:option(Flag,"rfc1918_filter",translate("Ignore private IPs on public interface"),translate("Prevent access from private (RFC1918) IPs on an interface if it has an public IP address"))
o.default=o.enabled
o.rmempty=false
return i
