local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local helpers = require("helpers")
local naughty = require("naughty")

-- Timer for detecting double clicks
local double_click_timer = nil
local double_click_interval = 0.20

-- Titlebars
client.connect_signal("request::titlebars", function(c)
local buttons = { awful.button({}, 1, function()
      c:activate({
        context = "titlebar",
        action = "mouse_move"
      })
      end), 
    awful.button({}, 3, function()
   local clients = awful.screen.focused().clients
   if #clients == 1 then
          c.floating = true
   end
      c:activate({
        context = "titlebar",
        action = "mouse_resize"
      }) end)}

  local close_icon = wibox.widget({
    valign = "center",
    halign = "center",
    markup = "",
    forced_width = beautiful.icon_size[1],
    forced_height = beautiful.icon_size[1],
    font = beautiful.font_icon,
    widget = wibox.widget.textbox
  })
  local close_button = helpers.add_bg(close_icon)
  close_button:buttons({ awful.button({}, 1, function()
    c:kill()
  end) })

  local minimize_icon = wibox.widget({
      valign = "center",
      halign = "center",
      markup = "",
      forced_width = beautiful.icon_size[1],
      forced_height = beautiful.icon_size[1],
      font = beautiful.font_icon,
      widget = wibox.widget.textbox
  })

  local minimize_button = helpers.add_bg(minimize_icon)
  minimize_button:buttons({ awful.button({}, 1, function()
	  gears.timer.delayed_call(function()
		  c.minimized = true
	  end)
  end) })

  local maximize_icon = wibox.widget({
    valign = "center",
    halign = "center",
    markup = "",
    forced_width = beautiful.icon_size[1],
    forced_height = beautiful.icon_size[1],
    font = beautiful.font_icon,
    widget = wibox.widget.textbox
  })

  local maximize_button = helpers.add_bg(maximize_icon)
  maximize_button:buttons({ awful.button({}, 1, function()
    c.maximized = not c.maximized
  end) })

  local left_widget = helpers.add_margin(wibox.widget({
    {
      image = c.icon or helpers.get_icon(c.class) or beautiful.icon_default,
      resize = true,
      valign = "center",
      halign = "center",
      widget = wibox.widget.imagebox,
    },
    {
      halign = "left",
      valign = "center",
      markup = "<b>" .. (c.class or c.name or "unknown"):gsub("^%l", string.upper) .. "</b>",
      widget = wibox.widget.textbox,
      font = beautiful.font_small
    },
    buttons = buttons,
    spacing = beautiful.margin[1],
    layout = wibox.layout.fixed.horizontal
  }))

  local right_widget = helpers.add_margin(wibox.widget({
    minimize_button,
    maximize_button,
    close_button,
    layout = wibox.layout.align.horizontal
  }))

  local grab = helpers.add_margin(wibox.widget({
    {
      widget = wibox.widget.separator(),
      opacity = 0,
    },
    buttons = buttons,  
    layout = wibox.layout.fixed.horizontal
  }))

  -- Add single and double click detection to the grab widget
  grab:buttons(gears.table.join(
    awful.button({}, 1, function()
      if double_click_timer then
        double_click_timer:stop()
        double_click_timer = nil
        c.maximized = not c.maximized
        c:raise()
      else
        double_click_timer = gears.timer.start_new(double_click_interval, function()
          double_click_timer = nil
          c:activate({ context = "titlebar", action = "mouse_move" })
          return false
        end)
      end
    end)
  ))

  local titlebar_widget = helpers.add_margin(wibox.widget({
    left_widget,
    grab,
    right_widget,
    layout = wibox.layout.align.horizontal
  }))

  local titlebar = awful.titlebar(c, {
    size = beautiful.titlebar_height
  })

  titlebar.widget = titlebar_widget

  c.shape = helpers.rrect()
  client.connect_signal("focus", function()
    if c.active then
      minimize_button.fg = beautiful.orange
      maximize_button.fg = beautiful.green
      close_button.fg = beautiful.red
    else
      minimize_button.fg = beautiful.bg1
      maximize_button.fg = beautiful.bg1
      close_button.fg = beautiful.bg1
    end
  end)
end)

client.connect_signal("request::manage", function(c)
  if not awesome.startup then
    awful.client.setslave(c)
  end

  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
    awful.placement.no_offscreen(c)
  end
end)

client.connect_signal("property::maximized", function(c)
  if c.maximized then
    c.shape = nil
  else
    c.shape = helpers.rrect()
  end
end)

client.connect_signal("property::fullscreen", function(c)
  if c.fullscreen then
    c.shape = nil
  else
    c.shape = helpers.rrect()
  end
end)
