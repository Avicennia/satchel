-- luacheck: globals satchel minetest _
local modn = minetest.get_current_modname()
local do_whitelist = satchel.config.whitelist_enabled
local do_crafting = satchel.config.require_craft
local function reveal(p,x)
    return minetest.chat_send_player(p,x)
end
minetest.register_craftitem(modn..":wand",
    {
        description = "Wand of the Astroid",
        inventory_image = "tetracuspid.png",
        inventory_overlay = "tetracuspid.png",
        stack_max = 1,
        range = 4.0,
        liquids_pointable = false,
        on_secondary_use = function(_, user)
            satchel.invring_summon(user and user:get_player_name(), "main")
            return nil
        end,
        on_use = function(_, user, pointed_thing)
            if(pointed_thing and pointed_thing.under)then
                local pos = pointed_thing.under
                local name = user:get_player_name()
                local tab,owner = {},nil
                local meta = minetest.get_meta(pos)
                for k,v in pairs(meta:to_table().fields)do
                    if(string.find(k,"satchel_player:"))then
                        local nam,val = string.sub(k,string.find(k,":")+1),tonumber(v)
                        tab[nam] = v and val
                        if(val==3)then owner = nam end
                    end
                end
                local userval = not owner and true or tab[name] and tab[name] > 0
                if(owner and owner ~= name and not userval)then reveal(name,"This container belongs to "..owner.."!") end
                return user:get_player_control().rmb and satchel.invring_summon(user and name, "main") or userval and minetest.get_inventory({type = "node", pos = pos}) and (not minetest.is_protected(pos,name)) and satchel.invring_summon_fixed(pos,"main",name,nil,nil,nil,nil,nil) and nil or nil
            end
        end
    })
if(do_crafting)then minetest.register_craft({type = "shapeless",output = modn..":wand",recipe = {modn..":trust_3",modn..":trust_3"}}) end
if(do_whitelist)then
    for n = 0, 3 do
        minetest.register_craftitem(modn..":trust_"..n,{
            description = "Trusty Heart lv."..n,
            inventory_image = "heart_"..n..".png",
            inventory_overlay = "heart_"..n..".png",
            stack_max = 1,
            range = 4.0,
            groups = {satchel_trust = n},
            on_use = function(_, user, pointed_thing)
                if(pointed_thing and pointed_thing.under)then
                    local pos = pointed_thing and pointed_thing.under
                    local uname = user:get_player_name()
                    if(pos and minetest.get_inventory({type = "node", pos = pos}) and user:get_player_control().sneak)then
                        local meta = minetest.get_meta(pos)
                        local owner
                        local whitelist = meta:to_table().fields
                        for k,v in pairs(meta:to_table().fields) do
                            if(string.find(k,"satchel_player:") and v == "3")then
                                owner = string.sub(k,string.find(k,":")+1)
                            end
                        end
                        if(owner and owner == uname and n~= 0)then
                            local tl = meta:get_int("satchel_trust_level") or 0
                            local it = meta:get_int("satchel_is_trusting")
                            meta:set_int("satchel_trust_level", (n < 3) and n or n == 3 and tl)
                            meta:set_int("satchel_is_trusting", n == 3 and (it < 1 and 1 or 0) or it)
                            satchel.feedback.show_trust(pos, "heart_3.png")
                            satchel.feedback.show_trust(pos, "heart_"..n..".png")
                            if not(meta:get_int("satchel_trust_level") == tl) then
                                reveal(uname, "Trust level changed from "..tl.." to "..meta:get_int("satchel_trust_level").."!")
                            end
                            reveal(uname, meta:get_int("satchel_is_trusting") == 0 and "No longer accepting new trustees!" or "Now accepting new trustees!")
                        elseif(owner and owner == uname and n == 0)then
                            for k,_ in pairs(whitelist)do
                                if(string.find(k,"satchel_player:"))then
                                    meta:set_int(k,0)
                                end
                            end
                            satchel.feedback.show_trust(pos, "heart_"..n..".png")
                            reveal(uname, "Trusted players reset!")
                        elseif(not owner and n == 3)then
                            meta:set_int("satchel_player:"..uname, 3)
                            satchel.feedback.show_trust(pos, "heart_"..n..".png")
                            reveal(uname, "Owner set to "..uname.."!")
                        elseif(owner and uname and owner ~= uname)then
                            local trusting = meta:get_int("satchel_is_trusting")
                            local tier = trusting > 0 and n <= meta:get_int("satchel_trust_level") and n
                            meta:set_int("satchel_player:"..uname, tier and tier or 0)
                            return tier and not satchel.feedback.show_trust(pos, "heart_"..n..".png") and reveal(uname, "Trust level of "..tier.." assigned to "..uname.."!") or nil
                        end
                    elseif(pos and minetest.get_inventory({type = "node", pos = pos}) and not user:get_player_control().sneak)then
                        local tab = {}
                        local meta = minetest.get_meta(pos)
                        for k,v in pairs(meta:to_table().fields)do
                            if(string.find(k,"satchel_player:"))then
                                tab[string.sub(k,string.find(k,":")+1)] = v and tonumber(v)
                            end
                        end
                        local tab2 = string.sub(minetest.serialize(tab),7)

                        return n == 3 and tab[uname] == 3 and reveal(uname, tab2) or nil
                    end
                end
                return nil
            end,
            on_secondary_use = function()
                return nil
            end

        })
        if(do_crafting)then
            minetest.register_craft({type = "shapeless",output = modn..":trust_"..(n<3 and n+1 or 0),recipe = {modn..":trust_"..n}})
        end
    end
end

minetest.register_node(modn..":empty",{
    description = "DEBUG_empty",
    tiles = {},
    drawtype = "mesh",
    mesh = "",
    groups = {DEBUG = 1}
})
minetest.register_tool(modn..":select",
    {
        description = "DEBUG_selection",
        inventory_image = "hand.png",
        inventory_overlay = "hand.png",
        wield_scale = {x = 1, y = 1, z = 1},
        stack_max = 0,
        range = 0,
        liquids_pointable = false,
    })

-----------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------
    local do_whitelist = satchel.config.whitelist_enabled
    local do_custom_settings = satchel.config.custom_settings

-- DebugCommands
minetest.register_chatcommand("invring", {
    params = "Opens ring of player on admin request",
    description = "Remove privilege from player",
    privs = {privs=true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        satchel.invring_summon(name, "main")
    end
})

minetest.register_chatcommand("invringclose", {
    params = "Closes ring of player on admin request",
    description = "Remove privilege from player",
    privs = {privs=true},
    func = function(name, param)
        return satchel.ringreg[name] and satchel.ringreg[name]:unbuild()
    end
})

minetest.register_chatcommand("invringlist", {
    params = "Displays rings of all players to user <admin>",
    description = "Remove privilege from player",
    privs = {privs=true},
    func = function(name, param)
        local t,n = {},0
        for k,_ in pairs(satchel.ringreg)do
            n = n + 1
            t[n] = k
        end
        return reveal(name, minetest.serialize(t))
    end
})

if(do_custom_settings)then
    minetest.register_chatcommand("satchel_settinglist", {
        params = "Displays settings of all players to user <admin>",
        description = "Remove privilege from player",
        privs = {privs=true},
        func = function(name, param)
            reveal(name, minetest.serialize(satchel.settings) or "error")
        end
    })


    -- User Commands
    minetest.register_chatcommand("satchel", {
        params = "Changes player setting value as requested",
        description = "Remove privilege from player",
        privs = {interact=true},
        func = function(name, param)
            local spcs = function(param, n)
                return string.find(param, " ",n or 1)
            end
            local space1 = spcs(param)
            local setting = space1 and string.sub( param, 1,space1-1) or nil
            local value = space1 and string.sub(param, space1+1) or nil
            local options = {radius = 1.6, height = 2, speed = 2.4, typeface = 4, texture = #satchel.textures or 4}
            if(setting and options[setting])then
                local v = tonumber(value)
                v = v and (setting ~= "speed" and v > 0 or setting == "speed" and v >=0) and v <= options[setting] and v or 1
                local t = satchel.settings[name]
                t[setting] = v
                satchel.settings[name] = t
                reveal(name, "Your "..setting.." value was set to "..v.."!")
            end
        end
    })
    minetest.register_chatcommand("satchel_mysettinglist", {
        params = "Shows player's own settinglist to player",
        description = "Remove privilege from player",
        privs = {interact=true},
        func = function(name, param)
            return satchel.settings[name] ~= nil and reveal(name, minetest.serialize(satchel.settings[name]))
        end
    })
end
if(do_whitelist)then
    minetest.register_chatcommand("satchel_whitelist", {
        params = "Adds a player to callers whitelist with a given value",
        description = "Remove privilege from player",
        privs = {interact=true},
        func = function(name, param)
            local spcs = function(param, n)
                return string.find(param, " ",n or 1)
            end
            local space1 = spcs(param)
            local pname = space1 and string.sub( param, 1,space1-1)
            local value = pname and tonumber(string.sub(param, space1+1))
            local ring = satchel.ringreg[name]
            if(ring and value and value < 3)then
                ring:whitelist_add(pname,value)
                reveal(name, "Added "..pname.." to your satchel whitelist at trust level "..value.."!")
            end
        end
    })
    minetest.register_chatcommand("satchel_whitelist_clear", {
        params = "<name> <privilege>",
        description = "Clear player whitelist trustees",
        privs = {interact=true},
        func = function(name, param)
            local ring = satchel.ringreg[name]
            if(ring)then
                ring.whitelist = {}
                ring.whitelist[name] = 3
            end
        end
    })

    satchel.show_whitelist = function(name)
        local ring = satchel.ringreg[name]
        if(ring)then
            local n = 0
            for k,v in pairs(ring.whitelist)do
                n = n + 1
                reveal(name,n..") Player: "..k.."  "..n..") Trust level: "..v)
            end
        end
    end
    minetest.register_chatcommand("satchel_mywhitelist", {
        params = "Show whitelist to player",
        description = "Remove privilege from player",
        privs = {interact=true},
        func = function(name, param)
            satchel.show_whitelist(name)
        end
    })
end
