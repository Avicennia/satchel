local modn = minetest.get_current_modname()
local modp = minetest.get_modpath(modn)
local modstore = minetest.get_mod_storage()
satchel = {typefaces = {"roman","arabic","thoranic","han"}}
dofile(modp.."/proc.lua")
dofile(modp.."/ent.lua")
dofile(modp.."/commands.lua")
function say(x) 
    return type(x) == "string" and minetest.chat_send_all(x) or type(x) ~= "string" and minetest.chat_send_all(minetest.serialize(x))
end

local function reveal(p,x)
    return minetest.chat_send_player(p,x)
end
-- Init
local defaults = {
    count_nametags = true,
    whitelist_enabled = true,
    ring_entity_rotation = true,
    immobilize_on_summon = true,
    container_inherit_settings = true}

for k,v in pairs(defaults)do
    minetest.settings:set_bool(k,v)
    --satchel.config[k] =minetest.settings:get_bool(k)
end
satchel.config = minetest.settings:to_table()
satchel.ringrad = 1.3
satchel.ringreg = {}
local storedsettings = minetest.deserialize(modstore:get_string("ring_settings"))
minetest.after(3,function()say(storedsettings) end)
satchel.settings =  storedsettings or {}
minetest.register_on_joinplayer(function(player) player:set_inventory_formspec("") satchel.settings[player:get_player_name()] = satchel.settings[player:get_player_name()] or {} end)
minetest.register_on_leaveplayer(function(player) return satchel.ringreg[player:get_player_name()] and satchel.ringreg[player:get_player_name()]:unbuild() end)
minetest.register_on_dieplayer(function(player) return satchel.ringreg[player:get_player_name()] and satchel.ringreg[player:get_player_name()]:unbuild() end)
minetest.register_on_shutdown(function() modstore:set_string("ring_settings",minetest.serialize(satchel.settings)) end)
minetest.register_on_player_receive_fields(function(player, formname, fields) return formname == "" and  satchel.invring_summon(player:get_player_name(), "main",_,"brito.png") end)
minetest.register_tool(modn..":hammer",
{
    description = "Hammer",
    --groups = {},
    inventory_image = "hand.png",
    inventory_overlay = "hand.png",
    wield_scale = {x = 1, y = 1, z = 1},
    stack_max = 1,
    range = 4.0,
    liquids_pointable = false,
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 0,
    },
    on_secondary_use = function(itemstack, user, pointed_thing) 
		
	end,
    on_use = function(itemstack, user, pointed_thing)
        local pos = pointed_thing.under
        local node,name = minetest.get_node(pos), user:get_player_name()
        return minetest.get_inventory({type = "node", pos = pos})and (not minetest.is_protected(pos,name)) and satchel.invring_summon_fixed(pos,"main", name)
	end,
   
   
})
minetest.register_node(modn..":empty",{
    description = "DEBUG_empty",
    tiles = {},
    drawtype = "mesh",
    mesh = "",
    groups = {DEBUG = 1}
})
for n = 0, 3 do
minetest.register_craftitem(modn..":trust_"..n,{
    description = "Trusty Heart lv."..n,
    inventory_image = "heart_"..n..".png",
    inventory_overlay = "heart_"..n..".png",
    stack_max = 1,
    range = 4.0,
    groups = {satchel_trust = n},
    on_use = function(itemstack, user, pointed_thing)
        if(pointed_thing and pointed_thing.under)then
        local pos = pointed_thing and pointed_thing.under
        local node = minetest.get_node(pos)
        local uname = user:get_player_name()
        if(pos and --[[minetest.get_inventory({type = "node", pos = pos}) and]] user:get_player_control().sneak)then
            local meta = minetest.get_meta(pos)
            local owner
            local whitelist = meta:to_table().fields
            for k,v in pairs(meta:to_table().fields) do
                if(string.find(k,"satchel_player:") and v == "3")then
                    owner = string.sub(k,string.find(k,":")+1)
                else end
            end
            if(owner and owner == uname and n~= 0)then
                local tl = meta:get_int("satchel_trust_level") or 0
                local it = meta:get_int("satchel_is_trusting")
                meta:set_int("satchel_trust_level", (n < 3) and n or n == 3 and tl)
                meta:set_int("satchel_is_trusting", n == 3 and (it < 1 and 1 or 0) or it)
                reveal(uname, "Trust level changed from "..tl.." to "..meta:get_int("satchel_trust_level").."!")
                reveal(uname, meta:get_int("satchel_is_trusting") == 0 and "No longer accepting new trustees!" or "Now accepting new trustees!")
            elseif(owner and owner == uname and n == 0)then
                for k,v in pairs(whitelist)do
                    if(string.find(k,"satchel_player:"))then
                    meta:set_int(k,0)
                    else end
                end
                reveal(uname, "Trusted players reset!")
            elseif(not owner and n == 3)then
                meta:set_int("satchel_player:"..uname, 3)
                reveal(uname, "Owner set to "..uname.."!")
            elseif(owner and uname and owner ~= uname)then
                local trusting = meta:get_int("satchel_is_trusting")
                local tier = trusting > 0 and n <= meta:get_int("satchel_trust_level") and n or 0
                meta:set_int("satchel_player:"..uname, tier)
                reveal(uname, "Trust level of "..tier.." assigned to "..uname.."!")
            end
        elseif(pos and minetest.get_inventory({type = "node", pos = pos}) and not user:get_player_control().sneak)then
            local tab = {}
            local meta = minetest.get_meta(pos)
            for k,v in pairs(meta:to_table().fields)do
                if(string.find(k,"satchel_player:"))then
                    local k = string.sub(k,string.find(k,":")+1)
                    tab[k] = tonumber(v) 
                else end
            end
            local tab = string.sub(minetest.serialize(tab),7)

            return n == 3 and reveal(uname, tab) or nil
        end
    else end
    return nil
    end,
    on_secondary_use = function(itemstack, user)
        return nil
    end
    
})
end

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing) 
    if(node.name == "chest:chest")then
        local meta, tab = minetest.get_meta(pos), {}
        for k,v in pairs(meta:to_table().fields) do
            if(string.find(k,"satchel"))then
                tab[k] = v
            else end
        end
        say(tab)
    end
end)