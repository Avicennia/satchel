 -- luacheck: globals satchel minetest _
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