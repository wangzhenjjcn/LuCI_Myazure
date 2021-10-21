local i=require"luci.dispatcher"
local e=require("luci.model.ipkg")
local n=require"nixio.fs"
local e=luci.model.uci.cursor()
local o="frp"
local a,t,e
local s={}
a=Map(o,translate("Frp Setting"),translate("Frp is a fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet."))
a:section(SimpleSection).template="frp/frp_status"
t=a:section(NamedSection,"common","frp",translate("Global Setting"))
t.anonymous=true
t.addremove=false
t:tab("base",translate("Basic Settings"))
t:tab("other",translate("Other Settings"))
t:tab("log",translate("Client Log"))
e=t:taboption("base",Flag,"enabled",translate("Enabled"))
e.rmempty=false
e=t:taboption("base",Value,"server_addr",translate("Server"))
e.optional=false
e.rmempty=false
e=t:taboption("base",Value,"server_port",translate("Port"))
e.datatype="port"
e.optional=false
e.rmempty=false
e=t:taboption("base",Value,"token",translate("Token"),translate("Time duration between server of frpc and frps mustn't exceed 15 minutes."))
e.optional=false
e.password=true
e.rmempty=false
e=t:taboption("base",Value,"vhost_http_port",translate("Vhost HTTP Port"))
e.datatype="port"
e.rmempty=false
e=t:taboption("base",Value,"vhost_https_port",translate("Vhost HTTPS Port"))
e.datatype="port"
e.rmempty=false
e=t:taboption("other",Flag,"login_fail_exit",translate("Exit program when first login failed"),translate("decide if exit program when first login failed, otherwise continuous relogin to frps."))
e.default="1"
e.rmempty=false
e=t:taboption("other",Flag,"tcp_mux",translate("TCP Stream Multiplexing"),translate("Default is Ture. This feature in frps.ini and frpc.ini must be same."))
e.default="1"
e.rmempty=false
e=t:taboption("other",ListValue,"protocol",translate("Protocol Type"),translate("Frp support kcp protocol since v0.12.0"))
e.default="tcp"
e:value("tcp",translate("TCP Protocol"))
e:value("kcp",translate("KCP Protocol"))
e=t:taboption("other",Flag,"enable_http_proxy",translate("Connect frps by HTTP PROXY"),translate("frpc can connect frps using HTTP PROXY"))
e.default="0"
e.rmempty=false
e:depends("protocol","tcp")
e=t:taboption("other",Value,"http_proxy",translate("HTTP PROXY"))
e.datatype="uinteger"
e.placeholder="http://user:pwd@192.168.1.128:8080"
e:depends("enable_http_proxy",1)
e.optional=false
e=t:taboption("other",Flag,"enable_cpool",translate("Enable Connection Pool"),translate("This feature is fit for a large number of short connections."))
e.rmempty=false
e=t:taboption("other",Value,"pool_count",translate("Connection Pool"),translate("Connections will be established in advance."))
e.datatype="uinteger"
e.default="1"
e:depends("enable_cpool",1)
e.optional=false
e=t:taboption("base",Value,"time",translate("Service registration interval"),translate("0 means disable this feature, unit: min"))
e.datatype="range(0,59)"
e.default=30
e.rmempty=false
e=t:taboption("other",ListValue,"log_level",translate("Log Level"))
e.default="warn"
e:value("trace",translate("Trace"))
e:value("debug",translate("Debug"))
e:value("info",translate("Info"))
e:value("warn",translate("Warning"))
e:value("error",translate("Error"))
e=t:taboption("other",Value,"log_max_days",translate("Log Keepd Max Days"))
e.datatype="uinteger"
e.default="3"
e.rmempty=false
e.optional=false
e=t:taboption("log",TextValue,"log")
e.rows=26
e.wrap="off"
e.readonly=true
e.cfgvalue=function(t,t)
return n.readfile("/var/etc/frp/frpc.log")or""
end
e.write=function(e,e,e)
end
t=a:section(TypedSection,"proxy",translate("Services List"))
t.anonymous=true
t.addremove=true
t.template="cbi/tblsection"
t.extedit=i.build_url("admin","services","frp","config","%s")
function t.create(e,t)
new=TypedSection.create(e,t)
luci.http.redirect(e.extedit:format(new))
end
function t.remove(e,t)
e.map.proceed=true
e.map:del(t)
luci.http.redirect(i.build_url("admin","services","frp"))
end
local i=""
e=t:option(DummyValue,"remark",translate("Service Remark Name"))
e.width="10%"
e=t:option(DummyValue,"type",translate("Frp Protocol Type"))
e.width="10%"
e=t:option(DummyValue,"custom_domains",translate("Domain/Subdomain"))
e.width="20%"
e.cfgvalue=function(i,t)
local i=a.uci:get(o,t,"domain_type")or""
local n=a.uci:get(o,t,"type")or""
if i=="custom_domains"then
local e=a.uci:get(o,t,"custom_domains")or""return e end
if i=="subdomain"then
local e=a.uci:get(o,t,"subdomain")or""return e end
if i=="both_dtype"then
local e=a.uci:get(o,t,"custom_domains")or""
local t=a.uci:get(o,t,"subdomain")or""
e="%s/%s"%{e,t}return e end
if n=="tcp"or n=="udp"then
local e=a.uci:get(o,"common","server_addr")or""return e end
end
e=t:option(DummyValue,"remote_port",translate("Remote Port"))
e.width="10%"
e.cfgvalue=function(t,i)
local t=a.uci:get(o,i,"type")or""
if t==""or i==""then return""end
if t=="http"then
local e=a.uci:get(o,"common","vhost_http_port")or""return e end
if t=="https"then
local e=a.uci:get(o,"common","vhost_https_port")or""return e end
if t=="tcp"or t=="udp"then
local e=a.uci:get(o,i,"remote_port")or""return e end
end
e=t:option(DummyValue,"local_ip",translate("Local Host Address"))
e.width="15%"
e=t:option(DummyValue,"local_port",translate("Local Host Port"))
e.width="10%"
e=t:option(DummyValue,"use_encryption",translate("Use Encryption"))
e.width="15%"
e.cfgvalue=function(i,t)
local a=a.uci:get(o,t,"use_encryption")or""
local t
if a==""or t==""then return""end
if a=="1"then t="ON"
else t="OFF"end
return t
end
e=t:option(DummyValue,"use_compression",translate("Use Compression"))
e.width="15%"
e.cfgvalue=function(i,t)
local a=a.uci:get(o,t,"use_compression")or""
local t
if a==""or t==""then return""end
if a=="1"then t="ON"
else t="OFF"end
return t
end
e=t:option(Flag,"enable",translate("Enable State"))
e.width="10%"
e.rmempty=false
return a
