local modn = minetest.get_current_modname()

local do_rot = satchel.config.ring_entity_rotation
local do_custom_settings = satchel.config.custom_settings

local name = modn..":testent"
local ent = {
    physical = false,
    collide_with_objects = false,
    collisionbox = {-0.06, -0.06, -0.06, 0.06, 0.06, 0.06},
    selectionbox = {-0.06, -0.06, -0.06, 0.06, 0.06, 0.06},
    pointable = false,
    visual = "wielditem",
    visual_size = {x = 0.08, y = 0.07},
    makes_footstep_sound = false,
    backface_culling = true,
    nametag = "",
    nametag_color = "",
    static_save = false,

on_activate = function(self, stat)
    if(stat and stat ~= "")then
        local data = minetest.deserialize(stat) or {}
        self:set_ringdata(data.id,data.ind)
    end
    local obj = self.object
    local id,ind = self.ring_id, self.ring_index
    local data = satchel.ringreg[id]
    local invsize = data.size
    local stackref = data.ents.ped[ind].stack
    local wield = stackref:get_name() ~= "" and stackref:get_name() or modn..":empty"
    local pos = obj:get_pos()
    local settings = do_custom_settings and satchel.settings[data.summoner or data.owner]
    local light= minetest.get_node_light({x = pos.x, y = pos.y + 1, z = pos.z}) or 0
    light = light >= 10 and 0 or 14-light
    local props = obj:get_properties()
    props.textures[1] = wield
    props.automatic_rotate = do_rot and (wield ~= modn..":empty" and settings.speed or 0.41) or 0
    props.glow = light
    obj:set_properties(props)
    obj:set_armor_groups({immortal=1})
end,
}
function ent:set_ringdata(id, ind)
    self.ring_index = ind
    self.ring_id = id
end

minetest.register_entity(name, ent)

name = modn..":entped"
ent = {
    physical = false,
    collide_with_objects = false,
    collisionbox = {-0.12, -0.051, -0.12, 0.12, 0, 0.12},
    selectionbox = {-0.12, -0.051, -0.12, 0.12, 0, 0.12},
    pointable = true,
    visual = "cube",
    visual_size = {x = 0.18, y = 0.18},
    textures = {"satchel_panel.png","satchel_panel.png","satchel_panel.png","satchel_panel.png","satchel_panel.png","satchel_panel.png"},
    is_visible = true,
    automatic_rotate = 0,
    backface_culling = true,
    static_save = false,

on_activate = function(self, stat)
    local obj = self.object
    if(stat and stat ~= "")then
        local data = minetest.deserialize(stat) or {}
        self:set_ringdata(data.id,data.ind)
    end
    obj:set_armor_groups({immortal=1})
    local id = self.ring_id

    if(id)then
        local pos = obj:get_pos() -- position
        local data = satchel.ringreg[id]
        local light= minetest.get_node_light({x = pos.x, y = pos.y + 1, z = pos.z}) or 0--lighting
        light = light and light >= 10 and 0 or 14-light
        local props = obj:get_properties()
        props.glow = light
        if(not data.form)then -- Hotbar stuff (Player-only)
            local ind = self.ring_index
            local typeface = satchel.typefaces[satchel.settings[data.summoner or data.owner].typeface or 1]
            
            for n = 3, 6 do
                local tex = ind > 0 and ind < 10 and data.texture.."^"..typeface..ind..".png" or data.texture
                props.textures[n] = tex
            end 
            props.automatic_rotate = do_rot and (satchel.settings[data.summoner or data.owner].speed or 0.41) or 0
            obj:set_properties(props)
            
        end
    else obj:remove() end
end,
on_punch = function(self, puncher)
    local obj = self.object
    local prop = obj:get_properties()
    local id,ind = self.ring_id,self.ring_index
    local data = satchel.ringreg[id]
    local pname = puncher:is_player() and puncher:get_player_name()
    local remote = pname and satchel.ringreg[pname]
    return remote and remote:select(remote.selected,{id = id, ind = ind},pname,puncher:get_player_control().sneak and 1)
end,
on_rightclick = function(self,puncher)
    local obj = self.object
    local prop = obj:get_properties()
    local id,ind = self.ring_id,self.ring_index
    local data = satchel.ringreg[id]
    local pname = puncher:is_player() and puncher:get_player_name()
    local remote = (data) and pname and data.selected and satchel.ringreg[pname] 
    return remote and remote:select(remote.selected,{id = id, ind = ind},pname,2)
end
}
function ent:set_ringdata(id, ind)
    self.ring_index = ind
    self.ring_id = id
end
minetest.register_entity(name, ent)

local name = modn..":selent"
local ent = {
    physical = true,
    collide_with_objects = false,
    collisionbox = {-0.06, -0.06, -0.06, 0.06, 0.06, 0.06},
    selectionbox = {-0.06, -0.06, -0.06, 0.06, 0.06, 0.06},
    pointable = false,
    visual = "wielditem",
    visual_size = {x = 0.1, y = 0.13},
    textures = {modn..":select"},
    automatic_rotate = do_rot and 0.41 or 0,
    backface_culling = true,
    glow = 9,
    nametag = "",
    nametag_color = "",
    static_save = false,

on_activate = function(self, stat)
    if stat ~= "" and stat ~= nil then
        local data = minetest.deserialize(stat) or {}
        self:set_ringdata(data.id,data.ind)
    end
    self.object:set_armor_groups({immortal=1})
end
}
function ent:set_ringdata(id, ind)
    self.ring_index = ind
    self.ring_id = id
end
minetest.register_entity(name, ent)
