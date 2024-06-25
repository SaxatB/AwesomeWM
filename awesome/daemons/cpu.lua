local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local M = {}

M.interval = 2

-- Function to parse /proc/stat and get CPU usage times
local function get_cpu_times()
    local cpu_line = io.open("/proc/stat", "r"):read()
    local user, nice, system, idle, iowait, irq, softirq, steal = cpu_line:match("cpu  (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+)")
    user, nice, system, idle, iowait, irq, softirq, steal = tonumber(user), tonumber(nice), tonumber(system), tonumber(idle), tonumber(iowait), tonumber(irq), tonumber(softirq), tonumber(steal)
    local total = user + nice + system + idle + iowait + irq + softirq + steal
    local total_idle = idle + iowait
    return total, total_idle
end

-- Variables to store initial CPU times
local initial_total, initial_idle = get_cpu_times()

function M.update()
    local final_total, final_idle = get_cpu_times()

    local total_diff = final_total - initial_total
    local idle_diff = final_idle - initial_idle

    local cpu_usage = (total_diff - idle_diff) / total_diff * 100

    awesome.emit_signal("cpu::update", math.floor(cpu_usage))

    initial_total, initial_idle = final_total, final_idle
end

function M.start()
    gears.timer {
        timeout = M.interval,
        autostart = true,
        call_now = true,
        callback = M.update
    }
end

M.start()
