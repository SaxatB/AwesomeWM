local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local fade      = require("components.tagnotif.animations.fade")
 
local M = wibox {
  visible = false,
  opacity = 0,
  bg      = beautiful.bg_tagswitch or beautiful.bg_normal,
  fg      = beautiful.fg_tagswitch or beautiful.fg_normal,
  ontop   = true,
  height  = beautiful.tagswitch_height or beautiful.dpi(90),
  width   = beautiful.tagswitch_width or beautiful.dpi(180),
}
 
M:setup {
  {
    id     = "text",
    markup = "<b>dev</b>",
    font   = beautiful.tagswitch_font or beautiful.font,
    widget = wibox.widget.textbox,
  },
  valign = "center",
  halign = "center",
  layout = wibox.container.place,
}
 
awful.placement.bottom(M, { parent = awful.screen.focused(), margins = { bottom = beautiful.dpi(10) }})
 
M.changeText = function (text)
  M:get_children_by_id("text")[1]:set_markup("<b>" .. text .. "</b>")
end
 
M.animate = function (text)
  M.changeText(text)
  fade(M, beautiful.tagswitch_speed or 200, beautiful.tagswitch_delay or 0.25)
end
 
return M
