local vector = require('src/vector.lua')

function isCollided(unit, vec, radius)
    local collisionSize = BlzGetUnitCollisionSize(unit)
    local collidedV = vector.create(
        GetUnitX(unit), GetUnitY(unit))
    local collisionDist = vector.subtract(vec, collidedV)
    collisionDist = vector.normalize(collisionDist)
    collisionDist = vector.multiply(collisionDist, collisionSize)
    collisionDist = vector.add(collisionDist, collidedV)
    collisionDist = vector.subtract(vec, collisionDist)
    collisionDist = vector.magnitude(collisionDist)

    return collisionDist <= radius
end

function getAllCollisions(vec, radius)
    -- Loop through all nearby units
    -- Check they are alive
    -- TODO Check they aren't hidden
    -- TODO Check they aren't an effect unit
    -- Check they are coliding with the vector/radius

    local grp = GetUnitsInRangeOfLocAll(800, Location(vec.x, vec.y))
    local toReturn = {}
    ForGroupBJ(grp, function()
        local collidedUnit = GetEnumUnit()
        if
            GetUnitState(collidedUnit, UNIT_STATE_LIFE) > 0 and
            not IsUnitHidden(collidedUnit) and
            isCollided(collidedUnit, vec, radius)
        then
            table.insert(toReturn, collidedUnit)
        end
    end)

    return toReturn
end


return {
    getAllCollisions = getAllCollisions,
    isCollided = isCollided,
}