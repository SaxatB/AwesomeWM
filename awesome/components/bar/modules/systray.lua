local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")

local function create_widget()
	local systray = wibox.widget({
	widget = wibox.widget.systray(),
        horizontal = false,
	})
	systray:set_base_size(16)
    return helpers.add_margin(systray)
end
return create_widget
