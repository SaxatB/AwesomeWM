local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local config = require("config")

local M = {}

function M.create_status_widget(icon, color)
    local icon_widget = wibox.widget({
        markup = icon,
        font = beautiful.font_icon_medium,
        valign = "center",
        halign = "center",
        widget = wibox.widget.textbox
    })

    local progressbar = wibox.widget({
        icon_widget,
        colors = { color },
        bg = beautiful.bg0,
        thickness = beautiful.dpi(8),
        forced_height = beautiful.dpi(64),
        paddings = beautiful.dpi(2),
        rounded_edge = true,
        min_value = 0,
        max_value = 100,
        widget = wibox.container.arcchart
    })

    local text = wibox.widget({
        markup = "100%",
        valign = "center",
        halign = "center",
        widget = wibox.widget.textbox
    })

    local widget = helpers.add_bg1(helpers.add_margin(wibox.widget({
        helpers.add_margin(progressbar, beautiful.margin[2], beautiful.margin[2]),
        text,
        spacing = beautiful.margin[2],
        layout = wibox.layout.fixed.vertical
    })))
    widget.fg = color

    return { widget = widget, icon = icon_widget, text = text, progressbar = progressbar }
end

function M.new()
    local cpu = M.create_status_widget("", beautiful.green)
    awesome.connect_signal("cpu::update", function(value)
        if value < 25 then
            cpu.widget.fg = beautiful.green
            cpu.progressbar.colors[1] = beautiful.green
        elseif value < 50 then
            cpu.widget.fg = beautiful.blue
            cpu.progressbar.colors[1] = beautiful.blue
        elseif value < 75 then
            cpu.widget.fg = beautiful.purple
            cpu.progressbar.colors[1] = beautiful.purple
        else
            cpu.widget.fg = beautiful.red
            cpu.progressbar.colors[1] = beautiful.red
        end
        cpu.text.markup = tostring(value).."%"
        cpu.progressbar.value = value
    end)
    local memory = M.create_status_widget("", beautiful.green)
    awesome.connect_signal("memory::update", function(value)
        if value < 25 then
            memory.widget.fg = beautiful.green
            memory.progressbar.colors[1] = beautiful.green
        elseif value < 50 then
            memory.widget.fg = beautiful.blue
            memory.progressbar.colors[1] = beautiful.blue
        elseif value < 75 then
            memory.widget.fg = beautiful.purple
            memory.progressbar.colors[1] = beautiful.purple
        else
            memory.widget.fg = beautiful.red
            memory.progressbar.colors[1] = beautiful.red
        end
        memory.text.markup = tostring(value).."%"
        memory.progressbar.value = value
    end)
    local temperature = M.create_status_widget("", beautiful.red)
    awesome.connect_signal("temperature::update", function(value)
        if value < 40 then
            temperature.widget.fg = beautiful.green
            temperature.progressbar.colors[1] = beautiful.green
        elseif value < 60 then
            temperature.widget.fg = beautiful.blue
            temperature.progressbar.colors[1] = beautiful.blue
        else
            temperature.widget.fg = beautiful.red
            temperature.progressbar.colors[1] = beautiful.red
        end
        temperature.text.markup = tostring(value).."°C"
        temperature.progressbar.value = value
    end)
    local storage = M.create_status_widget("", beautiful.purple)
    awesome.connect_signal("hdd::update", function(value)
        if value < 40 then
            storage.widget.fg = beautiful.green
            storage.progressbar.colors[1] = beautiful.green
        elseif value < 60 then
            storage.widget.fg = beautiful.blue
            storage.progressbar.colors[1] = beautiful.blue
        else
            storage.widget.fg = beautiful.red
            storage.progressbar.colors[1] = beautiful.red
        end
        storage.text.markup = tostring(value).."%"
        storage.progressbar.value = value
    end)

    M.widget = helpers.add_margin(wibox.widget({
        cpu.widget,
        memory.widget,
	storage.widget,
	temperature.widget,
        spacing = beautiful.margin[1],
        layout = wibox.layout.flex.horizontal
    }))

    return M.widget
end

return M
