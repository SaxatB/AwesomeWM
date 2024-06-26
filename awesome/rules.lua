local awful = require("awful")
local ruled = require("ruled")
ruled.client.connect_signal("request::rules", function()
	-- All clients will match this rule.
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen + awful.placement.centered,
		},
	})

	-- Floating clients.
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = { "copyq", "pinentry" },
			class = {
				"Blueman-manager",
				"Gpick",
				"Gnome-multi-writer",
			},
			name = {
				"Event Tester",
			},
			role = {
				"AlarmWindow",
				"ConfigManager",
				"pop-up",
			},
		},
		properties = { floating = true },
	})

	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule({
		id = "titlebars",
		rule_any = {
			type = { "normal" },
		},
		except_any = { 
			class = { "Gnome-disks", "Gedit", "Gnome-multi-writer", "Gcr-prompter", "io.github.celluloid_player.Celluloid" },
			role = { "browser" } 
		},
		properties = { titlebars_enabled = true },
	})
end)
