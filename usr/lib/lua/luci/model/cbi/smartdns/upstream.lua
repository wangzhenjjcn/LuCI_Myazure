local e=arg[1]
m=Map("smartdns","%s - %s"%{translate("SmartDNS Server"),translate("Upstream DNS Server Configuration")})
m.redirect=luci.dispatcher.build_url("admin/services/smartdns")
if m.uci:get("smartdns",e)~="server"then
luci.http.redirect(m.redirect)
return
end
s=m:section(NamedSection,e,"server")
s.anonymous=true
s.addremove=false
s:option(Value,"name",translate("DNS Server Name"),translate("DNS Server Name"))
o=s:option(Value,"ip",translate("ip"),translate("DNS Server ip"))
o.datatype="or(host, string)"
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
o=s:option(Value,"tls_host_verify",translate("TLS Hostname Verify"),translate("Set TLS hostname to verify."))
o.default=""
o.datatype="string"
o.rempty=true
o:depends("type","tls")
o:depends("type","https")
o=s:option(Flag,"no_check_certificate",translate("No check certificate"),translate("Do not check certificate."))
o.default=o.disabled
o.rmempty=false
o:depends("type","tls")
o:depends("type","https")
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:option(Value,"host_name",translate("TLS SNI name"),translate("Sets the server name indication for query."))
o.default=""
o.datatype="hostname"
o.rempty=true
o:depends("type","tls")
o:depends("type","https")
o=s:option(Value,"http_host",translate("HTTP Host"),translate("Set the HTTP host used for the query. Use this parameter when the host of the URL address is an IP address."))
o.default=""
o.datatype="hostname"
o.rempty=true
o:depends("type","https")
o=s:option(Value,"server_group",translate("Server Group"),translate("DNS Server group belongs to, used with nameserver, such as office, home."))
o.rmempty=true
o.placeholder="default"
o.datatype="hostname"
o.rempty=true
o=s:option(Flag,"blacklist_ip",translate("IP Blacklist Filtering"),translate("Filtering IP with blacklist"))
o.rmempty=false
o.default=o.disabled
o.cfgvalue=function(...)
return Flag.cfgvalue(...)or"0"
end
o=s:option(Value,"spki_pin",translate("TLS SPKI Pinning"),translate("Used to verify the validity of the TLS server, The value is Base64 encoded SPKI fingerprint, leaving blank to indicate that the validity of TLS is not verified."))
o.default=""
o.datatype="string"
o.rempty=true
o:depends("type","tls")
o:depends("type","https")
o=s:option(Value,"addition_arg",translate("Additional Server Args"),translate("Additional Args for upstream dns servers"))
o.default=""
o.rempty=true
o.optional=true
return m
