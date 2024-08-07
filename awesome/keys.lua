local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local gears = require("gears")
local config = require("config")

local modkey = config.modkey
local apps = config.apps

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "i", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey }, "Return", function()
        awful.spawn(apps.terminal)
    end, { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey }, "e", function()
        awful.spawn(apps.file_manager)
    end, { description = "open file manager", group = "launcher" }),
    awful.key({ modkey }, "r", function()
        awesome.emit_signal("launcher::toggle")
    end, { description = "show the menubar", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "s", function()
        awful.spawn.with_shell("sh " .. gears.filesystem.get_configuration_dir() .. "screenshot area")
    end, { description = "screenshot selection", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "x", function()
        awful.spawn.with_shell("sh " .. gears.filesystem.get_configuration_dir() .. "color-picker")
    end, { description = "Color Picker", group = "launcher" }),
    awful.key({}, "Print", function()
        awful.spawn.with_shell("sh " .. gears.filesystem.get_configuration_dir() .. "screenshot full")
    end, { description = "screenshot screen", group = "launcher" }),
    awful.key({ "Mod1", "Shift" }, "x", function()
        awesome.emit_signal("lockscreen::toggle")
    end, { description = "lock screen", group = "launcher" }),
    awful.key({ modkey }, "Escape", function()
        awesome.emit_signal("exitscreen::toggle")
    end, { description = "Exit screen", group = "launcher" }),

    awful.key({
        modifiers = {},
        key = "XF86MonBrightnessUp",
        description = "brightness up",
        group = "launcher",
        on_press = function()
            awesome.emit_signal("brightness::osd")
            awesome.emit_signal("brightness::increase", 5)
        end,
    }),
    awful.key({
        modifiers = {},
        key = "XF86MonBrightnessDown",
        description = "brightness down",
        group = "launcher",
        on_press = function()
            awesome.emit_signal("brightness::osd")
            awesome.emit_signal("brightness::decrease", 5)
        end,
    }),
    awful.key({
        modifiers = {},
        key = "XF86AudioRaiseVolume",
        description = "volume up",
        group = "launcher",
        on_press = function()
            awesome.emit_signal("volume::osd")
            awesome.emit_signal("volume::increase", 5)
        end,
    }),

    awful.key({
        modifiers = {},
        key = "XF86AudioLowerVolume",
        description = "volume down",
        group = "launcher",
        on_press = function()
            awesome.emit_signal("volume::osd")
            awesome.emit_signal("volume::decrease", 5)
        end,
    }),

    awful.key({
        modifiers = {},
        key = "XF86AudioMute",
        description = "toggle mute",
        group = "launcher",
        on_press = function()
            awesome.emit_signal("volume::osd")
            awesome.emit_signal("volume::mute")
        end,
    }),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "j", function()
        awful.client.focus.byidx(1)
    end, { description = "focus next by index", group = "client" }),
    awful.key({ modkey }, "k", function()
        awful.client.focus.byidx(-1)
    end, { description = "focus previous by index", group = "client" }),
    awful.key({ "Mod1" }, "Tab", function()
        awesome.emit_signal("switcher::toggle")
    end, { description = "window switcher", group = "client" }),
    awful.key({ modkey }, "Left", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey }, "Right", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "screen" }),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift" }, "j", function()
        awful.client.swap.byidx(1)
    end, { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function()
        awful.client.swap.byidx(-1)
    end, {
        description = "swap with previous client by index",
        group = "client",
    }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey }, "l", function()
        awful.tag.incmwfact(0.05)
    end, { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey }, "h", function()
        awful.tag.incmwfact(-0.05)
    end, { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function()
        awful.tag.incnmaster(1, nil, true)
    end, {
        description = "increase the number of master clients",
        group = "layout",
    }),
    awful.key({ modkey, "Shift" }, "l", function()
        awful.tag.incnmaster(-1, nil, true)
    end, {
        description = "decrease the number of master clients",
        group = "layout",
    }),
    awful.key({ modkey, "Control" }, "h", function()
        awful.tag.incncol(1, nil, true)
    end, {
        description = "increase the number of columns",
        group = "layout",
    }),
    awful.key({ modkey, "Control" }, "l", function()
        awful.tag.incncol(-1, nil, true)
    end, {
        description = "decrease the number of columns",
        group = "layout",
    }),
    awful.key({ modkey }, "space", function()
        awful.layout.inc(1, awful.screen.focused())
    end, {
        description = "cycle layouts",
        group = "layout",
    }),
})

awful.keyboard.append_global_keybindings({
    awful.key({
        modifiers = { modkey },
        keygroup = "numrow",
        description = "only view tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
  end,
    }),
    awful.key({
        modifiers = { modkey, "Control" },
        keygroup = "numrow",
        description = "toggle tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    }),
    awful.key({
        modifiers = { modkey, "Shift" },
        keygroup = "numrow",
        description = "move focused client to tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    }),
    awful.key({
        modifiers = { modkey, "Control", "Shift" },
        keygroup = "numrow",
        description = "toggle focused client on tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    }),
    awful.key({
        modifiers = { modkey },
        keygroup = "numpad",
        description = "select layout directly",
        group = "layout",
        on_press = function(index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }),
})

awful.mouse.append_global_mousebindings({
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext),
})
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate({ context = "mouse_click" })
        end),
        awful.button({ modkey }, 1, function(c)
            c:activate({ context = "mouse_click", action = "mouse_move" })
        end),
        awful.button({ modkey }, 3, function(c)
            c:activate({ context = "mouse_click", action = "mouse_resize" })
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey }, "f", function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, { description = "toggle fullscreen", group = "client" }),
        awful.key({ modkey, "Shift" }, "c", function(c)
            c:kill()
        end, { description = "close", group = "client" }),
        awful.key(
            { modkey, "Control" },
            "space",
            awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }
        ),
        awful.key({ modkey }, "z", function(c)
            local master = awful.client.getmaster()
            c:swap(master)
            master:activate()
        end, { description = "move to master", group = "client" }),
        awful.key({ modkey }, "o", function(c)
            c:move_to_screen()
        end, { description = "move to screen", group = "client" }),
        awful.key({ modkey }, "t", function(c)
            c.ontop = not c.ontop
        end, { description = "toggle keep on top", group = "client" }),
        awful.key({ modkey }, "m", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "(un)maximize", group = "client" }),
        awful.key({ modkey, "Control" }, "m", function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, { description = "(un)maximize vertically", group = "client" }),
        awful.key({ modkey, "Shift" }, "m", function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, { description = "(un)maximize horizontally", group = "client" }),
    })
end)
