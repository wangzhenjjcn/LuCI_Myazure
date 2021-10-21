local e=require"luci.sys"
local t=e.exec("cat /usr/share/adbyby/dnsmasq.adblock | wc -l")
local t=0
if nixio.fs.access("/usr/share/adbyby/dnsmasq.adblock")then
t=tonumber(e.exec("cat /usr/share/adbyby/dnsmasq.adblock | wc -l"))
end
local a=0
if nixio.fs.access("/usr/share/adbyby/rules/")then
a=tonumber(e.exec("/usr/share/adbyby/rule-count '/usr/share/adbyby/rules/'"))
end
m=Map("adbyby")
s=m:section(TypedSection,"adbyby")
s.anonymous=true
o=s:option(Flag,"block_ios")
o.title=translate("Block Apple iOS OTA update")
o.default=0
o.rmempty=false
o=s:option(Flag,"cron_mode")
o.title=translate("Update the rule at 6 a.m. every morning and restart adbyby")
o.default=0
o.rmempty=false
o=s:option(DummyValue,"ad_data",translate("Adblock Plus Data"))
o.rawhtml=true
o.template="adbyby/refresh"
o.value=t.." "..translate("Records")
o=s:option(DummyValue,"rule_data",translate("Subscribe 3rd Rules Data"))
o.rawhtml=true
o.template="adbyby/refresh"
o.value=a.." "..translate("Records")
o.description=translate("AdGuardHome / Host / DNSMASQ rules auto-convert")
o=s:option(Button,"delete",translate("Delete All Subscribe Rules"))
o.inputstyle="reset"
o.write=function()
e.exec("rm -f /usr/share/adbyby/rules/data/* /usr/share/adbyby/rules/host/*")
e.exec("/etc/init.d/adbyby restart 2>&1 &")
luci.http.redirect(luci.dispatcher.build_url("admin","services","adbyby","advanced"))
end
o=s:option(DynamicList,"subscribe_url",translate("Anti-AD Rules Subscribe"))
o.rmempty=true
return m