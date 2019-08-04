local hero = require('src/hero.lua')
local mouse = require('src/mouse.lua')
local vector = require('src/vector.lua')
local effect = require('src/effect.lua')
local projectile = require('src/projectile.lua')

-- TODO create some sort of helper or "DB" for getting cooldowns
local COOLDOWN_S = 1

local cooldowns = {}

local cast = function(playerId)
    if
        cooldowns[playerId] ~= nil and
        TimerGetRemaining(cooldowns[playerId]) > 0.05
    then
        print("Dummy spell is on cooldown!")
        return false
    end

    if cooldowns[playerId] ~= nil then
        DestroyTimer(cooldowns[playerId])
        cooldowns[playerId] = nil
    end

    print("Casting dummy spell")

    local timer = CreateTimer()
    TimerStart(timer, COOLDOWN_S, false, nil)
    cooldowns[playerId] = timer

    return true
end

local getCooldown = function(playerId)
    if cooldowns[playerId] ~= nil then
        return TimerGetRemaining(cooldowns[playerId])
    end
    return 0
end

local getTotalCooldown = function()
    return COOLDOWN_S
end

return {
    cast = cast,
    getCooldown = getCooldown,
    getTotalCooldown = getTotalCooldown,
}