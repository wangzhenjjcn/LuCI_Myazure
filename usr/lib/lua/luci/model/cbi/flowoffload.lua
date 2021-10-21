local t,e,a
local o=require"luci.sys"
t=Map("flowoffload")
t.title=translate("Turbo ACC Acceleration Settings")
t.description=translate("Opensource Linux Flow Offload driver (Fast Path or HWNAT)")
t:append(Template("flow/status"))
e=t:section(TypedSection,"flow")
e.addremove=false
e.anonymous=true
flow=e:option(Flag,"flow_offloading",translate("Enable"))
flow.default=0
flow.rmempty=false
flow.description=translate("Enable software flow offloading for connections. (decrease cpu load / increase routing throughput)")
hw=e:option(Flag,"flow_offloading_hw",translate("HWNAT"))
hw.default=0
hw.rmempty=true
hw.description=translate("Enable Hardware NAT (depends on hw capability like MTK 762x)")
hw:depends("flow_offloading",1)
bbr=e:option(Flag,"bbr",translate("Enable BBR"))
bbr.default=0
bbr.rmempty=false
bbr.description=translate("Bottleneck Bandwidth and Round-trip propagation time (BBR)")
dns=e:option(Flag,"dns",translate("DNS Acceleration"))
dns.default=0
dns.rmempty=false
dns.description=translate("Enable DNS Cache Acceleration and anti ISP DNS pollution")
a=e:option(Value,"dns_server",translate("Upsteam DNS Server"))
a.default="114.114.114.114,114.114.115.115"
a.description=translate("Muitiple DNS server can saperate with ','")
a:depends("dns",1)
return t
