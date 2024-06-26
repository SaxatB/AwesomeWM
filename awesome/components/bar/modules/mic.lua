local awful = require("awful")
local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")

local function update(icon, background, tooltip, mute, vol)
    if mute then
        tooltip.markup = "<b>Muted</b>"
        icon.markup = ""
        background.fg = beautiful.red
        return
    end

	if vol == 0 then
	icon.markup = ""
        background.fg = beautiful.red
	elseif vol < 30 then
	icon.markup = ""
        background.fg = beautiful.purple
	elseif vol < 60 then
	icon.markup = ""
        background.fg = beautiful.blue
	else
	icon.markup = ""
        background.fg = beautiful.green
	end

	tooltip.markup = "<b>Mic</b>: " .. tostring(vol) .. "%"
end

local function create_widget()
    local icon = wibox.widget({
        font = beautiful.font_icon,
        markup = "",
        valign = "center",
        halign = "center",
        widget = wibox.widget.textbox
    })

    local background = helpers.add_bg0(icon)

    background:buttons({
        awful.button({}, 3, function()
            awful.spawn.with_shell("pavucontrol --tab=4")
        end),
        awful.button({}, 1, function()
            awesome.emit_signal("microphone::mute")
        end),
        awful.button({}, 4, function()
            awesome.emit_signal("microphone::increase", 5)
        end),
        awful.button({}, 5, function()
            awesome.emit_signal("microphone::decrease", 5)
        end)
    })

    local widget = helpers.add_margin(background, beautiful.margin[1], 0)

    local tooltip = helpers.add_tooltip(widget, "<b>Mic</b>")
    
    awesome.connect_signal("microphone::update", function(mute, vol)
        update(icon, background, tooltip, mute, vol)
    end)

    return widget
end

return create_widget
