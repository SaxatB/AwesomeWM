local awful = require("awful")
local gears = require("gears")

local M = {}

M.interval = 5
M.script = "df -h /home|grep '^/' | awk '{print $5}' | tr -d '%'"

function M.update()
    awful.spawn.easy_async_with_shell(M.script, function(stdout)
        local storage = tonumber(stdout)
        awesome.emit_signal("hdd::update", math.floor(storage))
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
