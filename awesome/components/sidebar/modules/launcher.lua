local Gio = require("lgi").Gio
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local naughty = require("naughty")
local gears = require("gears")

local M = {}

M.pinned = { "Nemo", "Chromium", "Alacritty", "Sublime Text", "Theme Changer" }
M.num_visible = 3 -- Number of visible apps in launcher at one time

function M.get_apps()
	M.apps = {}
	local app_info = Gio.AppInfo
	local apps = app_info.get_all()

	for _, app in pairs(apps) do
		local name = app_info.get_display_name(app)
		local cmd = app_info.get_commandline(app)
		local exec = app_info.get_executable(app)
		local icon = helpers.get_gicon_path(app_info.get_icon(app)) or nil
		local description = Gio.AppInfo.get_description(app)
		local filter = name

		local pinned = false
		for _, pin_app in pairs(M.pinned) do
			if name == pin_app then
				pinned = true
				break
			end
		end

		if pinned then
			filter = "aaaaaaaaaa" .. filter
		end

		if name and exec and icon then
			table.insert(M.apps, {
				name = "<b>" .. name .. "</b>",
				cmd = cmd,
				exec = exec,
				icon = icon,
				filter = filter,
				description = description,
			})
		end
	end
end

function M.create_default()
	local image = wibox.widget({
		image = beautiful.icon_terminal,
		resize = true,
		valign = "center",
		halign = "center",
		forced_height = beautiful.icon_size[2],
		forced_width = beautiful.icon_size[2],
		widget = wibox.widget.imagebox,
	})

	local name = wibox.widget({
		markup = "<b>Run in terminal</b>",
		valign = "center",
		halign = "left",
		widget = wibox.widget.textbox,
	})

	local description = wibox.widget({
		text = "Run prompt input in terminal",
		valign = "center",
		halign = "left",
		widget = wibox.widget.textbox,
	})

	local background = helpers.add_bg0(helpers.add_margin(wibox.widget({
		image,
		{
			name,
			description,
			layout = wibox.layout.fixed.vertical,
		},
		spacing = beautiful.margin[1],
		layout = wibox.layout.fixed.horizontal,
	})))

	background:buttons(gears.table.join(awful.button({}, 1, function()
		M.run_default()
	end)))

	background:connect_signal("mouse::enter", function()
		background.bg = beautiful.bg1
	end)
	background:connect_signal("mouse::leave", function()
		background.bg = beautiful.bg0
	end)

	return background
end

function M.create_app_widget(app, default_bg)
	local image = wibox.widget({
		image = app.icon or beautiful.icon_default,
		resize = true,
		valign = "center",
		halign = "center",
		forced_height = beautiful.icon_size[2],
		forced_width = beautiful.icon_size[2],
		widget = wibox.widget.imagebox,
	})

	local name = wibox.widget({
		markup = app.name or "<b>Unknown</b>",
		valign = "center",
		halign = "left",
		widget = wibox.widget.textbox,
	})

	local description = wibox.widget({
		text = app.description,
		valign = "center",
		halign = "left",
		widget = wibox.widget.textbox,
	})

	local background = helpers.add_bg0(helpers.add_margin(wibox.widget({
		image,
		{
			name,
			description,
			layout = wibox.layout.fixed.vertical,
		},
		spacing = beautiful.margin[1],
		layout = wibox.layout.fixed.horizontal,
	})))

	background.bg = default_bg

	background:buttons(gears.table.join(awful.button({}, 1, function()
		M.run_app(app)
	end)))

	background:connect_signal("mouse::enter", function()
		background.bg = beautiful.blue
		background.fg = beautiful.bg0
	end)
	background:connect_signal("mouse::leave", function()
		background.bg = default_bg
		background.fg = beautiful.fg0
	end)

	return background
end

function M.update_apps()
	M.matches = {}
	for _, app in pairs(M.apps) do
		if app.filter:lower():find(M.input:lower():gsub("%W", "%%%0")) then
			table.insert(M.matches, app)
		end
	end

	table.sort(M.matches, function(a, b)
		return a.filter:lower() < b.filter:lower()
	end)

	M.list:reset()

	local selected = false
	for i = M.selected, math.min(M.selected + M.num_visible, #M.matches) do
		local app = M.matches[i]
		local default_bg = beautiful.bg0
		if i == M.selected then
			default_bg = beautiful.bg1
			selected = true
		end
		local app_widget = M.create_app_widget(app, default_bg)
		M.list:add(app_widget)
	end

	if M.selected + M.num_visible > #M.matches then
		local default = M.create_default()
		if not selected then
			default.bg = beautiful.bg1
		end
		M.list:add(default)
	end
end

function M.run_app(app)
	awful.spawn(app.exec)
	awesome.emit_signal("launcher::stop")
end

function M.run_default()
	awful.spawn(M.prompt.text:sub(1, -2))
	awesome.emit_signal("launcher::stop")
end

function M.keypressed_callback(_, mod, key, event)
	if event == "release" then
		return
	end

	local input_changed = false

	if key == "BackSpace" then
		M.input = M.input:sub(1, -2)
		input_changed = true
	elseif key == "Escape" then
		awesome.emit_signal("launcher::stop")
	elseif key == "Return" then
		if M.selected <= #M.matches then
			M.run_app(M.matches[M.selected])
		else
			M.run_default()
		end
		awesome.emit_signal("launcher::stop")
	elseif key == "Down" then
		M.selected = M.selected + 1
		if M.selected > #M.matches + 1 then
			M.selected = 1
		end
	elseif key == "Up" then
		M.selected = M.selected - 1
		if M.selected < 1 then
			M.selected = #M.matches + 1
		end
	elseif #key == 1 then
		if not M.input then
			M.input = key
		else
			M.input = M.input .. key
		end
		input_changed = true
	end

	if input_changed then
		if not M.input or M.input == "" then
			M.prompt.text = "|"
		else
			M.prompt.text = M.input .. "|"
		end
		M.selected = 1
	end

	M.update_apps()
end

function M.new()
	M.apps = {}
	M.matches = {}
	M.input = ""
	M.selected = 1

	M.keygrabber = awful.keygrabber({
		mask_event_callback = true,
		keypressed_callback = M.keypressed_callback,
	})

	M.side_text = wibox.widget({
		markup = "",
		font = beautiful.font_icon,
		valign = "center",
		halign = "center",
		widget = wibox.widget.textbox,
	})

	M.prompt = wibox.widget({
		text = "|",
		valign = "center",
		halign = "left",
		widget = wibox.widget.textbox,
	})

	M.list = wibox.widget({
		spacing = beautiful.margin[1],
		layout = wibox.layout.fixed.vertical,
	})

	M.search = helpers.add_bg1(helpers.add_margin(
		wibox.widget({
			M.side_text,
			M.prompt,
			spacing = beautiful.margin[1],
			layout = wibox.layout.fixed.horizontal,
		}),
		beautiful.margin[3],
		beautiful.margin[3]
	))

	M.widget = wibox.widget({
		helpers.add_margin(wibox.widget({
			M.search,
			M.list,
			spacing = beautiful.margin[1],
			layout = wibox.layout.fixed.vertical,
		})),
		bg = beautiful.bg0,
		forced_height = beautiful.dpi(315),
		layout = wibox.container.background,
	})

	M.widget:buttons({
		awful.button({}, 4, function()
			M.selected = M.selected - 1
			if M.selected < 1 then
				M.selected = #M.matches + 1
			end
			M.update_apps()
		end),
		awful.button({}, 5, function()
			M.selected = M.selected + 1
			if M.selected > #M.matches + 1 then
				M.selected = 1
			end
			M.update_apps()
		end),
	})

	return M.widget
end

return M
