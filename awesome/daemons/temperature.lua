local awful = require("awful")
local gears = require("gears")

local M = {}

M.interval = 5
M.max_temp = 100
M.script = "sensors | grep 'CPU:' | awk '{print $2}' | tr -d '+°C'"

function M.update()
    awful.spawn.easy_async_with_shell(M.script, function(stdout)
        local temp = tonumber(stdout)
        if temp then
            local temp_percentage = (temp / M.max_temp) * 100
            awesome.emit_signal("temperature::update", math.floor(temp_percentage))
        end
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
