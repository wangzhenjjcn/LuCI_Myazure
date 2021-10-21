local e=require"luci.model.network".init()
m=Map("mwan3",translate("MWAN - Globals"))
s=m:section(NamedSection,"globals","globals",nil)
n=s:option(ListValue,"local_source",
translate("Local source interface"),
translate("Use the IP address of this interface as source IP "..
"address for traffic initiated by the router itself"))
n:value("none")
n.default="none"
for t,e in ipairs(e:get_networks())do
if e:name()~="loopback"then
n:value(e:name())
end
end
n.rmempty=false
mask=s:option(
Value,
"mmx_mask",
translate("Firewall mask"),
translate("Enter value in hex, starting with <code>0x</code>"))
mask.datatype="hex(4)"
mask.default="0xff00"
return m
