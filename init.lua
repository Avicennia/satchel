-- luacheck: globals satchel minetest _
local modn = minetest.get_current_modname()
local modp = minetest.get_modpath(modn)
local modstore = minetest.get_mod_storage()
satchel = {typefaces = {"roman","arabic","thoranic","han"}, textures = {"satchel_panel","tsukura","brito","olliy","easeltest","brickstest","wickertest","shaggy","trunk2","canarium","stuc"}}

-- Init

dofile(modp.."/settings.lua")
satchel.ringrad = 1.4
satchel.ringreg = {}
minetest.register_on_mods_loaded(function()
    if(satchel.config.disable_select_callbacks)then
        for n=1,#satchel.dq do
            minetest.override_item(satchel.dq[n], {on_rightclick=function() end})
        end
    end
    if(satchel.config.require_craft)then
        local item = satchel.mtg_recipe_starter_item[1]
        local MTG = minetest.registered_items[item or "default:apple"] and minetest.register_craft({type = "shapeless",output = modn..":trust_0",recipe = {item or "default:apple"}})
    end
end)

local storedsettings = satchel.config.custom_settings and minetest.deserialize(modstore:get_string("ring_settings"))
satchel.settings =  storedsettings or {}

-----------------------------------------------------------------
-- Register Calls
-----------------------------------------------------------------
minetest.register_on_joinplayer(function(player) local name = player:get_player_name(); satchel.settings[name] = satchel.settings[name] or {} return satchel.config.superimpose_default_inventory and minetest.after(3,function()player:set_inventory_formspec("size[4.62,0.2] label[0,0;Press again to toggle your Satchel] background[-0.2,-0.3;5.1,1.2;notice.png]")end) end)
minetest.register_on_leaveplayer(function(player) return satchel.ringreg[player:get_player_name()] and satchel.ringreg[player:get_player_name()]:unbuild() end)
minetest.register_on_dieplayer(function(player) return satchel.ringreg[player:get_player_name()] and satchel.ringreg[player:get_player_name()]:unbuild(), player:set_inventory_formspec("size[4.62,0.2] label[0,0;Press again to toggle your Satchel] background[-0.2,-0.3;5.1,1.2;notice.png]") end)
minetest.register_on_shutdown(function() modstore:set_string("ring_settings",minetest.serialize(satchel.settings)) end)
minetest.register_on_player_receive_fields(function(player, formname) return formname == "" and  satchel.invring_summon(player:get_player_name(), "main") end)

-----------------------------------------------------------------
-- File Load
-----------------------------------------------------------------
dofile(modp.."/ring.lua")
dofile(modp.."/ent.lua")
dofile(modp.."/tools.lua")


-----------------------------------------------------------------
-- Particle Stuff
-----------------------------------------------------------------

satchel.feedback = {}
satchel.feedback.show_trust = function(pos, tex)
minetest.add_particlespawner({
    amount = 10,
    time = 1,
    minpos = {x=pos.x-1.1, y=pos.y-0.4, z=pos.z-1.1},
    maxpos = {x=pos.x+1.1, y=pos.y+0.4, z=pos.z+1.1},
    minvel = {x=0, y=0.2, z=0},
    maxvel = {x=0, y=0.4, z=0},
    minacc = {x=0, y=0, z=0},
    maxacc = {x=0, y=0.5, z=0},
    minexptime = 1.7,
    maxexptime = 3,
    minsize = 1,
    maxsize = 1.6,
    collisiondetection = false,
    collision_removal = false,
    vertical = true,
    texture = tex,
    glow = 12
})
end
