local function reveal(p,x)
    return minetest.chat_send_player(p,x)
end

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


minetest.register_chatcommand("satchel_settinglist", {
    params = "Displays settings of all players to user <admin>", 
    description = "Remove privilege from player", 
    privs = {privs=true},
    func = function(name, param)
        say(satchel.config)
        --reveal(name, minetest.serialize(satchel.settings))
    end
})


-- User Commands
minetest.register_chatcommand("invr", {
    params = "Changes player setting value as requested", 
    description = "Remove privilege from player", 
    privs = {interact=true},
    func = function(name, param)
        local spcs = function(param, n)
            return string.find(param, " ",n or 1)
        end
        local space1 = spcs(param)
        local setting = string.sub( param, 1,space1-1) or nil
        local value = string.sub(param, space1+1) or nil
        local options = {radius = 1.6, height = 2, speed = 3, typeface = 4}
        if(setting and options[setting])then
            local v = tonumber(value)
            v = v and math.abs(v) <= options[setting] and v or options[setting]
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
            reveal(name, "Added "..pname.." to your satchel whitelist!")
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
        reveal(name,n..") Player: "..k)
        reveal(name,n..") Trust level: "..v)
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