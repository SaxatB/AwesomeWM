local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local M = {}

function M.new()
    M.title = wibox.widget({
        markup = "<b>Weather</b>",
	align = "center",
        widget = wibox.widget.textbox
    })

    M.temp = wibox.widget({
	align = "center",
        widget = wibox.widget.textbox
    })

    M.weather = wibox.widget({
	align = "center",
        widget = wibox.widget.textbox
    })

    M.location = wibox.widget({
	align = "center",
        widget = wibox.widget.textbox
    })

    awesome.connect_signal("weather::update", function(city, hows_weather, feels_like)
        hows_weather = string.gsub(hows_weather, "'", "")
        feels_like = string.gsub(feels_like, "\n", "")
	local city_markup = "<span font='"..beautiful.font_icon.."'></span>  <span font='"..beautiful.font.."'>"..city.."</span>"
	local temp_markup = "<span font='"..beautiful.font_icon.."'></span>  <span font='"..beautiful.font.."'>"..feels_like:match("%d%d").."°C</span>"
        local weather_markup = "<span font='"..beautiful.font_icon.."'></span>  <span font='"..beautiful.font.."'>"..hows_weather.."</span>"

        M.weather.markup = weather_markup
        M.temp.markup = temp_markup
        M.location.markup = city_markup
    end)

    M.widget = helpers.add_margin(helpers.add_bg1(wibox.widget({
        {
            helpers.add_margin(M.title, beautiful.margin[1], beautiful.margin[1]),
            spacing = beautiful.margin[1],
            layout = wibox.layout.fixed.vertical
        },
        nil,
        {
            helpers.add_margin({
                layout = wibox.layout.fixed.vertical,
                spacing = beautiful.margin[1],
		M.location,
		M.weather,
		M.temp,
            }, beautiful.margin[1], beautiful.margin[1]),
            layout = wibox.layout.flex.horizontal
        },
        layout = wibox.layout.align.vertical
    })))

    return M.widget
end

return M
