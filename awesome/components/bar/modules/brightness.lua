local awful = require("awful")
local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")

local function update(background, tooltip, bright)
	if bright < 25 then
        background.fg = beautiful.red
	elseif bright < 50 then
        background.fg = beautiful.blue
	else
        background.fg = beautiful.green
	end

	tooltip.markup = "<b>Brightness</b>: " .. tostring(bright) .. "%"
end

local function create_widget()
    local icon = wibox.widget({
        font = beautiful.font_icon,
        markup = "",
        valign = "center",
        halign = "center",
        widget = wibox.widget.textbox
    })

    local background = helpers.add_bg0(icon)

    background:buttons({
        awful.button({}, 4, function()
            awesome.emit_signal("brightness::increase", 5)
        end),
        awful.button({}, 5, function()
            awesome.emit_signal("brightness::decrease", 5)
        end)
    })

    local widget = helpers.add_margin(background, beautiful.margin[1], 0)

    local tooltip = helpers.add_tooltip(widget, "<b>Brightness</b>")
    
    awesome.connect_signal("brightness::update", function(bright)
        update(background, tooltip, bright)
    end)

    return widget
end

return create_widget
