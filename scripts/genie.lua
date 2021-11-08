-- entry wrapper

newoption {
	trigger = "debug-genie",
	description = "enable to attach debug to genie",
}

if _OPTIONS["debug-genie"] ~= nil then
	dofile("../scaffolding/system/debug.lua")
end

dofile('hotfixes.lua')
dofile('argus.lua')
