-------------------------------------------------------------------------------
---
--- GENie hotfixes
---
--- trying to solve a couple of issues by hot-patching the lua structures
---
-------------------------------------------------------------------------------

--- add 'clang'
dofile("clang.lua")

--- add 'clang' as valid option to --cc
local opt_cc = premake.option.get('cc')
table.insert(opt_cc.allowed, { "clang", "LLVM Clang (clang/clang++)" })

--- add 'clang' as valid type to actions
local act_cmake = premake.action.get('cmake')
table.insert(act_cmake.valid_tools.cc, 'clang')

local act_jcdb = premake.action.get('jcdb')
table.insert(act_jcdb.valid_tools.cc, 'clang')

local act_gmake = premake.action.get('gmake')
table.insert(act_gmake.valid_tools.cc, 'clang')

local act_ninja = premake.action.get('ninja')
table.insert(act_ninja.valid_tools.cc, 'clang')

local act_xcode8 = premake.action.get('xcode8')
table.insert(act_xcode8.valid_tools.cc, 'clang')

local act_xcode9 = premake.action.get('xcode9')
table.insert(act_xcode9.valid_tools.cc, 'clang')

local act_xcode10 = premake.action.get('xcode10')
table.insert(act_xcode10.valid_tools.cc, 'clang')

-------------------------------------------------------------------------------

dofile("toolchains.lua")

-------------------------------------------------------------------------------

--- patch-in namestyle for windows configs
----> solves issues with static libs being written as .a in ninja or make

if _OPTIONS.os == "windows" or os.is("windows") then
	premake.platforms["Native"].namestyle = "windows"
	premake.platforms["x32"].namestyle = "windows"
	premake.platforms["x64"].namestyle = "windows"
end

-------------------------------------------------

--- patch-in fixed gcc.islibfile for windows configs
----> was implemented wrongly for namestyle windows

premake.gcc.islibfile = function(cfg, p)
	local namestyle = premake.getnamestyle(cfg)
	if namestyle:lower() == "windows"    and path.getextension(p) == ".lib" then
		return true
	end
	if namestyle:lower() == "posix"      and path.getextension(p) == ".a" then
		return true
	end
	if namestyle:lower() == "emscripten" and path.getextension(p) == ".bc" then
	end
	return false
end

premake.gcc.getlinkflags = function(cfg)
	local result = {}
	for _, value in ipairs(premake.getlinks(cfg, "system", "fullpath")) do
		if premake.gcc.islibfile(cfg, value) and path.getdirectory(value) ~= "." then
			value = path.rebase(value, cfg.project.location, cfg.location)
			table.insert(result, _MAKE.esc(value))
		elseif path.getextension(value) == ".framework" then
			table.insert(result, '-framework ' .. _MAKE.esc(path.getbasename(value)))
		else
			table.insert(result, '-l' .. _MAKE.esc(path.getbasename(value)))
		end
	end
	return result
end

-------------------------------------------------
