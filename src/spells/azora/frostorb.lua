local hero = require('src/hero.lua')
local mouse = require('src/mouse.lua')
local vector = require('src/vector.lua')
local effect = require('src/effect.lua')
local projectile = require('src/projectile.lua')
local log = require('src/log.lua')
local casttime = require('src/casttime.lua')
local animations = require('src/animations.lua')
local buff = require('src/buff.lua')

-- TODO create some sort of helper or "DB" for getting cooldowns
local COOLDOWN_S = 160

local cooldowns = {}

local cast = function(playerId)
    if
        cooldowns[playerId] ~= nil and
        TimerGetRemaining(cooldowns[playerId]) > 0.05
    then
        log.log(playerId, "Frost Orb is on cooldown!", log.TYPE.ERROR)
        return false
    end

    if cooldowns[playerId] ~= nil then
        DestroyTimer(cooldowns[playerId])
        cooldowns[playerId] = nil
    end

    local hero = hero.getHero(playerId)

    local heroV = vector.create(GetUnitX(hero), GetUnitY(hero))
    local mouseV = vector.create(
        mouse.getMouseX(playerId),
        mouse.getMouseY(playerId))

    local dist = vector.subtract(heroV, mouseV)
    local mag = vector.magnitude(dist)
    if mag > 800 then
        log.log(playerId, "Out of range!", log.TYPE.ERROR)
        return false
    end

    IssueImmediateOrder(hero, "stop")
    animations.queueAnimation(hero, 16, 2)

    local castSuccess = casttime.cast(playerId, 1)
    if not castSuccess then
        return false
    end

    local timer = CreateTimer()
    TimerStart(timer, COOLDOWN_S, false, nil)
    cooldowns[playerId] = timer

    animations.queueAnimation(hero, 8, 2)

    for x=0,30,10 do
        for i=x,360+x,40 do
            local toV = vector.fromAngle(bj_DEGTORAD * i)

            projectile.createProjectile{
                playerId = playerId,
                model = "efor",
                fromV = mouseV,
                toV = vector.add(mouseV, toV),
                speed = 300,
                length = 350,
                onCollide = function(collidedUnit)
                    if IsUnitEnemy(collidedUnit, Player(playerId)) then
                        UnitDamageTargetBJ(
                            hero,
                            collidedUnit,
                            50 * buff.getDamageModifier(hero, collidedUnit),
                            ATTACK_TYPE_PIERCE,
                            DAMAGE_TYPE_UNKNOWN)
                        return true
                    end
                    return false
                end
            }
        end
        TriggerSleepAction(0.03)
    end

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

local getIcon = function()
    return "ReplaceableTextures\\CommandButtons\\BTNFrostBolt.blp"
end

return {
    cast = cast,
    getCooldown = getCooldown,
    getTotalCooldown = getTotalCooldown,
    getIcon = getIcon,
}