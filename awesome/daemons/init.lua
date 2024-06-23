req = {
	"volume",
	"brightness",
	"battery",
	"playerctl",
	"cpu",
	"memory",
	"temperature",
	"hdd",
	"uptime"
}

for _, x in pairs(req) do
	require("daemons."..x)
end
