local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

local function create_widget()
    local clock = wibox.widget({
        format = '%I\n%M',
        valign = "center",
        halign = "center",
        widget = wibox.widget.textclock,
    })

local month_calendar = awful.widget.calendar_popup.month({
	screen = s,
	position = "bl",
	start_sunday = true,
	margin = dpi(8),
	ontop = true,
})

clock:connect_signal("button::press",
    function(_, _, _, button)
      if button == 1 then 
	month_calendar:toggle()
      end
    end
)
return helpers.add_margin(clock)
end
return create_widget
