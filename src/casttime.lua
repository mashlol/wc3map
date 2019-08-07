local hero = require('src/hero.lua')

local castTimes = {}
local movePrevents = {}

local cast = function(playerId, time, interruptable, canMove)
    if castTimes[playerId] ~= nil then
        return false
    end

    if interruptable == nil then
        interruptable = true
    end

    if canMove == nil then
        canMove = false
    end

    if interruptable == true then
        -- Allow move so you can interupt by moving
        canMove = true
    end

    local timer = CreateTimer()
    TimerStart(timer, time, false, nil)
    castTimes[playerId] = {
        timer = timer,
        interruptable = interruptable,
        canMove = canMove,
    }

    if not canMove then
        PauseUnit(hero.getHero(playerId), true)
    end
    TriggerSleepAction(time)

    local successfulCast = false
    if
        castTimes[playerId] ~= nil and
        GetHandleId(castTimes[playerId].timer) == GetHandleId(timer)
    then
        PauseUnit(hero.getHero(playerId), false)
        successfulCast = true
        castTimes[playerId] = nil
        DestroyTimer(timer)
    end

    return successfulCast
end

local isCasting = function(playerId)
    return castTimes[playerId] ~= nil
end

local interruptCast = function()
    if GetIssuedOrderId() == 851973 then
        return
    end
    local playerId = GetPlayerId(GetTriggerPlayer())
    local timer = castTimes[playerId]
    if timer ~= nil and timer.interruptable == true then
        PauseUnit(hero.getHero(playerId), false)
        castTimes[playerId] = nil
        DestroyTimer(timer.timer)
    end
end

local getCastDurationRemaining = function(playerId)
    local timer = castTimes[playerId]
    if timer ~= nil then
        return TimerGetRemaining(timer.timer)
    end
    return nil
end

local getCastDurationTotal = function(playerId)
    local timer = castTimes[playerId]
    if timer ~= nil then
        return TimerGetTimeout(timer.timer)
    end
    return nil
end

local init = function()
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER)
    TriggerAddAction(trigger, interruptCast)
end

return {
    init = init,
    cast = cast,
    isCasting = isCasting,
    getCastDurationRemaining = getCastDurationRemaining,
    getCastDurationTotal = getCastDurationTotal,
}
