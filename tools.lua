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
