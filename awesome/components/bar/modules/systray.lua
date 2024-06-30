local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")
local gears = require("gears")
local awful = require("awful")

local function create_widget()
    local systray = wibox.widget({
        widget = wibox.widget.systray(),
        horizontal = false,
    })
    systray:set_base_size(16)
    systray.visible = false

    local arrow = wibox.widget {
        widget = wibox.widget.textbox,
        text = "",
        align = "center",
        valign = "center",
    }

    local tray_toggle = wibox.widget {
        systray,
        arrow,
	spacing = beautiful.dpi(2),
        layout = wibox.layout.fixed.vertical,
    }

    arrow:buttons(gears.table.join(
        arrow:buttons(),
        awful.button({}, 1, function()
            if systray.visible then
                systray.visible = false
                arrow.text = ""
            else
                systray.visible = true
                arrow.text = ""
            end
        end)
    ))

    return helpers.add_margin(tray_toggle, beautiful.dpi(13), 0)
end

return create_widget
