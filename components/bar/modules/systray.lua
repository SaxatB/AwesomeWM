local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")

local function create_widget()
	local systray = wibox.widget({
	widget = wibox.widget.systray(),
        horizontal = false,
	})
	systray:set_base_size(20)
    return helpers.add_margin(systray, beautiful.dpi(12), 0)
end
return create_widget
