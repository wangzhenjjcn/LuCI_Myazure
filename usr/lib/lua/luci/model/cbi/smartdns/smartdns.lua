require("nixio.fs")
require("luci.http")
require("luci.dispatcher")
require("nixio.fs")
m=Map("smartdns")
m.title=translate("SmartDNS Server")
m.description=translate("SmartDNS is a local high-performance DNS server, supports finding fastest IP, supports ad filtering, and supports avoiding DNS poisoning.")
m:section(SimpleSection).template="smartdns/smartdns_status"
s=m:section(TypedSection,"smartdns",translate("Settings"),translate("General Settings"))
s.anonymous=true
s:tab("settings",translate("General Settings"))
s:tab("seconddns",translate("Second Server Settings"))
s:tab("custom",translate("Custom Settings"))
o=s:taboption("settings",Flag,"enabled",translate("Enable"),translate("Enable or disable smartdns server"))
o.default=o.disabled
o.rempty=false
o=s:taboption("settings",Value,"server_name",translate("Server Name"),translate("Smartdns server name"))
o.default="smartdns"
o.datatype="hostname"
o.rempty=false
o=s:taboption("settings",Value,"port",translate("Local Port"),translate("Smartdns local server port"))
o.placeholder=6053
o.default=6053
o.datatype="port"
o.rempty=false
o=s:taboption("settings",Flag,"tcp_server",translate("TCP Server"),translate("Enable TCP DNS Server"))
o.rmempty=false
o.default=o.enabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"1"
end
o=s:taboption("settings",Flag,"ipv6_server",translate("IPV6 Server"),translate("Enable IPV6 DNS Server"))
o.rmempty=false
o.default=o.enabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"1"
end
o=s:taboption("settings",Flag,"dualstack_ip_selection",translate("Dual-stack IP Selection"),translate("Enable IP selection between IPV4 and IPV6"))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("settings",Flag,"prefetch_domain",translate("Domain prefetch"),translate("Enable domain prefetch, accelerate domain response speed."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("settings",Flag,"serve_expired",translate("Serve expired"),translate("Attempts to serve old responses from cache with a TTL of 0 in the response without waiting for the actual resolution to finish."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("settings",ListValue,"redirect",translate("Redirect"),translate("SmartDNS redirect mode"))
o.placeholder="none"
o:value("none",translate("none"))
o:value("dnsmasq-upstream",translate("Run as dnsmasq upstream server"))
o:value("redirect",translate("Redirect 53 port to SmartDNS"))
o.default="none"
o.rempty=false
o=s:taboption("settings",Value,"cache_size",translate("Cache Size"),translate("DNS domain result cache size"))
o.rempty=true
o=s:taboption("settings",Value,"rr_ttl",translate("Domain TTL"),translate("TTL for all domain result."))
o.rempty=true
o=s:taboption("settings",Value,"rr_ttl_min",translate("Domain TTL Min"),translate("Minimum TTL for all domain result."))
o.rempty=true
o.placeholder="300"
o.default=300
o.optional=true
o=s:taboption("settings",Value,"rr_ttl_max",translate("Domain TTL Max"),translate("Maximum TTL for all domain result."))
o.rempty=true
o=s:taboption("seconddns",Flag,"seconddns_enabled",translate("Enable"),translate("Enable or disable second DNS server."))
o.default=o.disabled
o.rempty=false
o=s:taboption("seconddns",Value,"seconddns_port",translate("Local Port"),translate("Smartdns local server port"))
o.placeholder=7053
o.default=7053
o.datatype="port"
o.rempty=false
o=s:taboption("seconddns",Flag,"seconddns_tcp_server",translate("TCP Server"),translate("Enable TCP DNS Server"))
o.rmempty=false
o.default=o.enabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"1"
end
o=s:taboption("seconddns",Value,"seconddns_server_group",translate("Server Group"),translate("Query DNS through specific dns server group, such as office, home."))
o.rmempty=true
o.placeholder="default"
o.datatype="hostname"
o.rempty=true
o=s:taboption("seconddns",Flag,"seconddns_no_speed_check",translate("Skip Speed Check"),translate("Do not check speed."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("seconddns",Flag,"seconddns_no_rule_addr",translate("Skip Address Rules"),translate("Skip address rules."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("seconddns",Flag,"seconddns_no_rule_nameserver",translate("Skip Nameserver Rule"),translate("Skip nameserver rules."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("seconddns",Flag,"seconddns_no_rule_ipset",translate("Skip Ipset Rule"),translate("Skip ipset rules."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("seconddns",Flag,"seconddns_no_rule_soa",translate("Skip SOA Address Rule"),translate("Skip SOA address rules."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("seconddns",Flag,"seconddns_no_dualstack_selection",translate("Skip Dualstack Selection"),translate("Skip Dualstack Selection."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("seconddns",Flag,"seconddns_no_cache",translate("Skip Cache"),translate("Skip Cache."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:taboption("seconddns",Flag,"force_aaaa_soa",translate("Force AAAA SOA"),translate("Force AAAA SOA."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
custom=s:taboption("custom",Value,"Custom Settings",
translate(""),
translate("smartdns custom settings"))
custom.template="cbi/tvalue"
custom.rows=20
function custom.cfgvalue(e,e)
return nixio.fs.readfile("/etc/smartdns/custom.conf")
end
function custom.write(t,t,e)
e=e:gsub("\r\n?","\n")
nixio.fs.writefile("/etc/smartdns/custom.conf",e)
end
o=s:taboption("custom",Flag,"coredump",translate("Generate Coredump"),translate("Generate Coredump file when smartdns crash, coredump file is located at /tmp/smartdns.xxx.core."))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
s=m:section(TypedSection,"server",translate("Upstream Servers"),translate("Upstream Servers, support UDP, TCP protocol. "..
"Please configure multiple DNS servers, including multiple foreign DNS servers."))
s.anonymous=true
s.addremove=true
s.template="cbi/tblsection"
s.extedit=luci.dispatcher.build_url("admin/services/smartdns/upstream/%s")
o=s:option(Flag,"enabled",translate("Enable"),translate("Enable"))
o.rmempty=false
o.default=o.enabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"1"
end
s:option(Value,"name",translate("DNS Server Name"),translate("DNS Server Name"))
o=s:option(Value,"ip",translate("ip"),translate("DNS Server ip"))
o.datatype="or(ipaddr, string)"
o.rmempty=false
o=s:option(Value,"port",translate("port"),translate("DNS Server port"))
o.placeholder="default"
o.datatype="port"
o.rempty=true
o:depends("type","udp")
o:depends("type","tcp")
o:depends("type","tls")
o=s:option(ListValue,"type",translate("type"),translate("DNS Server type"))
o.placeholder="udp"
o:value("udp",translate("udp"))
o:value("tcp",translate("tcp"))
o:value("tls",translate("tls"))
o:value("https",translate("https"))
o.default="udp"
o.rempty=false
s=m:section(TypedSection,"smartdns",translate("Domain Address"),
translate("Set Specific domain ip address."))
s.anonymous=true
addr=s:option(Value,"address",
translate(""),
translate("Specify an IP address to return for any host in the given domains, Queries in the domains are never forwarded and always replied to with the specified IP address which may be IPv4 or IPv6."))
addr.template="cbi/tvalue"
addr.rows=20
function addr.cfgvalue(e,e)
return nixio.fs.readfile("/etc/smartdns/address.conf")
end
function addr.write(t,t,e)
e=e:gsub("\r\n?","\n")
nixio.fs.writefile("/etc/smartdns/address.conf",e)
end
s=m:section(TypedSection,"smartdns",translate("IP Blacklist"),
translate("Set Specific ip blacklist."))
s.anonymous=true
addr=s:option(Value,"blacklist_ip",
translate(""),
translate("Configure IP blacklists that will be filtered from the results of specific DNS server."))
addr.template="cbi/tvalue"
addr.rows=20
function addr.cfgvalue(e,e)
return nixio.fs.readfile("/etc/smartdns/blacklist-ip.conf")
end
function addr.write(t,t,e)
e=e:gsub("\r\n?","\n")
nixio.fs.writefile("/etc/smartdns/blacklist-ip.conf",e)
end
s=m:section(TypedSection,"smartdns",translate("Technical Support"),
translate("If you like this software, please buy me a cup of coffee."))
s.anonymous=true
o=s:option(Button,"web")
o.title=translate("SmartDNS official website")
o.inputtitle=translate("open website")
o.inputstyle="apply"
o.write=function()
luci.http.redirect("https://pymumu.github.io/smartdns")
end
o=s:option(Button,"Donate")
o.title=translate("Donate to smartdns")
o.inputtitle=translate("Donate")
o.inputstyle="apply"
o.write=function()
luci.http.redirect("https://pymumu.github.io/smartdns/#donate")
end
return m
