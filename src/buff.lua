local BUFF_INFO = {
    focus = {
        effects = {
            {
                type = 'multiplyDamage',
                amount = 1.2,
            },
            {
                type = 'modifyMoveSpeed',
                amount = 1.5,
            },
        },
    },
    armorpot = {
        effects = {
            {
                type = 'multiplyIncomingDamage',
                amount = 0.9,
            },
        },
    },
}

-- BuffInstances:
-- {
--   [unitHandleID] = {
--     buffs = {
--       [buffName] = true,
--     },
--     unit = unit,
--   },
-- }
local buffInstances = {}

function applyBuffs()
    for unitId,unitInfo in pairs(buffInstances) do
        local unit = unitInfo.unit
        local buffs = unitInfo.buffs
        local baseSpeed = GetUnitDefaultMoveSpeed(unit)

        for buffName,val in pairs(buffs) do
            local effects = BUFF_INFO[buffName].effects
            for idx,info in pairs(effects) do
                if info.type == 'modifyMoveSpeed' then
                    baseSpeed = baseSpeed * info.amount
                end
            end
        end

        SetUnitMoveSpeed(unit, baseSpeed)
    end
end

function addBuff(unit, buffName)
    local unitId = GetHandleId(unit)
    if buffInstances[unitId] == nil then
        buffInstances[unitId] = {
            unit = unit,
            buffs = {},
        }
    end

    buffInstances[unitId].buffs[buffName] = true
    applyBuffs(unit)
end

function removeBuff(unit, buffName)
    local unitId = GetHandleId(unit)
    if buffInstances[unitId] == nil or buffInstances[unitId].buffs == nil then
        return
    end

    buffInstances[unitId].buffs[buffName] = nil
    applyBuffs(unit)
end

function hasBuff(unit, buffName)
    local unitId = GetHandleId(unit)
    return buffInstances[unitId] ~= nil and
        buffInstances[unitId].buffs ~= nil and
        buffInstances[unitId].buffs[buffName]
end

function getBuffs(unit)
    local unitId = GetHandleId(unit)
    return buffInstances[unitId] and buffInstances[unitId].buffs or {}
end

-- Iterate over all a units buffs and get the final damage modifier
function getDamageModifier(unit, target)
    local buffs = getBuffs(unit)
    local modifier = 1
    for buffName,val in pairs(buffs) do
        local effects = BUFF_INFO[buffName].effects
        for idx,info in pairs(effects) do
            if info.type == 'multiplyDamage' then
                modifier = modifier * info.amount
            end
        end
    end
    local buffs = getBuffs(target)
    for buffName,val in pairs(buffs) do
        local effects = BUFF_INFO[buffName].effects
        for idx,info in pairs(effects) do
            if info.type == 'multiplyIncomingDamage' then
                modifier = modifier * info.amount
            end
        end
    end
    return modifier
end

function init()
    TimerStart(CreateTimer(), 1, true, applyBuffs)
end

return {
    addBuff = addBuff,
    removeBuff = removeBuff,
    hasBuff = hasBuff,
    getBuffs = getBuffs,
    getDamageModifier = getDamageModifier,
    init = init,
}