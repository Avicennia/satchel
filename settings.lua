
-- Mod Initialization Settings
-- Feel free to change these  as you like

satchel.config = {
    count_nametags = false,
    whitelist_enabled = true,
    ring_entity_rotation = true,
    immobilize_on_summon = true,
    custom_settings = true,
    superimpose_default_inventory = true,
    require_craft = true
}

--[[for k,v in pairs(defaults)do
    minetest.settings:set_bool(k,v)
    satchel.config[k] =minetest.settings:get_bool(k)
end]] -- WIP, to implement through settingtypes.txt when post-5.1 setting glitch is resolved.