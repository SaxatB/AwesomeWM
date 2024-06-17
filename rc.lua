pcall(require, "luarocks.loader")
local awful = require("awful")
local gears  = require("gears")
local gfs = require("gears.filesystem")
require("awful.autofocus")

-- Beautiful
require("themes")

-- Signals
require("signals")

--Daemons
require("daemons")

-- Components
require("components")

-- Keys
require("keys")

-- Client rules
require("rules")

-- Notifications
require("notifications")

-- Autostart Applications
local helpers = require("helpers")
helpers.check_if_running("picom", nil, function()
	awful.spawn("picom --config " .. gfs.get_configuration_dir() .. "picom.conf", false)
end)

helpers.run_once_pgrep("copyq")
-- helpers.run_once_pgrep("mpDris2")
	--- Polkit Agent
	helpers.run_once_ps(
		"polkit-gnome-authentication-agent-1",
		"/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
	)
	--- Other stuff
-- helpers.run_once_grep("blueman-applet")
-- helpers.run_once_grep("nm-applet")
helpers.run_once_grep("numlockx")
helpers.run_once_grep("xss-lock -- " .. gfs.get_configuration_dir() .. "autolock")

-- Mem Clean
local collectgarbage = collectgarbage
collectgarbage("incremental", 110, 1000)
pcall(require, "luarocks.loader")

local memory_last_check_count = collectgarbage("count")
local memory_last_run_time = os.time()
local memory_growth_factor = 1.1 -- 10% over last
local memory_long_collection_time = 300 -- five minutes in seconds

local gtimer = require("gears.timer")
gtimer.start_new(30, function()
	local cur_memory = collectgarbage("count")
	-- instead of forcing a garbage collection every 30 seconds
	-- check to see if memory has grown enough since we last ran
	-- or if we have waited a sificiently long time
	local elapsed = os.time() - memory_last_run_time
	local waited_long = elapsed >= memory_long_collection_time
	local grew_enough = cur_memory > (memory_last_check_count * memory_growth_factor)
	if grew_enough or waited_long then
		collectgarbage("collect")
		collectgarbage("collect")
		memory_last_run_time = os.time()
	end
	-- even if we didn't clear all the memory we would have wanted
	-- update the current memory usage.
	-- slow growth is ok so long as it doesn't go unchecked
	memory_last_check_count = collectgarbage("count")
	return true
end)
