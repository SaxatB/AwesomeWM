
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

local header = require("components.sidebar.modules.header")
local launcher = require("components.sidebar.modules.launcher")
local media = require("components.sidebar.modules.media")
local status = require("components.sidebar.modules.status")
local notifications = require("components.sidebar.modules.notifications")
local M = {}

function M.toggle()
  M.wibox.visible = not M.wibox.visible
  if M.wibox.visible then
    M.wibox.height = awful.screen.focused().geometry.height - 4 * beautiful.useless_gap
    M.wibox.screen = awful.screen.focused()
    awful.placement.top_left(M.wibox, {
      margins = {
        top = 2 * beautiful.useless_gap,
        left = beautiful.bar_width + 2 * beautiful.useless_gap
      }
    })
    launcher.input = ""
    launcher.prompt.markup = "|"
    launcher.get_apps()
    launcher.update_apps()
    awful.spawn.easy_async_with_shell("echo $USER", function(stdout)
      stdout = stdout:gsub("[\n\r]", "")
      header.name.markup = "<b>@" .. stdout .. "</b>"
    end)
    launcher.keygrabber:start()
  else
    launcher.keygrabber:stop()
  end
end

function M.stop()
  M.wibox.visible = false
  launcher.keygrabber:stop()
end

function M.new()
  M.header = header.new()
  M.launcher = launcher.new()
  M.media = media.new()
  M.status = status.new()
  M.notifications = notifications.new()

  M.widget = helpers.add_margin(wibox.widget({
    M.header,
    M.launcher,
    {
    	M.media,
    	M.status,
    	layout = wibox.layout.flex.horizontal
    },
    M.notifications,
    fill_space = true,
    spacing = beautiful.margin[0],
    layout = wibox.layout.fixed.vertical
  }), beautiful.margin[2], beautiful.margin[2])

  M.wibox = wibox({
    widget = M.widget,
    shape = helpers.rrect(),
    ontop = true,
    visible = false,
    width = beautiful.dpi(540),
    height = awful.screen.focused().geometry.height - 4 * beautiful.useless_gap,
    border_color = beautiful.border_color_active,
    border_width = beautiful.border_width,
  })

  awesome.connect_signal("launcher::toggle", function()
    M.toggle()
  end)

  awesome.connect_signal("launcher::stop", function()
    M.stop()
  end)
end

M.new()
