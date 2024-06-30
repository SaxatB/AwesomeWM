req = {
	"volume",
	"brightness",
	"battery",
	"weather",
	"playerctl",
	"cpu",
	"memory",
	"uptime"
}

for _, x in pairs(req) do
	require("daemons."..x)
end
