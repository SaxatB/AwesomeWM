local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

local M = {}
M.visible = false
-- Commands
function M.poweroff()
	awful.spawn.with_shell("systemctl poweroff -i")
	awesome.emit_signal("exitscreen::toggle")
end

function M.reboot()
	awful.spawn.with_shell("systemctl reboot -i")
	awesome.emit_signal("exitscreen::toggle")
end

function M.suspend()
	awesome.emit_signal("exitscreen::toggle")
	awesome.emit_signal("lockscreen::toggle")
	awful.spawn.with_shell("systemctl suspend -i")
end

function M.exit()
	awesome.quit()
end

function M.lock()
	awesome.emit_signal("exitscreen::toggle")
	awful.spawn.with_shell("loginctl lock-session")
end

-- Goodbye text
M.username = os.getenv("USER")
M.goodbye_widget = wibox.widget.textbox("[ Goodbye " .. M.username:sub(1,1):upper()..M.username:sub(2) .. " ]")
text_font = beautiful.font or "sans 20"

-- Buttons and Text
-- Separator
M.sep = wibox.widget({
	forced_height = dpi(20),
	opacity = 0,
	widget = wibox.widget.separator(),
})
-- Poweroff
poweroff_text = wibox.widget.textbox("[P]oweroff")
poweroff_text.font = text_font

local power_icon = wibox.widget({
	image = beautiful.icon_power,
	ontop = true,
	resize = true,
	halign = "center",
	valign = "center",
	opacity = 1.0,
	forced_height = dpi(65),
	forced_width = dpi(140),
	widget = wibox.widget.imagebox
})

local power_widget = wibox.widget({
	{
        nil,
        power_icon,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    {
        nil,
        poweroff_text,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical
})

-- Button
power_widget:connect_signal("button::press", M.poweroff)
helpers.add_hover_cursor(power_widget, "hand1")

-- Exit
exit_text = wibox.widget.textbox("[E]xit")
exit_text.font = text_font

local exit_icon = wibox.widget({
	image = beautiful.icon_exit,
	ontop = true,
	resize = true,
	halign = "center",
	valign = "center",
	opacity = 1.0,
	forced_height = dpi(65),
	forced_width = dpi(140),
	widget = wibox.widget.imagebox
})

local exit_widget = wibox.widget({
	{
        nil,
        exit_icon,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    {
        nil,
        exit_text,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical
})

-- Button
exit_widget:connect_signal("button::press", M.exit)
helpers.add_hover_cursor(exit_widget, "hand1")

-- Suspend 
suspend_text = wibox.widget.textbox("[S]uspend")
suspend_text.font = text_font

local suspend_icon = wibox.widget({
	image = beautiful.icon_suspend,
	ontop = true,
	resize = true,
	halign = "center",
	valign = "center",
	opacity = 1.0,
	forced_height = dpi(65),
	forced_width = dpi(140),
	widget = wibox.widget.imagebox
})

local suspend_widget = wibox.widget({
	{
        nil,
        suspend_icon,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    {
        nil,
        suspend_text,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical
})

-- Button
suspend_widget:connect_signal("button::press", M.suspend)
helpers.add_hover_cursor(suspend_widget, "hand1")

-- Reboot 
reboot_text = wibox.widget.textbox("[R]eboot")
reboot_text.font = text_font

local reboot_icon = wibox.widget({
	image = beautiful.icon_reboot,
	ontop = true,
	resize = true,
	halign = "center",
	valign = "center",
	opacity = 1.0,
	forced_height = dpi(65),
	forced_width = dpi(140),
	widget = wibox.widget.imagebox
})

local reboot_widget = wibox.widget({
	{
        nil,
        reboot_icon,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    {
        nil,
        reboot_text,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical
})

-- Button
reboot_widget:connect_signal("button::press", M.reboot)
helpers.add_hover_cursor(reboot_widget, "hand1")

-- Lock 
lock_text = wibox.widget.textbox("[L]ock")
lock_text.font = text_font

local lock_icon = wibox.widget({
	image = beautiful.icon_lock,
	ontop = true,
	resize = true,
	halign = "center",
	valign = "center",
	opacity = 1.0,
	forced_height = dpi(65),
	forced_width = dpi(140),
	widget = wibox.widget.imagebox
})

local lock_widget = wibox.widget({
	{
        nil,
        lock_icon,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    {
        nil,
        lock_text,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical
})

-- Button
lock_widget:connect_signal("button::press", M.lock)
helpers.add_hover_cursor(lock_widget, "hand1")

-- Screen
function M.create_scr()
	for s in screen do
	M.scr[s] = wibox({
	    widget = M.widget,
            visible = true,
            ontop = true,
            screen = s,
            width = s.geometry.width,
            height = s.geometry.height,
            x = s.geometry.x,
            y = s.geometry.y
	})
	end
end

-- Toggle Exit Screen
function M.toggle()
    M.visible = not M.visible
    if M.visible then
        M.keygrabber:start()
        M.create_scr()
    else
        M.input = ""
        for _, widget in pairs(M.scr) do
            widget.visible = false
        end
        M.keygrabber:stop()
    end
end

function M.stop()
    M.visible = false
    M.input = ""
    for _, widget in pairs(M.scr) do
        widget.visible = false
    end
    M.keygrabber:stop()
end

M.background = wibox.widget({
        halign = "center",
        valign = "center",
        vertical_fit_policy = true,
        horizontal_fit_policy = true,
        resize = true,
        opacity = 0.5,
        clip_shape = helpers.rrect(),
        widget = wibox.widget.imagebox
})


    M.widget = wibox.widget({
    M.background,
    {
	    nil,
    {
        {
            nil,
            M.goodbye_widget,
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
	M.sep,
        {
            nil,
            {
		power_widget,
		reboot_widget,
		lock_widget,
		suspend_widget,
		exit_widget,
                spacing = dpi(60),
                layout = wibox.layout.fixed.horizontal
            },
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
            -- layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.vertical
    },
    nil,
    expand = "none",
    layout = wibox.layout.align.vertical
    },
    layout = wibox.layout.stack
    })

    M.input = ""
    M.scr = {}

    M.keygrabber = awful.keygrabber({
        -- stop_event = 'release',
        mask_event_callback = true,
        --keybindings = {awful.key {
          --  modifiers = {},
            --key = 'Return',
            --on_press = function(_)
             --   M.input = M.input
            --end
        --}},
        keypressed_callback = function(_, _, key, event)
           -- if event == "release" then
             --   return
            --end
            if key == 'Escape' or key == 'q' or key == 'x' then
		awesome.emit_signal("exitscreen::toggle")
                return
            end
	    if key == 'p' then
		-- Shutdown Script
		M.poweroff()
	    end
	    if key == 'r' then
		-- Reboot Script
		M.reboot()
	    end
	    if key == 'l' then
		-- Lock Script
		M.lock()
	    end
	    if key == 's' then
		-- Suspend Script
		M.suspend()
	    end
	    if key == 'e' then
		-- Leave Script
		M.exit()
	    end
        end
    })

    M.background.image = gears.surface.load_uncached(beautiful.wallpaper)

    screen.connect_signal("list", function()
        if M.visible then
            for s, wibox in pairs(M.scr) do
                wibox.visible = false
            end
            M.scr = {}
            M.create_scr()
        end
    end)

    awesome.connect_signal("exitscreen::toggle", function()
        M.toggle()
    end)
return M
