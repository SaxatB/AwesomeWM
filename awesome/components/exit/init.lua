local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

local M = {}
M.visible = false

-- Commands
local function create_command(cmd)
    return function()
        awesome.emit_signal("exitscreen::toggle")
        if cmd then awful.spawn.with_shell(cmd) end
    end
end

M.poweroff = create_command("systemctl poweroff -i")
M.reboot = create_command("systemctl reboot -i")
M.suspend = function()
    awesome.emit_signal("exitscreen::toggle")
    awesome.emit_signal("lockscreen::toggle")
    awful.spawn.with_shell("systemctl suspend -i")
end
M.exit = awesome.quit
M.lock = function()
    awesome.emit_signal("exitscreen::toggle")
    awesome.emit_signal("lockscreen::toggle")
end

-- Goodbye text
M.username = os.getenv("USER")
M.goodbye_widget = wibox.widget.textbox("This is where it had to end, " .. M.username:sub(1,1):upper()..M.username:sub(2)..".")
M.goodbye_widget.font = "RobotoCondensed 26"
local text_font = beautiful.font or "sans 20"

-- Create button widget
local function create_button(text, icon, action)
    local text_widget = wibox.widget.textbox(text)
    text_widget.font = text_font

    local icon_widget = wibox.widget({
        image = icon,
        ontop = true,
        resize = true,
        halign = "center",
        valign = "center",
        opacity = 1.0,
        forced_height = beautiful.dpi(65),
        forced_width = beautiful.dpi(140),
        widget = wibox.widget.imagebox
    })

    local button_widget = wibox.widget({
        {
            nil,
            icon_widget,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        {
            nil,
            text_widget,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        spacing = beautiful.dpi(10),
        layout = wibox.layout.fixed.vertical
    })

    button_widget:connect_signal("button::press", action)
    helpers.add_hover_cursor(button_widget, "hand1")
    return button_widget
end

-- Buttons
local power_widget = create_button("Poweroff", beautiful.icon_power, M.poweroff)
local reboot_widget = create_button("Reboot", beautiful.icon_reboot, M.reboot)
local suspend_widget = create_button("Suspend", beautiful.icon_suspend, M.suspend)
local exit_widget = create_button("Exit", beautiful.icon_exit, M.exit)
local lock_widget = create_button("Lock", beautiful.icon_lock, M.lock)

-- Exit (Exit Screen) Button
local exit_btn = wibox.widget({
    text = "",
    font = beautiful.font_icon_medium,
    valign = "center",
    halign = "right",
    widget = wibox.widget.textbox
})

exit_btn:connect_signal("button::press", function()
	M.toggle()
end)
helpers.add_hover_cursor(exit_btn, "hand1")

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
        for _, widget in pairs(M.scr) do
            widget.visible = false
        end
        M.keygrabber:stop()
    end
end

M.background = wibox.widget({
    halign = "center",
    valign = "center",
    vertical_fit_policy = "always",
    horizontal_fit_policy = "always",
    resize = true,
    opacity = 0.25,
    clip_shape = helpers.rrect(),
    widget = wibox.widget.imagebox
})

M.widget = wibox.widget({
    M.background,
    {
	    {
	    nil,
	    nil,
            helpers.add_margin(exit_btn, beautiful.margin[2], beautiful.margin[1]),
            expand = "none",
            layout = wibox.layout.align.horizontal
    	},
        {
            {
                nil,
                M.goodbye_widget,
                nil,
                expand = "none",
                layout = wibox.layout.align.horizontal
            },
	    {
			forced_height = beautiful.dpi(40),
			opacity = 0,
			widget = wibox.widget.separator()
	    },
            {
                nil,
                {
                    power_widget,
                    reboot_widget,
                    lock_widget,
                    suspend_widget,
                    exit_widget,
                    spacing = beautiful.dpi(60),
                    layout = wibox.layout.fixed.horizontal
                },
                nil,
                expand = "none",
                layout = wibox.layout.align.horizontal
            },
            layout = wibox.layout.align.vertical
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    },
    layout = wibox.layout.stack
})

M.scr = {}

M.keygrabber = awful.keygrabber({
    mask_event_callback = true,
    keypressed_callback = function(_, _, key, event)
        local actions = {
            Escape = M.toggle,
            q = M.toggle,
            x = M.toggle,
            p = M.poweroff,
            r = M.reboot,
            l = M.lock,
            s = M.suspend,
            e = M.exit
        }
        if actions[key] then
            actions[key]()
        end
    end
})

M.background.image = gears.surface.load_uncached(beautiful.wallpaper)

screen.connect_signal("list", function()
    if M.visible then
        for _, wibox in pairs(M.scr) do
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
