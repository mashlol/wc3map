local Vector = require('src/vector.lua')
local hero = require('src/hero.lua')
local collision = require('src/collision.lua')

local projectiles = {}
local timer

local isCloseTo = function(val, expected)
    return val + 15 >= expected and val - 15 <= expected
end

local destroyProjectile = function(projectile)
    if projectile.options.shouldRemove then
        if projectile.options.removeInsteadOfKill then
            RemoveUnit(projectile.unit)
        else
            KillUnit(projectile.unit)
        end
    end
    projectile.toRemove = true
    if projectile.options.onDestroy then
        projectile.options.onDestroy(projectile.unit)
    end
end

local getGoalV = function(options)
    if options.toV ~= nil then
        return Vector:new(options.toV)
    else
        return Vector:new{
            x = GetUnitX(options.destUnit),
            y = GetUnitY(options.destUnit),
        }
    end
end

local clearProjectiles = function()
    local elapsedTime = TimerGetElapsed(timer)

    for idx, projectile in pairs(projectiles) do
        local curProjectileX = GetUnitX(projectile.unit)
        local curProjectileY = GetUnitY(projectile.unit)

        local projectileV = Vector:new{x = curProjectileX, y = curProjectileY}
        local ownerHero = hero.getHero(projectile.options.playerId)
        local collidedUnits = collision.getAllCollisions(
            projectileV,
            projectile.options.radius or 50)
        for idx, collidedUnit in pairs(collidedUnits) do
            if
                collidedUnit ~= ownerHero and
                projectile.toRemove ~= true and
                projectile.alreadyCollided[GetHandleId(collidedUnit)] ~= true
            then
                projectile.alreadyCollided[GetHandleId(collidedUnit)] = true
                local destroyOnCollide = false
                if projectile.options.onCollide then
                    destroyOnCollide = projectile.options.onCollide(
                        collidedUnit)
                end
                if destroyOnCollide then
                    destroyProjectile(projectile)
                end
            end
        end

        local goalV = getGoalV(projectile.options)
        if projectile.toRemove then
            -- do nothing
        elseif
            isCloseTo(curProjectileX, goalV.x) and
            isCloseTo(curProjectileY, goalV.y)
        then
            -- Already at destination, can finish
            destroyProjectile(projectile)
        else
            -- Move toward destination at speed
            local distVector = Vector:new(goalV):subtract(projectileV)

            local deltaV = Vector:new(distVector)
                :normalize()
                :multiply(projectile.options.speed * elapsedTime)

            if deltaV:magnitude() >= distVector:magnitude() then
                deltaV = distVector
            end

            deltaV:add(projectileV)

            SetUnitX(projectile.unit, deltaV.x)
            SetUnitY(projectile.unit, deltaV.y)
            local facingRad = Atan2(
                goalV.y - projectile.options.fromV.y,
                goalV.x - projectile.options.fromV.x)
            SetUnitFacing(projectile.unit, bj_RADTODEG * facingRad)

            if projectile.options.onMove then
                projectile.options.onMove(deltaV.x, deltaV.y)
            end
        end
    end
    local newProjectiles = {}
    for idx, projectile in pairs(projectiles) do
        if projectile ~= nil and projectile.toRemove ~= true then
            table.insert(newProjectiles, projectile)
        end
    end
    projectiles = newProjectiles
end

local init = function()
    timer = CreateTimer()
    TimerStart(timer, 0.0078125, true, clearProjectiles)
end

local createProjectile = function(options)
    local goalV = getGoalV(options)
    if options.length ~= nil then
        local lengthNormalizedV = Vector:new(goalV)
            :subtract(options.fromV)
            :normalize()
            :multiply(options.length)
            :add(options.fromV)
        goalV = lengthNormalizedV
        options.toV = goalV
    end

    if options.projectile == nil then
        options.projectile = CreateUnit(
            Player(PLAYER_NEUTRAL_PASSIVE),
            FourCC(options.model),
            options.fromV.x,
            options.fromV.y,
            bj_RADTODEG * Atan2(goalV.y - options.fromV.y, goalV.x - options.fromV.x))
        options.shouldRemove = true
    else
        options.shouldRemove = false
    end

    table.insert(projectiles, {
        unit = options.projectile,
        options = options,
        alreadyCollided = {}
    })

    return options.projectile
end

return {
    init = init,
    createProjectile = createProjectile,
}
