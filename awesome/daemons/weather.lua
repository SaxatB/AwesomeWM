local awful = require("awful")
local gears = require("gears")

local M = {}

M.interval = 1200 -- Check for weather every 20 min
M.city = "London" -- Ex. London or Salt+Lake+City
M.script = [[curl -sf "wttr.in/]] .. M.city .. [[?format='%C:%f'" ]]

function M.update()
    awful.spawn.easy_async_with_shell(M.script, function(stdout)
        local weather = stdout:match("(.+):")
        local feels_like = stdout:match(".+[:](.+)")
        awesome.emit_signal('weather::update', M.city, weather, feels_like)
        collectgarbage("collect")
    end)
end

function M.start()
    gears.timer {
        timeout = M.interval,
        autostart = true,
        call_now = true,
        callback = M.update
    }
end

M.start()
