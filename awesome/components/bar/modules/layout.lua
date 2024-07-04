local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")

local function create_widget(s)
	local layout_box = awful.widget.layoutbox({
		screen = s,
		-- Add buttons, allowing you to change the layout
		buttons = {
			awful.button({}, 1, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 3, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 4, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 5, function()
				awful.layout.inc(-1)
			end),
		},
	})

	local widget = helpers.add_margin(layout_box, beautiful.margin[1], beautiful.margin[0])
	return widget
end
return create_widget
