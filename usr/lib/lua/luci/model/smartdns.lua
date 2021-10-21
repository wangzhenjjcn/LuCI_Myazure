require("nixio.fs")
require("luci.http")
require("luci.dispatcher")
require("nixio.fs")
local e=require"luci.model.uci".cursor()
module("luci.model.smartdns",package.seeall)
function get_config_option(o,a,t,i)
return e:get_first(o,a,t)or i
end
return m
