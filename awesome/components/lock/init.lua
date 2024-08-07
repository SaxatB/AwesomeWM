local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local pam = require("liblua_pam")

local clock = require("components.lock.modules.clock")
local circle = require("components.lock.modules.circle")

local M = {}
M.visible = false

function M.auth()
    return pam.auth_current_user(M.input)
end

function M.create_wiboxes()
    for s in screen do
        M.wiboxes[s] = wibox({
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

function M.update_wiboxes()
    for s in screen do
        local w = M.wiboxes[s]
        if w then
            w:geometry({
                width = s.geometry.width,
                height = s.geometry.height,
                x = s.geometry.x,
                y = s.geometry.y
            })
        end
    end
end

function M.toggle()
    if not M.visible then
        M.visible = true
        M.create_wiboxes()
        M.keygrabber:start()
    end
end

function M.stop()
    circle.reset()
    M.visible = false
    M.input = ""
    for _, widget in pairs(M.wiboxes) do
        widget.visible = false
    end
    M.keygrabber:stop()
end

function M.new()
    M.clock = clock.new()
    M.circle = circle.new()

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
            M.clock,
            valign = "center",
            halign = "center",
            layout = wibox.container.place
        },
        {
            M.circle,
            valign = "bottom",
            halign = "left",
            layout = wibox.container.place
        },
        layout = wibox.layout.stack
    })

    M.input = ""
    M.wiboxes = {}

    M.keygrabber = awful.keygrabber({
        stop_event = 'release',
        mask_event_callback = true,
        keybindings = {awful.key {
            modifiers = {'Mod1', 'Mod4', 'Shift', 'Control'},
            key = 'Return',
            on_press = function(_)
                M.input = M.input
                circle.random()
            end
        }},
        keypressed_callback = function(_, _, key, event)
            if event == "release" then
                return
            end
            if key == 'Escape' then
                M.input = ""
                circle.random()
                return
            end

            if key == "BackSpace" then
                if #M.input > 0 then
                    circle.random()
                end
                M.input = M.input:sub(1, -2)
            end

            if #key == 1 then
                circle.random()
                if not M.input then
                    M.input = key
                else
                    M.input = M.input .. key
                end
            end
        end,
        keyreleased_callback = function(_, _, key, _)
            if key == "Return" then
                if M.auth() then
                    M.stop()
                else
                    M.input = ""
                end
            end
        end
    })

    M.background.image = gears.surface.load_uncached(beautiful.wallpaper)

    awful.spawn.easy_async("fprintd-verify", function(out)
	    if out:match("verify%-match") then
		M.stop()
	    elseif out:match("verify%-no%-match") then
		M.input = ""
	    end
    end)

    screen.connect_signal("list", function()
        if M.visible then
            for s, wibox in pairs(M.wiboxes) do
                wibox.visible = false
            end
            M.wiboxes = {}
            M.create_wiboxes()
        end
    end)

    screen.connect_signal("property::geometry", function()
        if M.visible then
            M.update_wiboxes()
        end
    end)

    awesome.connect_signal("lockscreen::toggle", function()
        M.toggle()
    end)

    return M
end

return M.new()
