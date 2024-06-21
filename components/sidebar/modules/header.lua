local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local helpers = require("helpers")
local M = {}

M.buttons = {
    {
        icon = "",
        cmd = "awesome-client 'awesome.emit_signal(\"lockscreen::toggle\")'",
        text = "Lock",
        color = beautiful.green,
    },
   {
        icon = "",
        cmd = "awesome-client 'awesome.emit_signal(\"exitscreen::toggle\")'",
        text = "Exit",
        color = beautiful.blue,
   }
}

function M.create_button(icon, cmd, text, color)
    local icon_widget = wibox.widget({
        markup = icon,
        font = beautiful.font_icon,
        forced_width = beautiful.icon_size[2],
        forced_height = beautiful.icon_size[2],
        valign = "center",
        halign = "center",
        widget = wibox.widget.textbox
    })

    local widget = helpers.add_bg1(helpers.add_margin(icon_widget))
    widget.fg = color
    widget:buttons({
        awful.button({}, 1, function()
            awesome.emit_signal("launcher::stop")
            awful.spawn.with_shell(cmd)
        end)
    })

    widget:connect_signal("mouse::enter", function()
        widget.bg = beautiful.bg2
    end)

    widget:connect_signal("mouse::leave", function()
        widget.bg = beautiful.bg1
    end)

    return widget
end

function M.new()
    M.pfp = wibox.widget({
        image = gears.filesystem.get_configuration_dir() .. "assets/pfp.jpg",
        halign = "center",
        valign = "center",
        forced_height = beautiful.icon_size[2],
        forced_width = beautiful.icon_size[2],
        resize = true,
        clip_shape = gears.shape.circle,
        widget = wibox.widget.imagebox
    })

    M.uptime_text = wibox.widget({
        valign = "center",
        halign = "left",
        widget = wibox.widget.textbox
    })

    M.uptime = helpers.add_bg1(M.uptime_text)
    M.uptime.fg = beautiful.fg2

    M.name = wibox.widget({
        markup = "",
        valign = "center",
        halign = "left",
        widget = wibox.widget.textbox
    })

    M.button_group = wibox.widget({
        spacing = beautiful.margin[1],
        layout = wibox.layout.flex.horizontal
    })

     -- Weather Widget
     M.weather_icon = wibox.widget({
	image = beautiful.weather_cloudy,
	resize = true,
	forced_width = beautiful.dpi(86),
	forced_height = beautiful.dpi(86),
	widget = wibox.widget.imagebox	
     })

     M.temperature = wibox.widget({
	font = beautiful.font,
	align = "left",
	widget = wibox.widget.textbox
     })

     M.the_weather = wibox.widget({
	font = beautiful.font,
	align = "left",
	widget = wibox.widget.textbox
     })

     M.city = wibox.widget({
	font = beautiful.font,
	align = "left",
	widget = wibox.widget.textbox
     })

     awesome.connect_signal("signal::weather", function(city, hows_weather, feels_like)
	hows_weather = string.gsub(hows_weather, "'", "")
	feels_like = string.gsub(feels_like, "\n", "")
	M.the_weather.markup = hows_weather
	M.temperature.markup = feels_like:match("%d%d").."°C"
	M.city.markup = "<span font='" .. beautiful.font_icon .. "'> </span>" .. city
end)

    for _, button in ipairs(M.buttons) do
        M.button_group:add(M.create_button(button.icon, button.cmd, button.text, button.color))
    end

    M.widget = helpers.add_margin(wibox.widget({
	    -- Intro Widget
	   helpers.add_bg1(helpers.add_margin({
        {
            M.pfp,
            {
                M.name,
                M.uptime,
                layout = wibox.layout.fixed.vertical
            },
            spacing = beautiful.margin[1],
            forced_height = beautiful.icon_size[2],
            layout = wibox.layout.fixed.horizontal
        },
        M.button_group,
        layout = wibox.layout.align.vertical
	}, beautiful.margin[1], beautiful.margin[1])),
	spacing = beautiful.margin[1],
        layout = wibox.layout.fixed.horizontal
    }))

    awesome.connect_signal("uptime::update", function(stdout)
        M.uptime_text.markup = stdout
    end)

    return M.widget
end

return M
