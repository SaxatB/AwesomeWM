local awful = require("awful")
local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")

-- Volume and Brightness widgets
local brightness_widget = require("components.bar.modules.brightness-widget.brightness")
local volume_widget = require('components.bar.modules.volume-widget.volume')

local function create_bar(s)
    s.bar = awful.wibar({
        position = "left",
        width = beautiful.bar_width,
        screen = s,
        height = s.geometry.height
    })

    s.bar.widget = helpers.add_bg0(wibox.widget({
        layout = wibox.layout.align.vertical,
        { -- Top widgets
            -- Launcher, Taglist
            require("components.bar.modules.launcher")(),
            require("components.bar.modules.taglist")(s),
            spacing = beautiful.margin[1],
            layout = wibox.layout.fixed.vertical,
        },
        { -- Middle widgets
            -- Tasklist
            require("components.bar.modules.tasklist")(s),
            spacing = beautiful.margin[1],
            layout = wibox.layout.fixed.vertical
        },
        { -- Bottom widgets
            -- Systray, Battery, Volume, Brightness, Clock, Layout
            require("components.bar.modules.systray")(),
	    brightness_widget{
            type = 'arc',
            program = 'brightnessctl',
            step = 2, },
	    volume_widget{
            widget_type = 'arc' },
	    require("components.bar.modules.battery")(),
            require("components.bar.modules.clock")(),
            require("components.bar.modules.layout")(),
            spacing = beautiful.margin[1],
            layout = wibox.layout.fixed.vertical
        }
    }))
end

screen.connect_signal("request::desktop_decoration", function(s)
    create_bar(s)
end)
