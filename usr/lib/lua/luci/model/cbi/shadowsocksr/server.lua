require"luci.http"
require"luci.dispatcher"
local a,e,t
local o="shadowsocksr"
local i={
"table",
"rc4",
"rc4-md5",
"rc4-md5-6",
"aes-128-cfb",
"aes-192-cfb",
"aes-256-cfb",
"aes-128-ctr",
"aes-192-ctr",
"aes-256-ctr",
"bf-cfb",
"camellia-128-cfb",
"camellia-192-cfb",
"camellia-256-cfb",
"cast5-cfb",
"des-cfb",
"idea-cfb",
"rc2-cfb",
"seed-cfb",
"salsa20",
"chacha20",
"chacha20-ietf",
}
local i={
"origin",
"verify_deflate",
"auth_sha1_v4",
"auth_aes128_sha1",
"auth_aes128_md5",
"auth_chain_a",
}
obfs={
"plain",
"http_simple",
"http_post",
"random_head",
"tls1.2_ticket_auth",
"tls1.2_ticket_fastauth",
}
a=Map(o)
e=a:section(TypedSection,"server_global",translate("Global Setting"))
e.anonymous=true
t=e:option(Flag,"enable_server",translate("Enable Server"))
t.rmempty=false
e=a:section(TypedSection,"server_config",translate("Server Setting"))
e.anonymous=true
e.addremove=true
e.template="cbi/tblsection"
e.extedit=luci.dispatcher.build_url("admin/services/shadowsocksr/server/%s")
function e.create(...)
local a=TypedSection.create(...)
if a then
luci.http.redirect(e.extedit%a)
return
end
end
t=e:option(Flag,"enable",translate("Enable"))
function t.cfgvalue(...)
return Value.cfgvalue(...)or translate("0")
end
t.rmempty=false
t=e:option(DummyValue,"type",translate("Server Type"))
function t.cfgvalue(...)
return Value.cfgvalue(...)or"ssr"
end
t=e:option(DummyValue,"server_port",translate("Server Port"))
function t.cfgvalue(...)
return Value.cfgvalue(...)or"-"
end
t=e:option(DummyValue,"username",translate("Username"))
function t.cfgvalue(...)
return Value.cfgvalue(...)or"-"
end
t=e:option(DummyValue,"encrypt_method",translate("Encrypt Method"))
function t.cfgvalue(...)
local e=Value.cfgvalue(...)
return e and e:upper()or"-"
end
t=e:option(DummyValue,"protocol",translate("Protocol"))
function t.cfgvalue(...)
return Value.cfgvalue(...)or"-"
end
t=e:option(DummyValue,"obfs",translate("Obfs"))
function t.cfgvalue(...)
return Value.cfgvalue(...)or"-"
end
return a
