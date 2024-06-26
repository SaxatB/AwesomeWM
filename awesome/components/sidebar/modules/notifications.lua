local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")
local helpers = require("helpers")

local M = {}

local dnd_status_file = gears.filesystem.get_configuration_dir() .. "components/sidebar/modules/dnd_stat"

local function read_dnd_status()
    local file = io.open(dnd_status_file, "r")
    if file then
        local status = file:read("*a")
        file:close()
        return status == "true"
    else
        return false
    end
end

local function write_dnd_status(status)
    local file = io.open(dnd_status_file, "w")
    if file then
        file:write(status and "true" or "false")
        file:close()
    end
end

function M.new()
    M.erase_icon = wibox.widget({
        markup = "",
        font = beautiful.font_icon,
        valign = "center",
        halign = "right",
        widget = wibox.widget.textbox
    })

    M.erase = helpers.add_bg1(M.erase_icon)
    M.erase.fg = beautiful.blue

    M.dnd_active = read_dnd_status()

    M.dnd_button = helpers.add_bg1(wibox.widget({
        markup = "",
        font = beautiful.font_icon,
        valign = "center",
        halign = "right",
        widget = wibox.widget.textbox
    }))
    M.dnd_button.fg = M.dnd_active and beautiful.fg1 or beautiful.blue

    local dnd_timer = nil

    local function start_dnd()
        if dnd_timer then
            dnd_timer:stop()
        end
        dnd_timer = gears.timer({
            timeout = 0.1,
            call_now = true,
            autostart = true,
            callback = function()
                if M.dnd_active then
                    naughty.destroy_all_notifications()
                else
                    dnd_timer:stop()
                end
            end
        })
        write_dnd_status(true)
    end

    local function stop_dnd()
        if dnd_timer then
            dnd_timer:stop()
            dnd_timer = nil
        end
        write_dnd_status(false)
    end

    function M.toggle_dnd()
        M.dnd_active = not M.dnd_active
        if M.dnd_active then
            M.dnd_button.fg = beautiful.fg1
            start_dnd()
        else
            M.dnd_button.fg = beautiful.blue
            stop_dnd()
        end
    end

    M.dnd_button:buttons(awful.util.table.join(
        awful.button({}, 1, function()
            M.toggle_dnd()
        end)
    ))

    if M.dnd_active then
        start_dnd()
    end

    M.notifications = wibox.widget({
        spacing = beautiful.margin[0],
        layout = wibox.layout.overflow.vertical,
        forced_height = beautiful.dpi(1000),
        scrollbar_width = 10,
        step = 50
    })

    M.notifications:set_scrollbar_widget(wibox.widget({
        shape = helpers.rrect(),
        widget = wibox.widget.separator
    }))

    M.erase:buttons(awful.util.table.join(awful.button({}, 1, function()
        M.notifications:reset()
    end)))

    M.widget = helpers.add_margin(helpers.add_bg1(helpers.add_margin(wibox.widget({
        helpers.add_margin(wibox.widget({
            {
                markup = "<b>Notifications</b>",
                widget = wibox.widget.textbox
            },
            nil,
            {
                M.dnd_button,
                M.erase,
                spacing = beautiful.margin[1],
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal,
        }), beautiful.margin[1], beautiful.margin[1]),
        M.notifications,
        spacing = beautiful.margin[1],
        layout = wibox.layout.fixed.vertical
    }))))

    naughty.connect_signal("request::display", function(n)
        local close_icon = wibox.widget({
            valign = "center",
            halign = "center",
            forced_width = beautiful.icon_size[1],
            forced_height = beautiful.icon_size[1],
            markup = "",
            font = beautiful.font_icon,
            widget = wibox.widget.textbox
        })

        local close_button = helpers.add_bg0(close_icon)
        close_button.fg = beautiful.red

        local icon = nil
        if n.clients[1] ~= nil then
            icon = wibox.widget({
                client = n.clients[1],
                forced_height = beautiful.icon_size[0],
                forced_width = beautiful.icon_size[0],
                widget = awful.widget.clienticon
            })
        elseif n.app_icon then
            icon = wibox.widget({
                image = n.app_icon,
                resize = true,
                forced_height = beautiful.icon_size[0],
                forced_width = beautiful.icon_size[0],
                clip_shape = helpers.rrect(),
                widget = wibox.widget.imagebox
            })
        end

        local image = nil
        if n.icon then
            image = wibox.widget({
                image = n.icon,
                resize = true,
                forced_height = beautiful.icon_size[3],
                forced_width = beautiful.icon_size[3],
                halign = "right",
                valign = "center",
                clip_shape = helpers.rrect(),
                widget = wibox.widget.imagebox
            })
        end

        local title = wibox.widget({
            layout = wibox.container.scroll.horizontal,
            step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
            fps = 60,
            speed = 75,
            {
                halign = "left",
                valign = "center",
                markup = "<b>" .. n.title .. "</b>",
                widget = wibox.widget.textbox
            }
        })

        title:pause()

        local message = wibox.widget({
            layout = wibox.container.scroll.horizontal,
            step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
            fps = 60,
            speed = 75,
            {
                halign = "left",
                valign = "center",
                markup = n.message,
                widget = wibox.widget.textbox
            }
        })

        message:pause()

        local app_name = wibox.widget({
            valign = "center",
            halign = "left",
            markup = "<b>" .. n.app_name .. "</b>",
            widget = wibox.widget.textbox
        })

        local actions = wibox.widget({
            notification = n,
            base_layout = wibox.widget({
                spacing = beautiful.margin[1],
                layout = wibox.layout.flex.horizontal
            }),
            widget_template = {
                {
                    id = "text_role",
                    valign = "center",
                    halign = "center",
                    widget = wibox.widget.textbox
                },
                shape = helpers.rrect(),
                bg = beautiful.blue,
                fg = beautiful.bg0,
                forced_height = beautiful.dpi(30),
                visible = n.actions and #n.actions > 0,
                widget = wibox.container.background
            },
            style = {
                underline_normal = false,
                underline_selected = true
            },
            widget = naughty.list.actions
        })

        local time = wibox.widget({
            markup = os.date("%I:%M %p"),
            halign = "right",
            valign = "center",
            widget = wibox.widget.textbox
        })

        local title_bar = helpers.add_margin(wibox.widget({
            {
                {
                    icon,
                    valign = "center",
                    halign = "center",
                    layout = wibox.container.place,
                },
                app_name,
                spacing = beautiful.margin[0],
                layout = wibox.layout.fixed.horizontal
            },
            nil,
            {
                time,
                close_button,
                spacing = beautiful.margin[0],
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.align.horizontal,
        }), beautiful.margin[1], beautiful.margin[0])

        local body = helpers.add_margin(wibox.widget({
            {
                image,
                {
                    title,
                    message,
                    spacing = beautiful.margin[1],
                    layout = wibox.layout.fixed.vertical
                },
                spacing = beautiful.margin[1],
                fill_space = true,
                layout = wibox.layout.fixed.horizontal
            },
            actions,
            layout = wibox.layout.fixed.vertical
        }), beautiful.margin[1], beautiful.margin[1])
        body.shape = nil

        local widget = helpers.add_bg0(wibox.widget({
            title_bar,
            body,
            forced_height = (n.actions and #n.actions > 0) and beautiful.dpi(150) or beautiful.dpi(120),
            layout = wibox.layout.fixed.vertical
        }))

        widget:connect_signal("mouse::enter", function()
            title:continue()
            message:continue()
        end)

        widget:connect_signal("mouse::leave", function()
            title:pause()
            message:pause()
        end)

        close_button:buttons({ awful.button({}, 1, function()
            M.notifications:remove_widgets(widget, true)
        end) })

        M.notifications:insert(1, widget)
    end)

    return M.widget
end

return M
