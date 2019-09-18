local hero = require('src/hero.lua')
local keyboard = require('src/keyboard.lua')
local mouse = require('src/mouse.lua')
local projectile = require('src/projectile.lua')
local cleanup = require('src/cleanup.lua')
local uiMain = require('src/ui/main.lua')
local leaver = require('src/leaver.lua')
local casttime = require('src/casttime.lua')
local buffloop = require('src/buffloop.lua')
local target = require('src/target.lua')
local damage = require('src/damage.lua')
local party = require('src/party.lua')
local threat = require('src/threat.lua')
local camera = require('src/camera.lua')
local spawnpoint = require('src/spawnpoint.lua')
local spell = require('src/spell.lua')
local gc = require('src/gc.lua')
local save = require('src/saveload/save.lua')
local buffmanager = require('src/buffs/buffmanager.lua')
local cooldowns = require('src/spells/cooldowns.lua')
local backpack = require('src/items/backpack.lua')
local equipment = require('src/items/equipment.lua')
local itemmanager = require('src/items/itemmanager.lua')
local bossmanager = require('src/bosses/bossmanager.lua')

local debug = require('src/debug.lua')

local mainInit = function()
    hero.init()
    keyboard.init()
    mouse.init()
    projectile.init()
    cleanup.init()
    uiMain.init()
    leaver.init()
    casttime.init()
    buffloop.init()
    target.init()
    damage.init()
    party.init()
    threat.init()
    camera.init()
    spawnpoint.init()
    spell.init()
    gc.init()
    save.init()
    buffmanager.init()
    cooldowns.init()
    backpack.init()
    equipment.init()
    itemmanager.init()
    bossmanager.init()

    -- TODO remove for release
    debug.init()
end

TimerStart(CreateTimer(), 0.0, false, mainInit)

collectgarbage("stop")
