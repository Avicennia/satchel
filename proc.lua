-- luacheck: globals satchel minetest ItemStack
local modn = minetest.get_current_modname()
local do_immobilize = satchel.config.immobilize_on_summon
local do_whitelist = satchel.config.whitelist_enabled
local do_count_nametags = satchel.config.count_nametags
local do_custom_settings = satchel.config.custom_settings
local _ = nil
-----------------------------------------------------------------
-- UTIL functions
-----------------------------------------------------------------
local rutil = {}
rutil.id = function(x)
    return satchel.ringreg[x] and satchel.ringreg[x]
end

satchel.poltorec = function(pol, ori)
    local r = pol.r or pol[1]
    local thet = pol.thet or pol[2]
    thet = (thet/180)*math.pi
    local x,z = r*math.sin(thet), r*math.cos(thet)
    x,z = thet > 90 and thet < 270 and -x or x, thet > 180 and thet < 360 and -z or z
    return {x = x + ori.x, y = ori.y, z = z + ori.z}
end
---

-----------------------------------------------------------------
-- Stack Exchange (Not the cool one you're thinking of) functions
-----------------------------------------------------------------
local io = {}
io.stack_compat = function(data,ind1,ind2,frac)--- WIP
    local inv = data.inv
    local s1,s2 = inv:get_stack(data.list, ind1), inv:get_stack(data.list, ind2)
    local frac = frac == 1 and s1:get_count() or s1:get_count() == 1 and 1 or frac or 1
    local n1, n2 = s1:get_name(), s2:get_name()
    local dt = (n1 == n2 or n2 == "")
    if(dt)then
        local wr = s1:get_wear()
        local leftover =s2:add_item(ItemStack{name = s1:get_name(),count =s1:get_count()/frac})
        local taken =s1:take_item(s1:get_count()/frac)
        s1:set_count(s1:get_count()+leftover:get_count())
        s1:set_name(s1:get_count() > 0 and s2:get_name() or "air")
        if(wr)then s2:set_wear(wr) end
        inv:set_stack(data.list, ind1, s1)
        inv:set_stack(data.list, ind2, s2)
    end

end

io.whitelist_check = function(id, name)
    return satchel.ringreg[id]:whitelist_check(name)
end
io.whitelist_has_owner = function(id)
    return satchel.ringreg[id]:whitelist_has_owner()
end


io.ring_exchange = function(id1,id2,ind1,ind2,frac)
    local r1,r2 = rutil.id(id1),rutil.id(id2)
    local inv1,inv2 = r1.inv, r2.inv
    local s1,s2 = inv1:get_stack("main",ind1),inv2:get_stack("main",ind2)
    local n1, n2 = s1:get_name(), s2:get_name()
    local dt = (n1 == n2 or n2 == "")
    if(dt)then
        local frac = frac == 1 and s1:get_count() or s1:get_count() == 1 and 1 or frac or 1
        local leftover = s2:add_item(ItemStack{name = s1:get_name(),count =s1:get_count()/frac})
        local taken = s1:take_item(s1:get_count()/frac)
        s1:set_count(s1:get_count()+leftover:get_count())
        s1:set_name(s1:get_count() > 0 and s2:get_name() or "air")
        inv1:set_stack(r1.list, ind1, s1)
        inv2:set_stack(r2.list, ind2, s2)
    end
end
---


-----------------------------------------------------------------
-- Ring component object functions
-----------------------------------------------------------------
local invring = {}
invring.add_invent = function(id,ind,pos) -- Spawns an Inventory Entity (currently just itemstack entity) at pos.
    if(id and ind and pos)then
        local name = modn..":testent"
        local invent = minetest.add_entity(pos, name, minetest.serialize({id = id,ind =ind}))
        return invent end
end

invring.add_pedent = function(id,ind,pos) -- Spawns an item-pedestal entity at pos.
    if(id and ind)then
        local data = satchel.ringreg[id]
        local pos = pos or data.pos
        local pedent = minetest.add_entity({x = pos.x, y = pos.y-(0.07-0.025), z = pos.z}, modn..":entped", minetest.serialize({id = id,ind =ind}))
        return pedent end
end

invring.add_selent = function(id,ind,pos)
    local selent = minetest.add_entity({x = pos.x, y = pos.y-(0.07-0.025), z = pos.z}, modn..":selent", minetest.serialize({id = id,ind =ind}))
    return selent
end
---

-----------------------------------------------------------------
-- Ring "Class"
-----------------------------------------------------------------
satchel.add_invring = function(ownerref, listname, listsize, radius, texture, tf, inv, summoner)
    local ring = {
        owner = ownerref,
        form = tf, -- false is player ring, true is node ring
        pos = tf and minetest.deserialize(ownerref) or minetest.get_player_by_name(ownerref):get_pos(),
        inv = inv or tf and minetest.get_inventory({type = "node", pos = minetest.deserialize(ownerref)}) or minetest.get_inventory({type = "player", name = ownerref}),
        list = listname,
        size = listsize or 32,
        radius = radius,
        typeface = 1,
        summoner = tf and summoner,
        texture = texture,
        selected = {},
        whitelist = {[ownerref]=not tf and 3 or nil},-- keyed table w/ k = name, v = tier (one of 1 or 2 to denote input-only or i and o access)
        ents = {
            ped = {},
            ite = {},
            sel = nil
        }
    }
    function ring:build()
        local size,pos,ref = self.size,self.pos, self.owner
        local int,settings = 360/size, do_custom_settings and satchel.settings[self.summoner or ref] or {}
        for n = 1, size, 1 do
            local thet = n*int
            local pos2, stack = satchel.poltorec({settings.radius or self.radius,thet},pos),self.inv:get_stack(self.list,n)
            pos2.y = pos2.y + (settings.height or 1)
            self.ents.ped[n] = {pos = pos2, stack = stack, obj = invring.add_pedent(ref,n,pos2)}
            pos2.y = pos2.y+0.13 -- height offset for visibility of item-ent
            self.ents.ite[n] = {pos = pos2, stack = stack, obj = invring.add_invent(ref,n,pos2)}
        end
        self.selected = {id = ref, ind = 0}
        if(do_whitelist and self.summoner)then
            local tab = {}
            local meta = minetest.get_meta(pos)
            for k,v in pairs(meta:to_table().fields)do
                if(string.find(k,"satchel_player:"))then
                    local n = string.sub(k,string.find(k,":")+1)
                    tab[n] = tonumber(v)
                end
            end
            self.whitelist = tab
        end
        return self:update(), do_immobilize and self:mobility_shift()
    end

    function ring:mobility_shift()
        local p = not self.summoner and self.owner or false
        p = p and minetest.get_player_by_name(p)

        local pp = p and p:get_physics_override()
        return p and p:set_physics_override({speed = pp.speed > 0 and 0 or 1, gravity = 1, jump = pp.jump > 0 and 0 or 1, sneak = pp.sneak and false or true, sneak_glitch = pp.sneak_glitch, new_move = pp.new_move})
    end

    function ring:update()
        local inv = self.inv
        if(#self.ents.ite > 0)then
            for n = 1, self.size do
                local stack = inv:get_stack(self.list,n)
                local iname,icount = stack:get_name(), stack:get_count()
                local props_ped = self.ents.ped[n].obj:get_properties()
                local props_ite = self.ents.ite[n].obj:get_properties()
                props_ped.infotext = minetest.registered_items[iname] and minetest.registered_items[iname].description.."\nCount: "..icount or "UNKNOWN_ITEM \nCount: " .. icount
                props_ite.textures,props_ite.nametag = {iname ~= "" and iname or modn..":empty"},do_count_nametags and icount or nil
                self.ents.ped[n].obj:set_properties(props_ped)
                self.ents.ite[n].obj:set_properties(props_ite)
                local p = self.ents.ped[n].pos
                if(not minetest.get_node(p))then
                    return self:unbuild()
                end
            end
        end
        return true
    end

    function ring:select(t1,t2,pname,frac)
        -- t1 is the origin stack, t2 is from the remote stack. Frac is one of [nil], 1, or 2 denoting full stack, one-from-stack, or half-stack for transfer count.
        local compat = {}
        compat.id = (t1.id == t2.id)
        if(compat.id)then
            compat.indices = t1.ind == t2.ind
            if(not compat.indices and t1.ind ~= 0 and t2 ~= 0)then -- two diff slots, same ring
                local s1 = do_whitelist and io.whitelist_has_owner(t1.id) and (io.whitelist_check(t1.id, pname) or 0) or 2
                local v = s1 > 0 and satchel.ringreg[t1.id]:update() and io.stack_compat(satchel.ringreg[t1.id],t1.ind,t2.ind,frac)
                satchel.ringreg[t1.id]:update()
                self:clear_selected()
                t1.ind = 0
            elseif(not compat.indices and t1.ind == 0)then
                t1.ind = t2.ind
                self:show_selected()
            elseif(compat.indices)then
                t1.ind = 0
                self:clear_selected()
            else t1.ind = t2.ind
            end
        elseif(not compat.id)then
            if(t1.ind == 0 and t2.ind ~= 0)then
                t1.id = t2.id
                t1.ind = t2.ind
                self:show_selected()
            elseif(t1.ind ~= 0 and t2.ind ~=0)then
                local o1,o2 = do_whitelist and io.whitelist_has_owner(t1.id),do_whitelist and io.whitelist_has_owner(t2.id)
                local s1,s2 =do_whitelist and o1 and (io.whitelist_check(t1.id,pname) or 0) or 2, do_whitelist and o2 and (io.whitelist_check(t2.id, pname) or 0) or 2
                if(s1 > 1 and s2 >= 1)then
                    satchel.ringreg[t1.id]:update()
                    satchel.ringreg[t2.id]:update()
                    io.ring_exchange(t1.id,t2.id,t1.ind,t2.ind,frac)
                    satchel.ringreg[t1.id]:update()
                    satchel.ringreg[t2.id]:update()
                    t1.ind = t2.ind
                end
                self:clear_selected()
                t1.ind = 0
            end
        end
    end

    function ring:show_selected()
        self:clear_selected()
        local s = self.selected
        local tf = s.id == self.owner
        if(s and s.ind > 0)then
            local pos = tf and self.ents.ped[self.selected.ind].pos or satchel.ringreg[s.id].ents.ped[s.ind].pos
            pos = {x = pos.x, y = pos.y, z = pos.z}
            pos.y = pos.y + 0.4
            local selection_entity = invring.add_selent(tf and self.owner or s.id,tf and self.selected.ind or s.ind,pos)
            self.ents.sel = selection_entity
        end
    end

    function ring:clear_selected()
        return self.ents.sel and self.ents.sel:remove()
    end

    function ring:whitelist_add(name,level) -- Add whitelist hooks for external name-to-name use
        local level = level or 1
        self.whitelist[name] = level
    end

    function ring:whitelist_has_owner()
        local o
        for _,v in pairs(self.whitelist)do
            o = v == 3 or o
        end
        return o
    end

    function ring:whitelist_check(name)
        return self.whitelist[name]
    end

    function ring:whitelist_remove(name)
        self.whitelist[name] = nil
    end

    function ring:unbuild()
        local s = do_immobilize and self:mobility_shift(); s = nil
        for n = 1, #self.ents.ped do
            self.ents.ped[n].obj:remove()
            self.ents.ite[n].obj:remove()
        end
        self.vv = self.ents.sel and self.ents.sel:remove()
        satchel.ringreg[self.owner] = nil
    end
    satchel.ringreg[ownerref] = not satchel.ringreg[ownerref] and ring or satchel.ringreg[ownerref]:unbuild()
end
-----------------------------------------------------------------
-- Ring Summoning functions
-----------------------------------------------------------------
satchel.invring_summon = function(ref, list, radius, texture)
    local player,radius = minetest.get_player_by_name(ref), radius or satchel.ringrad
    local list, inv = list or "main", player and player:get_inventory()
    local size = inv and inv:get_size(list) -- Default inventory size in slots
    local texture = texture or satchel.settings[ref] and satchel.settings[ref].texture and satchel.textures[satchel.settings[ref].texture]..".png" or "satchel_panel.png"
    if(ref and list and size and texture and inv and radius)then satchel.add_invring(ref, list, size, radius,texture, nil, inv) end
    return satchel.ringreg[ref] and satchel.ringreg[ref]:build() and true
end
satchel.invring_summon_fixed = function(pos, list, summoner, size, radius, texture)
    local inv,radius = minetest.get_inventory({type = "node", pos = pos}), radius or satchel.ringrad
    local size = size or inv:get_size(list)
    local ref = minetest.serialize(pos)
    local texture = texture or satchel.settings[summoner] and satchel.settings[summoner].texture and satchel.textures[satchel.settings[summoner].texture]..".png" or "satchel_panel.png"
    if(ref and summoner and inv and size and texture and list and radius)then satchel.add_invring(ref, list, size, radius,texture, true, inv, summoner) end
    return true, satchel.ringreg[ref] and satchel.ringreg[ref]:build()
end
---
