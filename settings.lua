 -- luacheck: globals satchel minetest _

 -----------------------------------------------------------
-- Mod Initialization Config
-- Feel free to change these  as you like
------------------------------------------------------------

satchel.config = {
    count_nametags = false,
    whitelist_enabled = true,
    ring_entity_rotation = true,
    immobilize_on_summon = true,
    custom_settings = true,
    superimpose_default_inventory = true,
    disable_select_callbacks = true,
    require_craft = true
}
-- Place itemnames in this table to have their on_rightclick methods cleared.
satchel.dq = {}
satchel.mtg_recipe_starter_item = {"default:dirt"}