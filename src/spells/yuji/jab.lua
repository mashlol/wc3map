local hero = require('src/hero.lua')
local mouse = require('src/mouse.lua')
local Vector = require('src/vector.lua')
local effect = require('src/effect.lua')
local projectile = require('src/projectile.lua')
local log = require('src/log.lua')
local casttime = require('src/casttime.lua')
local collision = require('src/collision.lua')
local animations = require('src/animations.lua')
local damage = require('src/damage.lua')
local cooldowns = require('src/spells/cooldowns.lua')

-- TODO create some sort of helper or "DB" for getting cooldowns
local COOLDOWN_S = 5

local getSpellId = function()
    return 'jab'
end

local getSpellName = function()
    return 'Jab'
end

function getCollisionPoint(heroV, facingDeg, i, j)
    local perpendicularAngle = (facingDeg + 90) * bj_DEGTORAD
    local perpendicularVec = Vector:fromAngle(perpendicularAngle)
        :multiply(i * 50)
        :add(heroV)
    return Vector:fromAngle(facingDeg * bj_DEGTORAD)
        :multiply(j * 500)
        :add(perpendicularVec)
end

local cast = function(playerId)
    if cooldowns.isOnCooldown(playerId, getSpellId()) then
        log.log(playerId, getSpellName().." is on cooldown!", log.TYPE.ERROR)
        return false
    end

    if cooldowns[playerId] ~= nil then
        DestroyTimer(cooldowns[playerId])
        cooldowns[playerId] = nil
    end

    local hero = hero.getHero(playerId)
    local heroV = Vector:new{x = GetUnitX(hero), y = GetUnitY(hero)}
    local mouseV = Vector:new{
        x = mouse.getMouseX(playerId),
        y = mouse.getMouseY(playerId)
    }

    cooldowns.startCooldown(playerId, getSpellId(), COOLDOWN_S)

    SetUnitTimeScale(hero, 2)
    IssueImmediateOrder(hero, "stop")
    animations.queueAnimation(hero, 8, 1)

    local facingDeg =
        bj_RADTODEG * Atan2(mouseV.y - heroV.y, mouseV.x - heroV.x)

    SetUnitFacing(
        hero,
        facingDeg)

    effect.createEffect{
        model = "slsh",
        unit = hero,
        duration = 0.3,
        facing = facingDeg,
        timeScale = 0.7,
    }

    local shape = {
        getCollisionPoint(heroV, facingDeg, 1, 0),
        getCollisionPoint(heroV, facingDeg, -1, 0),
        getCollisionPoint(heroV, facingDeg, -1, 1),
        getCollisionPoint(heroV, facingDeg, 1, 1),
    }

    local collidedUnits = collision.getAllCollisions(shape)
    for idx, unit in pairs(collidedUnits) do
        if IsUnitEnemy(unit, Player(playerId)) then
            damage.dealDamage(hero, unit, 150)

            effect.createEffect{
                model = "ebld",
                unit = unit,
                duration = 0.1,
            }
        end
    end

    casttime.cast(playerId, 0.4, false)

    SetUnitTimeScale(hero, 1)

    return true
end

local getCooldown = function(playerId)
    return cooldowns.getRemainingCooldown(playerId, getSpellId())
end

local getTotalCooldown = function(playerId)
    return cooldowns.getTotalCooldown(playerId, getSpellId())
end

local getIcon = function()
    return "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp"
end

return {
    cast = cast,
    getSpellId = getSpellId,
    getSpellName = getSpellName,
    getIcon = getIcon,
}
