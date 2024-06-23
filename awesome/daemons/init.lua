req = {
	"volume",
	"brightness",
	"battery",
	"playerctl",
	"cpu",
	"memory",
	"temperature",
	"uptime"
}

for _, x in pairs(req) do
	require("daemons."..x)
end
