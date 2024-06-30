local awful = require("awful")
local naughty = require("naughty")

local M = {}
M.mute = false
M.vol = 0

local Mic = {}
Mic.mute = false
Mic.vol = 0

function M.update()
    awful.spawn.easy_async_with_shell("pamixer --get-mute && pamixer --get-volume", function(stdout)
        local info = {}
        for line in stdout:gmatch("[^\r\n]+") do
            table.insert(info, line)
        end
        if info[1] == "false" then
            M.mute = false
        else
            M.mute = true
        end
        M.vol = tonumber(info[2])
        awesome.emit_signal("volume::update", M.mute, M.vol)
    end)
end

function Mic.update()
    awful.spawn.easy_async_with_shell("pamixer --default-source --get-mute && pamixer --default-source --get-volume", function(stdout)
        local info = {}
        for line in stdout:gmatch("[^\r\n]+") do
            table.insert(info, line)
        end
        if info[1] == "false" then
            Mic.mute = false
        else
            Mic.mute = true
        end
        Mic.vol = tonumber(info[2])
        awesome.emit_signal("microphone::update", Mic.mute, Mic.vol)
    end)
end

function M.start()
    -- Initial values
    M.update()
    Mic.update()

    awful.spawn.easy_async({
        'pkill', '--full', '--uid', os.getenv('USER'), '^pactl subscribe'
    }, function()
        awful.spawn.with_line_callback([[
    bash -c "
    LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink\"
    "]], {
            stdout = function(line) M.update() end
        })

        awful.spawn.with_line_callback([[
    bash -c "
    LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on source\"
    "]], {
            stdout = function(line) Mic.update() end
        })
    end)

    awesome.connect_signal("volume::increase", function(i)
        awful.spawn.with_shell("pamixer -i " .. tostring(i))
    end)

    awesome.connect_signal("volume::decrease", function(d)
        awful.spawn.with_shell("pamixer -d " .. tostring(d))
    end)

    awesome.connect_signal("volume::mute", function()
        awful.spawn.with_shell("pamixer -t")
    end)

    awesome.connect_signal("microphone::increase", function(i)
        awful.spawn.with_shell("pamixer --default-source -i " .. tostring(i))
    end)

    awesome.connect_signal("microphone::decrease", function(d)
        awful.spawn.with_shell("pamixer --default-source -d " .. tostring(d))
    end)

    awesome.connect_signal("microphone::mute", function()
        awful.spawn.with_shell("pamixer --default-source -t")
    end)
end

M.start()
