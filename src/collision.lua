local Vector = require('src/vector.lua')
local SAT = require('src/lib/sat.lua')

function isCollided(unit, vec, radius)
    vec = Vector:new(vec)
    local collisionSize = BlzGetUnitCollisionSize(unit)
    local unitV = Vector:new{x = GetUnitX(unit), y = GetUnitY(unit)}
    local collisionDist = Vector:new(vec):subtract(unitV)
    if collisionDist:magnitude() <= collisionSize then
        return true
    end
    local mag = collisionDist:normalize()
        :multiply(collisionSize)
        :add(unitV)
        :multiply(-1)
        :add(vec)
        :magnitude()

    return mag <= radius
end

function isCollidedWithPolygon(unit, shape)
    local pts = {}
    for idx, vec in pairs(shape) do
        table.insert(pts, SAT.Vector(vec.x, vec.y))
    end

    local poly = SAT.Polygon(SAT.Vector(0, 0), pts)
    local circ = SAT.Circle(
        SAT.Vector(GetUnitX(unit), GetUnitY(unit)),
        BlzGetUnitCollisionSize(unit))
    local response = SAT.Response()
    local collided = SAT.testPolygonCircle(poly, circ, response)

    return collided
end

function getAllCollisions(vec, radius)
    -- Loop through all nearby units
    -- Check they are alive
    -- Check they aren't hidden
    -- TODO Check they aren't an effect unit
    -- Check they are coliding with the vector/radius

    local loc
    if vec[1] and vec[1].x then
        -- Assume its a shape (list of vectors, which represent points)
        loc = Location(vec[1].x, vec[1].y)
    else
        loc = Location(vec.x, vec.y)
    end
    local grp = GetUnitsInRangeOfLocAll(1000, loc)
    local toReturn = {}
    ForGroupBJ(grp, function()
        local collidedUnit = GetEnumUnit()
        if
            GetUnitState(collidedUnit, UNIT_STATE_LIFE) > 0 and
            not IsUnitHidden(collidedUnit)
        then
            if
                vec[1] and
                vec[1].x and
                isCollidedWithPolygon(collidedUnit, vec) or
                isCollided(collidedUnit, vec, radius)
            then
                table.insert(toReturn, collidedUnit)
            end
        end
    end)

    RemoveLocation(loc)

    return toReturn
end


return {
    getAllCollisions = getAllCollisions,
    isCollided = isCollided,
}
