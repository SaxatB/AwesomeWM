req = {
	"tags",
	"titlebars",
	"error",
}

for _, x in pairs(req) do
	require("signals."..x)
end
