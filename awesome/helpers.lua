-- Contains a bunch of useful helper functions

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local lgi = require("lgi")
local Gio = lgi.Gio
local Gtk = lgi.require("Gtk", "3.0")
local capi = { mouse = mouse }

local M = {}

function M.rrect()
  return function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, beautiful.radius)
  end
end

function M.circle()
  return function(cr, width, height)
    gears.shape.circle(cr, width, height)
  end
end

-- Makes widget change color on hover
function M.add_click(widget, color)
  color = color or beautiful.blue
  local background = wibox.widget({
    widget,
    shape = M.rrect(),
    layout = wibox.container.background,
  })

  background:connect_signal("mouse::enter", function()
    background.fg = beautiful.bg0
    background.bg = color
  end)

  background:connect_signal("mouse::leave", function()
    background.fg = beautiful.fg0
    background.bg = "#00000000"
  end)

  return background
end

-- Adds background to widget
function M.add_bg0(widget)
  local background = wibox.widget({
    widget,
    layout = wibox.container.background,
    bg = beautiful.bg0,
    fg = beautiful.fg0,
    shape = M.rrect()
  })
  return background
end

function M.add_bg1(widget)
  local background = wibox.widget({
    widget,
    layout = wibox.container.background,
    bg = beautiful.bg1,
    fg = beautiful.fg0,
    shape = M.rrect()
  })
  return background
end

function M.add_bg(widget)
  return wibox.widget({
    widget,
    shape = M.rrect(),
    layout = wibox.container.background
  })
end

-- Creates tooltip
function M.add_tooltip(widget, markup)
  return awful.tooltip({
    objects = { widget },
    markup = markup,
    shape = M.rrect(),
    margins_leftright = beautiful.margin[1],
    margins_topbottom = beautiful.margin[1],
    border_width = beautiful.border_width,
    border_color = beautiful.border_color_active,
  })
end

-- Helpers for Exit Screen
function M.add_hover_cursor(w, hover_cursor)
	local original_cursor = "left_ptr"

	w:connect_signal("mouse::enter", function()
		local widget = capi.mouse.current_wibox
		if widget then
			widget.cursor = hover_cursor
		end
	end)

	w:connect_signal("mouse::leave", function()
		local widget = capi.mouse.current_wibox
		if widget then
			widget.cursor = original_cursor
		end
	end)
end

-- Live Reload
function M.live(w, properties)
    local widget = w()

	for property, arg in pairs(properties) do
		widget[property] = beautiful[arg]
	end
        widget:emit_signal("widget::redraw_needed")
    return widget
end

-- Adds margin to widget
function M.add_margin(widget, h, v)
  h = h or beautiful.margin[0]
  v = v or beautiful.margin[0]
  return wibox.container.margin(widget, h, h, v, v)
end

-- Icons
M.gtk_theme = Gtk.IconTheme.get_default()
M.apps = Gio.AppInfo.get_all()

function M.get_icon(client_name)
  if not client_name then
    return nil
  end

  local icon_info = M.gtk_theme:lookup_icon(client_name, beautiful.icon_size[3], 0)
  if icon_info then
    local icon_path = icon_info:get_filename()
    if icon_path then
      return icon_path
    end
  end

  return nil
end

function M.get_gicon_path(gicon)
  if not gicon then
    return nil
  end

  local info = M.gtk_theme:lookup_by_gicon(gicon, beautiful.icon_size[3], 0)
  if info then
    return info:get_filename()
  end
end

--- Run Functions
local tostring = tostring
local string = string
local ipairs = ipairs
local math = math
local os = os

function M.run_once_pgrep(cmd)
	local findme = cmd
	local firstspace = cmd:find(" ")
	if firstspace then
		findme = cmd:sub(0, firstspace - 1)
	end
	awful.spawn.easy_async_with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

function M.run_once_ps(findme, cmd)
	awful.spawn.easy_async_with_shell(string.format("ps -C %s|wc -l", findme), function(stdout)
		if tonumber(stdout) ~= 2 then
			awful.spawn(cmd, false)
		end
	end)
end

function M.run_once_grep(command)
	awful.spawn.easy_async_with_shell(string.format("ps aux | grep '%s' | grep -v 'grep'", command), function(stdout)
		if stdout == "" or stdout == nil then
			awful.spawn(command, false)
		end
	end)
end

function M.check_if_running(command, running_callback, not_running_callback)
	awful.spawn.easy_async_with_shell(string.format("ps aux | grep '%s' | grep -v 'grep'", command), function(stdout)
		if stdout == "" or stdout == nil then
			if not_running_callback ~= nil then
				not_running_callback()
			end
		else
			if running_callback ~= nil then
				running_callback()
			end
		end
	end)
end

return M
