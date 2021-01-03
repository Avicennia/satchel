local modn = minetest.get_current_modname()
local modp = minetest.get_modpath(modn)
local modstore = minetest.get_mod_storage()
satchel = {typefaces = {"roman","arabic","thoranic","han"}}

function say(x) 
    return type(x) == "string" and minetest.chat_send_all(x) or type(x) ~= "string" and minetest.chat_send_all(minetest.serialize(x))
end

-- Init

dofile(modp.."/settings.lua")
satchel.ringrad = 1.3
satchel.ringreg = {}

local storedsettings = satchel.config.custom_settings and minetest.deserialize(modstore:get_string("ring_settings"))
satchel.settings =  storedsettings or {}

-----------------------------------------------------------------
-- Register Calls
-----------------------------------------------------------------
minetest.register_on_joinplayer(function(player) local name = player:get_player_name() satchel.settings[name] = satchel.settings[name] or {} return satchel.config.superimpose_default_inventory and player:set_inventory_formspec("size[4.62,0.2] label[0,0;Press again to toggle your Satchel] background[-0.2,-0.3;5.1,1.2;notice.png]") end)
minetest.register_on_leaveplayer(function(player) return satchel.ringreg[player:get_player_name()] and satchel.ringreg[player:get_player_name()]:unbuild() end)
minetest.register_on_dieplayer(function(player) return satchel.ringreg[player:get_player_name()] and satchel.ringreg[player:get_player_name()]:unbuild() end)
minetest.register_on_shutdown(function() modstore:set_string("ring_settings",minetest.serialize(satchel.settings)) end)
minetest.register_on_player_receive_fields(function(player, formname, fields) return formname == "" and  satchel.invring_summon(player:get_player_name(), "main",_,"brito.png") end)

-----------------------------------------------------------------
-- File Load
-----------------------------------------------------------------
dofile(modp.."/proc.lua")
dofile(modp.."/ent.lua")
dofile(modp.."/commands.lua")
dofile(modp.."/tools.lua")
dofile(modp.."/particles.lua")

--satchel.config = nil
