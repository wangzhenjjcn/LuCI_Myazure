local e=require"luci.tools.webadmin"
local r=require"luci.model.network"
local f=require"luci.util"
local c=require"luci.sys".net
local d=require"nixio.fs"
arg[1]=arg[1]or""
m=Map("wireless","",
translate("The <em>Device Configuration</em> section covers physical settings of the radio "..
"hardware such as channel, transmit power or antenna selection which are shared among all "..
"defined wireless networks (if the radio hardware is multi-SSID capable). Per network settings "..
"like encryption or operation mode are grouped in the <em>Interface Configuration</em>."))
m:chain("network")
m:chain("firewall")
m.redirect=luci.dispatcher.build_url("admin/network/wireless")
local u
function m.on_commit(e)
local e=r:get_wifinet(arg[1])
if u and e then
u.section=e.sid
m.title=luci.util.pcdata(e:get_i18n())
end
end
r.init(m.uci)
local o=r:get_wifinet(arg[1])
local e=o and o:get_device()
if not o or not e then
luci.http.redirect(luci.dispatcher.build_url("admin/network/wireless"))
return
end
function m.parse(i)
local t=m:formvalue("cbid.wireless.%s.country"%e:name())
local a=m:get(e:name(),"country")
if m:formvalue("cbid.wireless.%s.__toggle"%e:name())then
if e:get("disabled")=="1"or o:get("disabled")=="1"then
o:set("disabled",nil)
else
o:set("disabled","1")
end
e:set("disabled",nil)
r:commit("wireless")
luci.sys.call("(env -i /bin/ubus call network reload) >/dev/null 2>/dev/null")
luci.http.redirect(luci.dispatcher.build_url("admin/network/wireless",arg[1]))
return
end
Map.parse(i)
if m:get(e:name(),"type")=="mac80211"and t and t~=a then
luci.sys.call("iw reg set %s"%f.shellquote(t))
luci.http.redirect(luci.dispatcher.build_url("admin/network/wireless",arg[1]))
return
end
end
m.title=luci.util.pcdata(o:get_i18n())
local function h(e)
local a=e.txpwrlist or{}
local t=tonumber(e.txpower_offset)or 0
local e={}
local o=-1
local i,i
for i,a in ipairs(a)do
local i=a.dbm+t
local t=math.floor(10^(i/10))
if t~=o then
o=t
e[#e+1]={
display_dbm=i,
display_mw=t,
driver_dbm=a.dbm,
driver_mw=a.mw
}
end
end
return e
end
local function l(e,t)
e=tonumber(e)
if e~=nil then
local a,a
for a,t in ipairs(t)do
if t.driver_dbm>=e then
return t.driver_dbm
end
end
end
return e or""
end
local a=luci.sys.wifi.getiwinfo(arg[1])
local n=a.hwmodelist or{}
local h=h(a)
local w=l(e:get("txpower"),h)
s=m:section(NamedSection,e:name(),"wifi-device",translate("Device Configuration"))
s.addremove=false
s:tab("general",translate("General Setup"))
s:tab("macfilter",translate("MAC-Filter"))
s:tab("advanced",translate("Advanced Settings"))
st=s:taboption("general",DummyValue,"__status",translate("Status"))
st.template="admin_network/wifi_status"
st.ifname=arg[1]
en=s:taboption("general",Button,"__toggle")
if e:get("disabled")=="1"or o:get("disabled")=="1"then
en.title=translate("Wireless network is disabled")
en.inputtitle=translate("Enable")
en.inputstyle="apply"
else
en.title=translate("Wireless network is enabled")
en.inputtitle=translate("Disable")
en.inputstyle="reset"
end
local t=e:get("type")
local i=e:get("antenna")
local i=nil
local y,y
if o:mode()~="sta"then
for t,e in ipairs(e:get_wifinets())do
if e:mode()=="sta"and e:get("disabled")~="1"then
if not i then
i={}
i.channel=e:channel()
i.names={}
end
i.names[#i.names+1]=e:shortname()
end
end
end
if i then
ch=s:taboption("general",DummyValue,"choice",translate("Channel"))
ch.value=translatef("Locked to channel %s used by: %s",
i.channel or"(auto)",table.concat(i.names,", "))
else
ch=s:taboption("general",Value,"_mode_freq",'<br />'..translate("Operating frequency"))
ch.hwmodes=n
ch.htmodes=a.htmodelist
ch.freqlist=a.freqlist
ch.template="cbi/wireless_modefreq"
function ch.cfgvalue(t,e)
return{
m:get(e,"hwmode")or"",
m:get(e,"channel")or"auto",
m:get(e,"htmode")or""
}
end
function ch.formvalue(e,t)
return{
m:formvalue(e:cbid(t)..".band")or(n.g and"11g"or"11a"),
m:formvalue(e:cbid(t)..".channel")or"auto",
m:formvalue(e:cbid(t)..".htmode")or""
}
end
function ch.write(a,e,t)
m:set(e,"hwmode",t[1])
m:set(e,"channel",t[2])
m:set(e,"htmode",t[3])
end
noscan=s:taboption("general",Flag,"noscan",translate("Force 40MHz mode"),
translate("Always use 40MHz channels even if the secondary channel overlaps. Using this option does not comply with IEEE 802.11n-2009!"))
noscan.default=noscan.disabled
vendor_vht=s:taboption("general",Flag,"vendor_vht",translate("Enable 256-QAM"),translate("802.11n 2.4Ghz Only"))
vendor_vht.default=vendor_vht.disabled
end
if t=="mac80211"then
if#h>0 then
tp=s:taboption("general",ListValue,
"txpower",translate("Transmit Power"),"dBm")
tp.rmempty=true
tp.default=w
function tp.cfgvalue(...)
return l(Value.cfgvalue(...),h)
end
tp:value("",translate("auto"))
for t,e in ipairs(h)do
tp:value(e.driver_dbm,"%i dBm (%i mW)"
%{e.display_dbm,e.display_mw})
end
end
local e=a and a.countrylist
if e and#e>0 then
cc=s:taboption("advanced",ListValue,"country",translate("Country Code"),translate("Use ISO/IEC 3166 alpha2 country codes."))
cc.default=tostring(a and a.country or"00")
for t,e in ipairs(e)do
cc:value(e.alpha2,"%s - %s"%{e.alpha2,e.name})
end
else
s:taboption("advanced",Value,"country",translate("Country Code"),translate("Use ISO/IEC 3166 alpha2 country codes."))
end
legacyrates=s:taboption("advanced",Flag,"legacy_rates",translate("Allow legacy 802.11b rates"))
legacyrates.rmempty=false
legacyrates.default="1"
mubeamformer=s:taboption("advanced",Flag,"mu_beamformer",translate("MU-MIMO"))
mubeamformer.rmempty=false
mubeamformer.default="0"
s:taboption("advanced",Value,"distance",translate("Distance Optimization"),
translate("Distance to farthest network member in meters."))
local e=a and a.extant
if e and#e>0 then
ea=s:taboption("advanced",ListValue,"extant",translate("Antenna Configuration"))
for t,e in ipairs(e)do
ea:value(e.id,"%s (%s)"%{e.name,e.description})
if e.selected then
ea.default=e.id
end
end
end
s:taboption("advanced",Value,"frag",translate("Fragmentation Threshold"))
s:taboption("advanced",Value,"rts",translate("RTS/CTS Threshold"))
end
if t=="broadcom"then
tp=s:taboption("general",
(#h>0)and ListValue or Value,
"txpower",translate("Transmit Power"),"dBm")
tp.rmempty=true
tp.default=w
function tp.cfgvalue(...)
return l(Value.cfgvalue(...),h)
end
tp:value("",translate("auto"))
for t,e in ipairs(h)do
tp:value(e.driver_dbm,"%i dBm (%i mW)"
%{e.display_dbm,e.display_mw})
end
mode=s:taboption("advanced",ListValue,"hwmode",translate("Band"))
if n.b then
mode:value("11b","2.4GHz (802.11b)")
if n.g then
mode:value("11bg","2.4GHz (802.11b+g)")
end
end
if n.g then
mode:value("11g","2.4GHz (802.11g)")
mode:value("11gst","2.4GHz (802.11g + Turbo)")
mode:value("11lrs","2.4GHz (802.11g Limited Rate Support)")
end
if n.a then mode:value("11a","5GHz (802.11a)")end
if n.n then
if n.g then
mode:value("11ng","2.4GHz (802.11g+n)")
mode:value("11n","2.4GHz (802.11n)")
end
if n.a then
mode:value("11na","5GHz (802.11a+n)")
mode:value("11n","5GHz (802.11n)")
end
htmode=s:taboption("advanced",ListValue,"htmode",translate("HT mode (802.11n)"))
htmode:depends("hwmode","11ng")
htmode:depends("hwmode","11na")
htmode:depends("hwmode","11n")
htmode:value("HT20","20MHz")
htmode:value("HT40","40MHz")
end
ant1=s:taboption("advanced",ListValue,"txantenna",translate("Transmitter Antenna"))
ant1.widget="radio"
ant1:depends("diversity","")
ant1:value("3",translate("auto"))
ant1:value("0",translate("Antenna 1"))
ant1:value("1",translate("Antenna 2"))
ant2=s:taboption("advanced",ListValue,"rxantenna",translate("Receiver Antenna"))
ant2.widget="radio"
ant2:depends("diversity","")
ant2:value("3",translate("auto"))
ant2:value("0",translate("Antenna 1"))
ant2:value("1",translate("Antenna 2"))
s:taboption("advanced",Flag,"frameburst",translate("Frame Bursting"))
s:taboption("advanced",Value,"distance",translate("Distance Optimization"))
s:taboption("advanced",Value,"country",translate("Country Code"))
s:taboption("advanced",Value,"maxassoc",translate("Connection Limit"))
end
if t=="prism2"then
s:taboption("advanced",Value,"txpower",translate("Transmit Power"),"att units").rmempty=true
s:taboption("advanced",Flag,"diversity",translate("Diversity")).rmempty=false
s:taboption("advanced",Value,"txantenna",translate("Transmitter Antenna"))
s:taboption("advanced",Value,"rxantenna",translate("Receiver Antenna"))
end
s=m:section(NamedSection,o.sid,"wifi-iface",translate("Interface Configuration"))
u=s
s.addremove=false
s.anonymous=true
s.defaults.device=e:name()
s:tab("general",translate("General Setup"))
s:tab("encryption",translate("Wireless Security"))
s:tab("macfilter",translate("MAC-Filter"))
s:tab("advanced",translate("Advanced Settings"))
mode=s:taboption("general",ListValue,"mode",translate("Mode"))
mode.override_values=true
mode:value("ap",translate("Access Point"))
mode:value("sta",translate("Client"))
mode:value("adhoc",translate("Ad-Hoc"))
meshid=s:taboption("general",Value,"mesh_id",translate("Mesh Id"))
meshid:depends({mode="mesh"})
meshfwd=s:taboption("advanced",Flag,"mesh_fwding",translate("Forward mesh peer traffic"))
meshfwd.rmempty=false
meshfwd.default="1"
meshfwd:depends({mode="mesh"})
ssid=s:taboption("general",Value,"ssid",translate("<abbr title=\"Extended Service Set Identifier\">ESSID</abbr>"))
ssid.datatype="maxlength(32)"
ssid:depends({mode="ap"})
ssid:depends({mode="sta"})
ssid:depends({mode="adhoc"})
ssid:depends({mode="ahdemo"})
ssid:depends({mode="monitor"})
ssid:depends({mode="ap-wds"})
ssid:depends({mode="sta-wds"})
ssid:depends({mode="wds"})
bssid=s:taboption("general",Value,"bssid",translate("<abbr title=\"Basic Service Set Identifier\">BSSID</abbr>"))
network=s:taboption("general",Value,"network",translate("Network"),
translate("Choose the network(s) you want to attach to this wireless interface or "..
"fill out the <em>create</em> field to define a new network."))
network.rmempty=true
network.template="cbi/network_netlist"
network.widget="checkbox"
network.novirtual=true
function network.write(o,a,t)
local e=r:get_interface(a)
if e then
if t=='-'then
t=m:formvalue(o:cbid(a)..".newnet")
if t and#t>0 then
local t=r:add_network(t,{proto="none"})
if t then t:add_interface(e)end
else
local t=e:get_network()
if t then t:del_interface(e)end
end
else
local a
for a,t in ipairs(e:get_networks())do
t:del_interface(e)
end
for t in f.imatch(t)do
local t=r:get_network(t)
if t then
if not t:is_empty()then
t:set("type","bridge")
end
t:add_interface(e)
end
end
end
end
end
if t=="mac80211"then
if d.access("/usr/sbin/iw")then
mode:value("mesh","802.11s")
end
mode:value("ahdemo",translate("Pseudo Ad-Hoc (ahdemo)"))
mode:value("monitor",translate("Monitor"))
bssid:depends({mode="adhoc"})
bssid:depends({mode="sta"})
bssid:depends({mode="sta-wds"})
mp=s:taboption("macfilter",ListValue,"macfilter",translate("MAC-Address Filter"))
mp:depends({mode="ap"})
mp:depends({mode="ap-wds"})
mp:value("",translate("disable"))
mp:value("allow",translate("Allow listed only"))
mp:value("deny",translate("Allow all except listed"))
ml=s:taboption("macfilter",DynamicList,"maclist",translate("MAC-List"))
ml.datatype="macaddr"
ml:depends({macfilter="allow"})
ml:depends({macfilter="deny"})
c.mac_hints(function(e,t)ml:value(e,"%s (%s)"%{e,t})end)
mode:value("ap-wds","%s (%s)"%{translate("Access Point"),translate("WDS")})
mode:value("sta-wds","%s (%s)"%{translate("Client"),translate("WDS")})
function mode.write(t,e,a)
if a=="ap-wds"then
ListValue.write(t,e,"ap")
m.uci:set("wireless",e,"wds",1)
elseif a=="sta-wds"then
ListValue.write(t,e,"sta")
m.uci:set("wireless",e,"wds",1)
else
ListValue.write(t,e,a)
m.uci:delete("wireless",e,"wds")
end
end
function mode.cfgvalue(e,t)
local e=ListValue.cfgvalue(e,t)
local t=m.uci:get("wireless",t,"wds")=="1"
if e=="ap"and t then
return"ap-wds"
elseif e=="sta"and t then
return"sta-wds"
else
return e
end
end
hidden=s:taboption("general",Flag,"hidden",translate("Hide <abbr title=\"Extended Service Set Identifier\">ESSID</abbr>"))
hidden:depends({mode="ap"})
hidden:depends({mode="ap-wds"})
wmm=s:taboption("general",Flag,"wmm",translate("WMM Mode"))
wmm:depends({mode="ap"})
wmm:depends({mode="ap-wds"})
wmm.default=wmm.enabled
isolate=s:taboption("advanced",Flag,"isolate",translate("Isolate Clients"),
translate("Prevents client-to-client communication"))
isolate:depends({mode="ap"})
isolate:depends({mode="ap-wds"})
ifname=s:taboption("advanced",Value,"ifname",translate("Interface name"),translate("Override default interface name"))
ifname.optional=true
disassoc_low_ack=s:taboption("general",Flag,"disassoc_low_ack",translate("Disassociate On Low Acknowledgement"),translate("Allow AP mode to disconnect STAs based on low ACK condition"))
disassoc_low_ack.default=disassoc_low_ack.enabled
end
if t=="broadcom"then
mode:value("wds",translate("WDS"))
mode:value("monitor",translate("Monitor"))
hidden=s:taboption("general",Flag,"hidden",translate("Hide <abbr title=\"Extended Service Set Identifier\">ESSID</abbr>"))
hidden:depends({mode="ap"})
hidden:depends({mode="adhoc"})
hidden:depends({mode="wds"})
isolate=s:taboption("advanced",Flag,"isolate",translate("Separate Clients"),
translate("Prevents client-to-client communication"))
isolate:depends({mode="ap"})
s:taboption("advanced",Flag,"doth","802.11h")
s:taboption("advanced",Flag,"wmm",translate("WMM Mode"))
bssid:depends({mode="wds"})
bssid:depends({mode="adhoc"})
end
if t=="prism2"then
mode:value("wds",translate("WDS"))
mode:value("monitor",translate("Monitor"))
hidden=s:taboption("general",Flag,"hidden",translate("Hide <abbr title=\"Extended Service Set Identifier\">ESSID</abbr>"))
hidden:depends({mode="ap"})
hidden:depends({mode="adhoc"})
hidden:depends({mode="wds"})
bssid:depends({mode="sta"})
mp=s:taboption("macfilter",ListValue,"macpolicy",translate("MAC-Address Filter"))
mp:value("",translate("disable"))
mp:value("allow",translate("Allow listed only"))
mp:value("deny",translate("Allow all except listed"))
ml=s:taboption("macfilter",DynamicList,"maclist",translate("MAC-List"))
ml:depends({macpolicy="allow"})
ml:depends({macpolicy="deny"})
c.mac_hints(function(e,t)ml:value(e,"%s (%s)"%{e,t})end)
s:taboption("advanced",Value,"rate",translate("Transmission Rate"))
s:taboption("advanced",Value,"frag",translate("Fragmentation Threshold"))
s:taboption("advanced",Value,"rts",translate("RTS/CTS Threshold"))
end
encr=s:taboption("encryption",ListValue,"encryption",translate("Encryption"))
encr.override_values=true
encr.override_depends=true
encr:depends({mode="ap"})
encr:depends({mode="sta"})
encr:depends({mode="adhoc"})
encr:depends({mode="ahdemo"})
encr:depends({mode="ap-wds"})
encr:depends({mode="sta-wds"})
encr:depends({mode="mesh"})
cipher=s:taboption("encryption",ListValue,"cipher",translate("Cipher"))
cipher:depends({encryption="wpa"})
cipher:depends({encryption="wpa2"})
cipher:depends({encryption="psk"})
cipher:depends({encryption="psk2"})
cipher:depends({encryption="wpa-mixed"})
cipher:depends({encryption="psk-mixed"})
cipher:value("auto",translate("auto"))
cipher:value("ccmp",translate("Force CCMP (AES)"))
cipher:value("tkip",translate("Force TKIP"))
cipher:value("tkip+ccmp",translate("Force TKIP and CCMP (AES)"))
function encr.cfgvalue(t,e)
local e=tostring(ListValue.cfgvalue(t,e))
if e=="wep"then
return"wep-open"
elseif e and e:match("%+")then
return(e:gsub("%+.+$",""))
end
return e
end
function encr.write(o,t,i)
local e=tostring(encr:formvalue(t))
local a=tostring(cipher:formvalue(t))
if i=="wpa"or i=="wpa2"then
o.map.uci:delete("wireless",t,"key")
end
if e and(a=="tkip"or a=="ccmp"or a=="tkip+ccmp")then
e=e.."+"..a
end
o.map:set(t,"encryption",e)
end
function cipher.cfgvalue(t,e)
local e=tostring(ListValue.cfgvalue(encr,e))
if e and e:match("%+")then
e=e:gsub("^[^%+]+%+","")
if e=="aes"then e="ccmp"
elseif e=="tkip+aes"then e="tkip+ccmp"
elseif e=="aes+tkip"then e="tkip+ccmp"
elseif e=="ccmp+tkip"then e="tkip+ccmp"
end
end
return e
end
function cipher.write(t,e)
return encr:write(e)
end
encr:value("none","No Encryption")
encr:value("wep-open",translate("WEP Open System"),{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"},{mode="adhoc"},{mode="ahdemo"},{mode="wds"})
encr:value("wep-shared",translate("WEP Shared Key"),{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"},{mode="adhoc"},{mode="ahdemo"},{mode="wds"})
if t=="mac80211"or t=="prism2"then
local t=d.access("/usr/sbin/wpa_supplicant")
local e=d.access("/usr/sbin/hostapd")
local a=(os.execute("hostapd -veap >/dev/null 2>/dev/null")==0)
local i=(os.execute("wpa_supplicant -veap >/dev/null 2>/dev/null")==0)
local o=(os.execute("hostapd -vsae >/dev/null 2>/dev/null")==0)
local n=(os.execute("wpa_supplicant -vsae >/dev/null 2>/dev/null")==0)
if e and t then
encr:value("psk","WPA-PSK",{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"},{mode="adhoc"})
encr:value("psk2","WPA2-PSK",{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"},{mode="adhoc"})
encr:value("psk-mixed","WPA-PSK/WPA2-PSK Mixed Mode",{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"},{mode="adhoc"})
if o and n then
encr:value("sae","WPA3-SAE",{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"},{mode="adhoc"},{mode="mesh"})
encr:value("sae-mixed","WPA2-PSK/WPA3-SAE Mixed Mode",{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"},{mode="adhoc"})
end
if a and i then
encr:value("wpa","WPA-EAP",{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"})
encr:value("wpa2","WPA2-EAP",{mode="ap"},{mode="sta"},{mode="ap-wds"},{mode="sta-wds"})
end
elseif e and not t then
encr:value("psk","WPA-PSK",{mode="ap"},{mode="ap-wds"})
encr:value("psk2","WPA2-PSK",{mode="ap"},{mode="ap-wds"})
encr:value("psk-mixed","WPA-PSK/WPA2-PSK Mixed Mode",{mode="ap"},{mode="ap-wds"})
if o then
encr:value("sae","WPA3-SAE",{mode="ap"},{mode="ap-wds"})
encr:value("sae-mixed","WPA2-PSK/WPA3-SAE Mixed Mode",{mode="ap"},{mode="ap-wds"})
end
if a then
encr:value("wpa","WPA-EAP",{mode="ap"},{mode="ap-wds"})
encr:value("wpa2","WPA2-EAP",{mode="ap"},{mode="ap-wds"})
end
encr.description=translate(
"WPA-Encryption requires wpa_supplicant (for client mode) or hostapd (for AP "..
"and ad-hoc mode) to be installed."
)
elseif not e and t then
encr:value("psk","WPA-PSK",{mode="sta"},{mode="sta-wds"},{mode="adhoc"})
encr:value("psk2","WPA2-PSK",{mode="sta"},{mode="sta-wds"},{mode="adhoc"})
encr:value("psk-mixed","WPA-PSK/WPA2-PSK Mixed Mode",{mode="sta"},{mode="sta-wds"},{mode="adhoc"})
if n then
encr:value("sae","WPA3-SAE",{mode="sta"},{mode="sta-wds"},{mode="mesh"})
encr:value("sae-mixed","WPA2-PSK/WPA3-SAE Mixed Mode",{mode="sta"},{mode="sta-wds"})
end
if i then
encr:value("wpa","WPA-EAP",{mode="sta"},{mode="sta-wds"})
encr:value("wpa2","WPA2-EAP",{mode="sta"},{mode="sta-wds"})
end
encr.description=translate(
"WPA-Encryption requires wpa_supplicant (for client mode) or hostapd (for AP "..
"and ad-hoc mode) to be installed."
)
else
encr.description=translate(
"WPA-Encryption requires wpa_supplicant (for client mode) or hostapd (for AP "..
"and ad-hoc mode) to be installed."
)
end
elseif t=="broadcom"then
encr:value("psk","WPA-PSK")
encr:value("psk2","WPA2-PSK")
encr:value("psk+psk2","WPA-PSK/WPA2-PSK Mixed Mode")
end
auth_server=s:taboption("encryption",Value,"auth_server",translate("Radius-Authentication-Server"))
auth_server:depends({mode="ap",encryption="wpa"})
auth_server:depends({mode="ap",encryption="wpa2"})
auth_server:depends({mode="ap-wds",encryption="wpa"})
auth_server:depends({mode="ap-wds",encryption="wpa2"})
auth_server.rmempty=true
auth_server.datatype="host(0)"
auth_port=s:taboption("encryption",Value,"auth_port",translate("Radius-Authentication-Port"),translatef("Default %d",1812))
auth_port:depends({mode="ap",encryption="wpa"})
auth_port:depends({mode="ap",encryption="wpa2"})
auth_port:depends({mode="ap-wds",encryption="wpa"})
auth_port:depends({mode="ap-wds",encryption="wpa2"})
auth_port.rmempty=true
auth_port.datatype="port"
auth_secret=s:taboption("encryption",Value,"auth_secret",translate("Radius-Authentication-Secret"))
auth_secret:depends({mode="ap",encryption="wpa"})
auth_secret:depends({mode="ap",encryption="wpa2"})
auth_secret:depends({mode="ap-wds",encryption="wpa"})
auth_secret:depends({mode="ap-wds",encryption="wpa2"})
auth_secret.rmempty=true
auth_secret.password=true
acct_server=s:taboption("encryption",Value,"acct_server",translate("Radius-Accounting-Server"))
acct_server:depends({mode="ap",encryption="wpa"})
acct_server:depends({mode="ap",encryption="wpa2"})
acct_server:depends({mode="ap-wds",encryption="wpa"})
acct_server:depends({mode="ap-wds",encryption="wpa2"})
acct_server.rmempty=true
acct_server.datatype="host(0)"
acct_port=s:taboption("encryption",Value,"acct_port",translate("Radius-Accounting-Port"),translatef("Default %d",1813))
acct_port:depends({mode="ap",encryption="wpa"})
acct_port:depends({mode="ap",encryption="wpa2"})
acct_port:depends({mode="ap-wds",encryption="wpa"})
acct_port:depends({mode="ap-wds",encryption="wpa2"})
acct_port.rmempty=true
acct_port.datatype="port"
acct_secret=s:taboption("encryption",Value,"acct_secret",translate("Radius-Accounting-Secret"))
acct_secret:depends({mode="ap",encryption="wpa"})
acct_secret:depends({mode="ap",encryption="wpa2"})
acct_secret:depends({mode="ap-wds",encryption="wpa"})
acct_secret:depends({mode="ap-wds",encryption="wpa2"})
acct_secret.rmempty=true
acct_secret.password=true
wpakey=s:taboption("encryption",Value,"_wpa_key",translate("Key"))
wpakey:depends("encryption","psk")
wpakey:depends("encryption","psk2")
wpakey:depends("encryption","psk+psk2")
wpakey:depends("encryption","psk-mixed")
wpakey:depends("encryption","sae")
wpakey:depends("encryption","sae-mixed")
wpakey.datatype="wpakey"
wpakey.rmempty=true
wpakey.password=true
wpakey.cfgvalue=function(t,e,t)
local e=m.uci:get("wireless",e,"key")
if e=="1"or e=="2"or e=="3"or e=="4"then
return nil
end
return e
end
wpakey.write=function(e,t,a)
e.map.uci:set("wireless",t,"key",a)
e.map.uci:delete("wireless",t,"key1")
end
wepslot=s:taboption("encryption",ListValue,"_wep_key",translate("Used Key Slot"))
wepslot:depends("encryption","wep-open")
wepslot:depends("encryption","wep-shared")
wepslot:value("1",translatef("Key #%d",1))
wepslot:value("2",translatef("Key #%d",2))
wepslot:value("3",translatef("Key #%d",3))
wepslot:value("4",translatef("Key #%d",4))
wepslot.cfgvalue=function(t,e)
local e=tonumber(m.uci:get("wireless",e,"key"))
if not e or e<1 or e>4 then
return 1
end
return e
end
wepslot.write=function(t,a,e)
t.map.uci:set("wireless",a,"key",e)
end
local e
for e=1,4 do
wepkey=s:taboption("encryption",Value,"key"..e,translatef("Key #%d",e))
wepkey:depends("encryption","wep-open")
wepkey:depends("encryption","wep-shared")
wepkey.datatype="wepkey"
wepkey.rmempty=true
wepkey.password=true
function wepkey.write(a,t,e)
if e and(#e==5 or#e==13)then
e="s:"..e
end
return Value.write(a,t,e)
end
end
if t=="mac80211"or t=="prism2"then
ieee80211k=s:taboption("encryption",Flag,"ieee80211k",translate("802.11k"),translate("Enables The 802.11k standard provides information to discover the best available access point"))
ieee80211k:depends({mode="ap",encryption="wpa"})
ieee80211k:depends({mode="ap",encryption="wpa2"})
ieee80211k:depends({mode="ap-wds",encryption="wpa"})
ieee80211k:depends({mode="ap-wds",encryption="wpa2"})
ieee80211k:depends({mode="ap",encryption="psk"})
ieee80211k:depends({mode="ap",encryption="psk2"})
ieee80211k:depends({mode="ap",encryption="psk-mixed"})
ieee80211k:depends({mode="ap-wds",encryption="psk"})
ieee80211k:depends({mode="ap-wds",encryption="psk2"})
ieee80211k:depends({mode="ap-wds",encryption="psk-mixed"})
ieee80211k:depends({mode="ap",encryption="sae"})
ieee80211k:depends({mode="ap",encryption="sae-mixed"})
ieee80211k:depends({mode="ap-wds",encryption="sae"})
ieee80211k:depends({mode="ap-wds",encryption="sae-mixed"})
ieee80211k.rmempty=true
rrmneighborreport=s:taboption("encryption",Flag,"rrm_neighbor_report",translate("Enable neighbor report via radio measurements"))
rrmneighborreport.default=rrmneighborreport.enabled
rrmneighborreport:depends({ieee80211k="1"})
rrmneighborreport.rmempty=true
rrmbeaconreport=s:taboption("encryption",Flag,"rrm_beacon_report",translate("Enable beacon report via radio measurements"))
rrmbeaconreport.default=rrmbeaconreport.enabled
rrmbeaconreport:depends({ieee80211k="1"})
rrmbeaconreport.rmempty=true
ieee80211v=s:taboption("encryption",Flag,"ieee80211v",translate("802.11v"),translate("Enables 802.11v allows client devices to exchange information about the network topology,tating overall improvement of the wireless network."))
ieee80211v:depends({mode="ap",encryption="wpa"})
ieee80211v:depends({mode="ap",encryption="wpa2"})
ieee80211v:depends({mode="ap-wds",encryption="wpa"})
ieee80211v:depends({mode="ap-wds",encryption="wpa2"})
ieee80211v:depends({mode="ap",encryption="psk"})
ieee80211v:depends({mode="ap",encryption="psk2"})
ieee80211v:depends({mode="ap",encryption="psk-mixed"})
ieee80211v:depends({mode="ap-wds",encryption="psk"})
ieee80211v:depends({mode="ap-wds",encryption="psk2"})
ieee80211v:depends({mode="ap-wds",encryption="psk-mixed"})
ieee80211v:depends({mode="ap",encryption="sae"})
ieee80211v:depends({mode="ap",encryption="sae-mixed"})
ieee80211v:depends({mode="ap-wds",encryption="sae"})
ieee80211v:depends({mode="ap-wds",encryption="sae-mixed"})
ieee80211v.rmempty=true
wnmsleepmode=s:taboption("encryption",Flag,"wnm_sleep_mode",translate("extended sleep mode for stations"))
wnmsleepmode.default=wnmsleepmode.disabled
wnmsleepmode:depends({ieee80211v="1"})
wnmsleepmode.rmempty=true
bsstransition=s:taboption("encryption",Flag,"bss_transition",translate("BSS Transition Management"))
bsstransition.default=bsstransition.disabled
bsstransition:depends({ieee80211v="1"})
bsstransition.rmempty=true
timeadvertisement=s:taboption("encryption",ListValue,"time_advertisement",translate("Time advertisement"))
timeadvertisement:depends({ieee80211v="1"})
timeadvertisement:value("0",translatef("disabled"))
timeadvertisement:value("2",translatef("UTC time at which the TSF timer is 0"))
timeadvertisement.rmempty=true
time_zone=s:taboption("encryption",Value,"time_zone",
translate("time zone"),translate("Local time zone as specified in 8.3 of IEEE Std 1003.1-2004"))
time_zone:depends({time_advertisement="2"})
time_zone.placeholder="UTC8"
time_zone.rmempty=true
local e=(os.execute("hostapd -v11r 2>/dev/null || hostapd -veap 2>/dev/null")==0)
ieee80211r=s:taboption("encryption",Flag,"ieee80211r",
translate("802.11r Fast Transition"),
translate("Enables fast roaming among access points that belong "..
"to the same Mobility Domain"))
ieee80211r:depends({mode="ap",encryption="wpa"})
ieee80211r:depends({mode="ap",encryption="wpa2"})
ieee80211r:depends({mode="ap-wds",encryption="wpa"})
ieee80211r:depends({mode="ap-wds",encryption="wpa2"})
ieee80211r:depends({mode="ap",encryption="sae"})
ieee80211r:depends({mode="ap",encryption="sae-mixed"})
ieee80211r:depends({mode="ap-wds",encryption="sae"})
ieee80211r:depends({mode="ap-wds",encryption="sae-mixed"})
if e then
ieee80211r:depends({mode="ap",encryption="psk"})
ieee80211r:depends({mode="ap",encryption="psk2"})
ieee80211r:depends({mode="ap",encryption="psk-mixed"})
ieee80211r:depends({mode="ap-wds",encryption="psk"})
ieee80211r:depends({mode="ap-wds",encryption="psk2"})
ieee80211r:depends({mode="ap-wds",encryption="psk-mixed"})
ieee80211r:depends({mode="ap",encryption="sae"})
ieee80211r:depends({mode="ap",encryption="sae-mixed"})
ieee80211r:depends({mode="ap-wds",encryption="sae"})
ieee80211r:depends({mode="ap-wds",encryption="sae-mixed"})
end
ieee80211r.rmempty=true
nasid=s:taboption("encryption",Value,"nasid",translate("NAS ID"),
translate("Used for two different purposes: RADIUS NAS ID and "..
"802.11r R0KH-ID. Not needed with normal WPA(2)-PSK."))
nasid:depends({mode="ap",encryption="wpa"})
nasid:depends({mode="ap",encryption="wpa2"})
nasid:depends({mode="ap-wds",encryption="wpa"})
nasid:depends({mode="ap-wds",encryption="wpa2"})
nasid:depends({ieee80211r="1"})
nasid.rmempty=true
mobility_domain=s:taboption("encryption",Value,"mobility_domain",
translate("Mobility Domain"),
translate("4-character hexadecimal ID"))
mobility_domain:depends({ieee80211r="1"})
mobility_domain.placeholder="4f57"
mobility_domain.datatype="and(hexstring,rangelength(4,4))"
mobility_domain.rmempty=true
reassociation_deadline=s:taboption("encryption",Value,"reassociation_deadline",
translate("Reassociation Deadline"),
translate("time units (TUs / 1.024 ms) [1000-65535]"))
reassociation_deadline:depends({ieee80211r="1"})
reassociation_deadline.placeholder="1000"
reassociation_deadline.datatype="range(1000,65535)"
reassociation_deadline.rmempty=true
ft_protocol=s:taboption("encryption",ListValue,"ft_over_ds",translate("FT protocol"))
ft_protocol:depends({ieee80211r="1"})
ft_protocol:value("1",translatef("FT over DS"))
ft_protocol:value("0",translatef("FT over the Air"))
ft_protocol.rmempty=true
ft_psk_generate_local=s:taboption("encryption",Flag,"ft_psk_generate_local",
translate("Generate PMK locally"),
translate("When using a PSK, the PMK can be generated locally without inter AP communications"))
ft_psk_generate_local:depends({ieee80211r="1"})
r0_key_lifetime=s:taboption("encryption",Value,"r0_key_lifetime",
translate("R0 Key Lifetime"),translate("minutes"))
r0_key_lifetime:depends({ieee80211r="1",ft_psk_generate_local=""})
r0_key_lifetime.placeholder="10000"
r0_key_lifetime.datatype="uinteger"
r0_key_lifetime.rmempty=true
r1_key_holder=s:taboption("encryption",Value,"r1_key_holder",
translate("R1 Key Holder"),
translate("6-octet identifier as a hex string - no colons"))
r1_key_holder:depends({ieee80211r="1",ft_psk_generate_local=""})
r1_key_holder.placeholder="00004f577274"
r1_key_holder.datatype="and(hexstring,rangelength(12,12))"
r1_key_holder.rmempty=true
pmk_r1_push=s:taboption("encryption",Flag,"pmk_r1_push",translate("PMK R1 Push"))
pmk_r1_push:depends({ieee80211r="1",ft_psk_generate_local=""})
pmk_r1_push.placeholder="0"
pmk_r1_push.rmempty=true
r0kh=s:taboption("encryption",DynamicList,"r0kh",translate("External R0 Key Holder List"),
translate("List of R0KHs in the same Mobility Domain. "..
"<br />Format: MAC-address,NAS-Identifier,128-bit key as hex string. "..
"<br />This list is used to map R0KH-ID (NAS Identifier) to a destination "..
"MAC address when requesting PMK-R1 key from the R0KH that the STA "..
"used during the Initial Mobility Domain Association."))
r0kh:depends({ieee80211r="1",ft_psk_generate_local=""})
r0kh.rmempty=true
r1kh=s:taboption("encryption",DynamicList,"r1kh",translate("External R1 Key Holder List"),
translate("List of R1KHs in the same Mobility Domain. "..
"<br />Format: MAC-address,R1KH-ID as 6 octets with colons,128-bit key as hex string. "..
"<br />This list is used to map R1KH-ID to a destination MAC address "..
"when sending PMK-R1 key from the R0KH. This is also the "..
"list of authorized R1KHs in the MD that can request PMK-R1 keys."))
r1kh:depends({ieee80211r="1",ft_psk_generate_local=""})
r1kh.rmempty=true
eaptype=s:taboption("encryption",ListValue,"eap_type",translate("EAP-Method"))
eaptype:value("tls","TLS")
eaptype:value("ttls","TTLS")
eaptype:value("peap","PEAP")
eaptype:value("fast","FAST")
eaptype:depends({mode="sta",encryption="wpa"})
eaptype:depends({mode="sta",encryption="wpa2"})
eaptype:depends({mode="sta-wds",encryption="wpa"})
eaptype:depends({mode="sta-wds",encryption="wpa2"})
cacert=s:taboption("encryption",FileUpload,"ca_cert",translate("Path to CA-Certificate"))
cacert:depends({mode="sta",encryption="wpa"})
cacert:depends({mode="sta",encryption="wpa2"})
cacert:depends({mode="sta-wds",encryption="wpa"})
cacert:depends({mode="sta-wds",encryption="wpa2"})
cacert.rmempty=true
clientcert=s:taboption("encryption",FileUpload,"client_cert",translate("Path to Client-Certificate"))
clientcert:depends({mode="sta",eap_type="tls",encryption="wpa"})
clientcert:depends({mode="sta",eap_type="tls",encryption="wpa2"})
clientcert:depends({mode="sta-wds",eap_type="tls",encryption="wpa"})
clientcert:depends({mode="sta-wds",eap_type="tls",encryption="wpa2"})
privkey=s:taboption("encryption",FileUpload,"priv_key",translate("Path to Private Key"))
privkey:depends({mode="sta",eap_type="tls",encryption="wpa2"})
privkey:depends({mode="sta",eap_type="tls",encryption="wpa"})
privkey:depends({mode="sta-wds",eap_type="tls",encryption="wpa2"})
privkey:depends({mode="sta-wds",eap_type="tls",encryption="wpa"})
privkeypwd=s:taboption("encryption",Value,"priv_key_pwd",translate("Password of Private Key"))
privkeypwd:depends({mode="sta",eap_type="tls",encryption="wpa2"})
privkeypwd:depends({mode="sta",eap_type="tls",encryption="wpa"})
privkeypwd:depends({mode="sta-wds",eap_type="tls",encryption="wpa2"})
privkeypwd:depends({mode="sta-wds",eap_type="tls",encryption="wpa"})
privkeypwd.rmempty=true
privkeypwd.password=true
auth=s:taboption("encryption",ListValue,"auth",translate("Authentication"))
auth:value("PAP","PAP",{eap_type="ttls"})
auth:value("CHAP","CHAP",{eap_type="ttls"})
auth:value("MSCHAP","MSCHAP",{eap_type="ttls"})
auth:value("MSCHAPV2","MSCHAPv2",{eap_type="ttls"})
auth:value("EAP-GTC")
auth:value("EAP-MD5")
auth:value("EAP-MSCHAPV2")
auth:value("EAP-TLS")
auth:depends({mode="sta",eap_type="fast",encryption="wpa2"})
auth:depends({mode="sta",eap_type="fast",encryption="wpa"})
auth:depends({mode="sta",eap_type="peap",encryption="wpa2"})
auth:depends({mode="sta",eap_type="peap",encryption="wpa"})
auth:depends({mode="sta",eap_type="ttls",encryption="wpa2"})
auth:depends({mode="sta",eap_type="ttls",encryption="wpa"})
auth:depends({mode="sta-wds",eap_type="fast",encryption="wpa2"})
auth:depends({mode="sta-wds",eap_type="fast",encryption="wpa"})
auth:depends({mode="sta-wds",eap_type="peap",encryption="wpa2"})
auth:depends({mode="sta-wds",eap_type="peap",encryption="wpa"})
auth:depends({mode="sta-wds",eap_type="ttls",encryption="wpa2"})
auth:depends({mode="sta-wds",eap_type="ttls",encryption="wpa"})
cacert2=s:taboption("encryption",FileUpload,"ca_cert2",translate("Path to inner CA-Certificate"))
cacert2:depends({mode="sta",auth="EAP-TLS",encryption="wpa"})
cacert2:depends({mode="sta",auth="EAP-TLS",encryption="wpa2"})
cacert2:depends({mode="sta-wds",auth="EAP-TLS",encryption="wpa"})
cacert2:depends({mode="sta-wds",auth="EAP-TLS",encryption="wpa2"})
clientcert2=s:taboption("encryption",FileUpload,"client_cert2",translate("Path to inner Client-Certificate"))
clientcert2:depends({mode="sta",auth="EAP-TLS",encryption="wpa"})
clientcert2:depends({mode="sta",auth="EAP-TLS",encryption="wpa2"})
clientcert2:depends({mode="sta-wds",auth="EAP-TLS",encryption="wpa"})
clientcert2:depends({mode="sta-wds",auth="EAP-TLS",encryption="wpa2"})
privkey2=s:taboption("encryption",FileUpload,"priv_key2",translate("Path to inner Private Key"))
privkey2:depends({mode="sta",auth="EAP-TLS",encryption="wpa"})
privkey2:depends({mode="sta",auth="EAP-TLS",encryption="wpa2"})
privkey2:depends({mode="sta-wds",auth="EAP-TLS",encryption="wpa"})
privkey2:depends({mode="sta-wds",auth="EAP-TLS",encryption="wpa2"})
privkeypwd2=s:taboption("encryption",Value,"priv_key2_pwd",translate("Password of inner Private Key"))
privkeypwd2:depends({mode="sta",auth="EAP-TLS",encryption="wpa"})
privkeypwd2:depends({mode="sta",auth="EAP-TLS",encryption="wpa2"})
privkeypwd2:depends({mode="sta-wds",auth="EAP-TLS",encryption="wpa"})
privkeypwd2:depends({mode="sta-wds",auth="EAP-TLS",encryption="wpa2"})
privkeypwd2.rmempty=true
privkeypwd2.password=true
identity=s:taboption("encryption",Value,"identity",translate("Identity"))
identity:depends({mode="sta",eap_type="fast",encryption="wpa2"})
identity:depends({mode="sta",eap_type="fast",encryption="wpa"})
identity:depends({mode="sta",eap_type="peap",encryption="wpa2"})
identity:depends({mode="sta",eap_type="peap",encryption="wpa"})
identity:depends({mode="sta",eap_type="ttls",encryption="wpa2"})
identity:depends({mode="sta",eap_type="ttls",encryption="wpa"})
identity:depends({mode="sta-wds",eap_type="fast",encryption="wpa2"})
identity:depends({mode="sta-wds",eap_type="fast",encryption="wpa"})
identity:depends({mode="sta-wds",eap_type="peap",encryption="wpa2"})
identity:depends({mode="sta-wds",eap_type="peap",encryption="wpa"})
identity:depends({mode="sta-wds",eap_type="ttls",encryption="wpa2"})
identity:depends({mode="sta-wds",eap_type="ttls",encryption="wpa"})
identity:depends({mode="sta",eap_type="tls",encryption="wpa2"})
identity:depends({mode="sta",eap_type="tls",encryption="wpa"})
identity:depends({mode="sta-wds",eap_type="tls",encryption="wpa2"})
identity:depends({mode="sta-wds",eap_type="tls",encryption="wpa"})
anonymous_identity=s:taboption("encryption",Value,"anonymous_identity",translate("Anonymous Identity"))
anonymous_identity:depends({mode="sta",eap_type="fast",encryption="wpa2"})
anonymous_identity:depends({mode="sta",eap_type="fast",encryption="wpa"})
anonymous_identity:depends({mode="sta",eap_type="peap",encryption="wpa2"})
anonymous_identity:depends({mode="sta",eap_type="peap",encryption="wpa"})
anonymous_identity:depends({mode="sta",eap_type="ttls",encryption="wpa2"})
anonymous_identity:depends({mode="sta",eap_type="ttls",encryption="wpa"})
anonymous_identity:depends({mode="sta-wds",eap_type="fast",encryption="wpa2"})
anonymous_identity:depends({mode="sta-wds",eap_type="fast",encryption="wpa"})
anonymous_identity:depends({mode="sta-wds",eap_type="peap",encryption="wpa2"})
anonymous_identity:depends({mode="sta-wds",eap_type="peap",encryption="wpa"})
anonymous_identity:depends({mode="sta-wds",eap_type="ttls",encryption="wpa2"})
anonymous_identity:depends({mode="sta-wds",eap_type="ttls",encryption="wpa"})
anonymous_identity:depends({mode="sta",eap_type="tls",encryption="wpa2"})
anonymous_identity:depends({mode="sta",eap_type="tls",encryption="wpa"})
anonymous_identity:depends({mode="sta-wds",eap_type="tls",encryption="wpa2"})
anonymous_identity:depends({mode="sta-wds",eap_type="tls",encryption="wpa"})
password=s:taboption("encryption",Value,"password",translate("Password"))
password:depends({mode="sta",eap_type="fast",encryption="wpa2"})
password:depends({mode="sta",eap_type="fast",encryption="wpa"})
password:depends({mode="sta",eap_type="peap",encryption="wpa2"})
password:depends({mode="sta",eap_type="peap",encryption="wpa"})
password:depends({mode="sta",eap_type="ttls",encryption="wpa2"})
password:depends({mode="sta",eap_type="ttls",encryption="wpa"})
password:depends({mode="sta-wds",eap_type="fast",encryption="wpa2"})
password:depends({mode="sta-wds",eap_type="fast",encryption="wpa"})
password:depends({mode="sta-wds",eap_type="peap",encryption="wpa2"})
password:depends({mode="sta-wds",eap_type="peap",encryption="wpa"})
password:depends({mode="sta-wds",eap_type="ttls",encryption="wpa2"})
password:depends({mode="sta-wds",eap_type="ttls",encryption="wpa"})
password.rmempty=true
password.password=true
end
if t=="mac80211"then
local e=(os.execute("hostapd -v11w 2>/dev/null || hostapd -veap 2>/dev/null")==0)
if e then
ieee80211w=s:taboption("encryption",ListValue,"ieee80211w",
translate("802.11w Management Frame Protection"),
translate("Requires the 'full' version of wpad/hostapd "..
"and support from the wifi driver <br />(as of Feb 2017: "..
"ath9k and ath10k, in LEDE also mwlwifi and mt76)"))
ieee80211w.default=""
ieee80211w.rmempty=true
ieee80211w:value("",translate("Disabled (default)"))
ieee80211w:value("1",translate("Optional"))
ieee80211w:value("2",translate("Required"))
ieee80211w:depends({mode="ap",encryption="wpa2"})
ieee80211w:depends({mode="ap-wds",encryption="wpa2"})
ieee80211w:depends({mode="ap",encryption="psk2"})
ieee80211w:depends({mode="ap",encryption="psk-mixed"})
ieee80211w:depends({mode="ap-wds",encryption="psk2"})
ieee80211w:depends({mode="ap-wds",encryption="psk-mixed"})
ieee80211w:depends({mode="ap",encryption="sae"})
ieee80211w:depends({mode="ap",encryption="sae-mixed"})
ieee80211w:depends({mode="ap-wds",encryption="sae"})
ieee80211w:depends({mode="ap-wds",encryption="sae-mixed"})
max_timeout=s:taboption("encryption",Value,"ieee80211w_max_timeout",
translate("802.11w maximum timeout"),
translate("802.11w Association SA Query maximum timeout"))
max_timeout:depends({ieee80211w="1"})
max_timeout:depends({ieee80211w="2"})
max_timeout.datatype="uinteger"
max_timeout.placeholder="1000"
max_timeout.rmempty=true
retry_timeout=s:taboption("encryption",Value,"ieee80211w_retry_timeout",
translate("802.11w retry timeout"),
translate("802.11w Association SA Query retry timeout"))
retry_timeout:depends({ieee80211w="1"})
retry_timeout:depends({ieee80211w="2"})
retry_timeout.datatype="uinteger"
retry_timeout.placeholder="201"
retry_timeout.rmempty=true
end
local e=s:taboption("encryption",Flag,"wpa_disable_eapol_key_retries",
translate("Enable key reinstallation (KRACK) countermeasures"),
translate("Complicates key reinstallation attacks on the client side by disabling retransmission of EAPOL-Key frames that are used to install keys. This workaround might cause interoperability issues and reduced robustness of key negotiation especially in environments with heavy traffic load."))
e:depends({mode="ap",encryption="wpa2"})
e:depends({mode="ap",encryption="psk2"})
e:depends({mode="ap",encryption="psk-mixed"})
e:depends({mode="ap-wds",encryption="wpa2"})
e:depends({mode="ap-wds",encryption="psk2"})
e:depends({mode="ap-wds",encryption="psk-mixed"})
e:depends({mode="ap",encryption="sae"})
e:depends({mode="ap",encryption="sae-mixed"})
e:depends({mode="ap-wds",encryption="sae"})
e:depends({mode="ap-wds",encryption="sae-mixed"})
end
if t=="mac80211"or t=="prism2"then
local t=d.access("/usr/sbin/wpa_supplicant")
local e=d.access("/usr/sbin/hostapd_cli")
if e and t then
wps=s:taboption("encryption",Flag,"wps_pushbutton",translate("Enable WPS pushbutton, requires WPA(2)-PSK"))
wps.enabled="1"
wps.disabled="0"
wps.rmempty=false
wps:depends("encryption","psk")
wps:depends("encryption","psk2")
wps:depends("encryption","psk-mixed")
end
end
return m
