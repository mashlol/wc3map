local hero = require('src/hero.lua')
local keyboard = require('src/keyboard.lua')
local mouse = require('src/mouse.lua')
local projectile = require('src/projectile.lua')

local mainInit = function()
    hero.init()
    keyboard.init()
    mouse.init()
    projectile.init()
end

TimerStart(CreateTimer(), 0.0, false, mainInit)