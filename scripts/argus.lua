--
-- Argus build configuration script
--
-------------------------------------------------------------------------------
--
-- Maintainer notes
--
-- - we're not using the regular _scaffolding_ for this project
--   mostly b/c it's too bloated
-- - scaffolds are still used though
--
-------------------------------------------------------------------------------
--
-- Use the --to=path option to control where the project files get generated. I use
-- this to create project files for each supported toolset, each in their own folder,
-- in preparation for deployment.
--
	newoption {
		trigger = "to",
		value   = "path",
		description = "Set the output location for the generated files"
	}
-------------------------------------------------------------------------------
--
-- Use the --tooolchain=identifier option to control which toolchain is used
--
	newoption {
		trigger = "toolchain",
		value   = "string",
		description = "Set the toolchain to use for compilation"
	}


-------------------------------------------------------------------------------
if not _ACTION then
	return true
end


-------------------------------------------------------------------------------
--
-- Pull in dependencies
--
	dofile("functions.lua") -- from scaffolding/system/functions.lua
	dofile("cppsettings.lua") -- from scaffolding/system/settings.lua

-------------------------------------------------------------------------------
--
-- Solution wide settings
--

local thisscriptpath = path.getabsolute(path.getdirectory(_SCRIPT))
local rootpath       = path.getabsolute(path.join(thisscriptpath, '..'))
local locationpath = path.join(os.getcwd(), _OPTIONS["to"] or path.join('build/projects'))
local targetpath   = path.join(locationpath, '../bin')
local objectpath   = path.join(locationpath, '../obj')
local librarypath   = path.join(locationpath, '../lib')

	solution "Argus"
		configurations {
			"Debug",
			"Release"
		}
		location (locationpath)

		configuration { "Debug" }
			targetsuffix ""
			defines    { "DEBUG", "_DEBUG" }

		configuration { "Release" }
			targetsuffix ""
			defines    { "RELEASE", "NDEBUG" }

		configuration { "windows" }
			targetdir (path.join(targetpath, "windows"))
			objdir    (path.join(objectpath, "windows"))

		configuration { "linux*" }
			targetdir (path.join(targetpath, "linux"))
			objdir    (path.join(objectpath, "linux"))

		configuration { "macosx" }
			targetdir (path.join(targetpath, "darwin"))
			objdir    (path.join(objectpath, "darwin"))

		configuration { "asmjs" }
			targetdir (path.join(targetpath, "asmjs"))
			objdir    (path.join(objectpath, "asmjs"))

		configuration { "wasm*" }
			targetdir (path.join(targetpath, "wasm"))
			objdir    (path.join(objectpath, "wasm"))

		configuration { "Debug" }
			defines     { "_DEBUG", }
			flags       { "Symbols" }

		configuration { "Release" }
			defines     { "NDEBUG", }
			flags       { "OptimizeSize" }

		configuration { "Debug", "windows" }
			linkoptions { "-Wl,/DEBUG:FULL" }

		configuration {}

		flags {
			"ExtraWarnings",
			"No64BitChecks",
			"StaticRuntime",
		}

		buildoptions {
			--"-fdiagnostics-show-hotness",
			"-fdiagnostics-fixit-info",
			"-fdiagnostics-color",
			"-fdiagnostics-show-note-include-stack",
			"-Wextra-tokens",
			"-Wno-undef",
		}

	if _OPTIONS.toolchain == 'windows' then
		applytoolchain('clang-windows')
	elseif _OPTIONS.toolchain == 'macosx' then
		applytoolchain('clang-macos')
	elseif _OPTIONS.toolchain == 'linux' then
		applytoolchain('clang-linux')
	elseif _OPTIONS.toolchain == 'asmjs' then
		applytoolchain('emscripten-asmjs')
	elseif _OPTIONS.toolchain == 'wasm' then
		applytoolchain('emscripten-wasm')
	end

	startproject "argus-test"

-------------------------------------------------------------------------------
--
-- External 'scaffold' projects
--

local external_scaffolds = {
	--keep
	--this
	--line
	['munit'] = dofile(path.join(rootpath, "libs", "munit", "munit.lua")),
	--keep
	--this
	--line
	--['stb'] = dofile(path.join(rootpath, "libs", "stb", "stb.lua")),
	--keep
	--this
	--line
}

create_packages_projects(external_scaffolds)

-------------------------------------------------------------------------------
--
-- Main project
--

core_projects = {
	["argus"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function()
			links { "argus" }
		end,
		_create_projects = function()
			project "argus"
				language "C"
				kind "StaticLib"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				includedirs {
					"../src",
				}

				files {
					"../src/argus_macros.h",
					"../src/argus_action.h",
					"../src/argus_action.c",
					"../src/argus_option.h",
					"../src/argus_option.c",
					"../src/argus_help.h",
					"../src/argus_help.c",
				}

				build_c99()
		end, -- _create_projects()
	},
	["argus-test"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			project "argus-test"
				targetname "argus-test"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()
				-- add_packages {
				-- 	external_scaffolds['stb'],
				-- }

				links {
					"argus",
				}

				includedirs {
					"../src",
					"../tests",
				}

				files {
					'../tests/test.c',
				}

				buildoptions {
					"-fblocks",
					"-Wno-undef",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					defines     { "PLATFORM_WINDOWS" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "macosx" }
					defines      { "PLATFORM_MACOS" }

				configuration { "linux*" }
					defines      { "PLATFORM_LINUX" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {
				}

		end, -- _create_projects()
	},
	["example-options"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "examples"
			project "example-options"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()

				links {
					"argus",
				}

				includedirs {
					"../src",
					"../examples",
				}

				files {
					'../examples/example_options.c',
				}

				configuration {}

				buildoptions {
					"-fblocks",
					"-Wno-unused-parameter",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {}

		end, -- _create_projects()
	},
	["example-actions"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "examples"
			project "example-actions"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()

				links {
					"argus",
				}

				includedirs {
					"../src",
					"../examples",
				}

				files {
					'../examples/example_actions.c',
				}

				configuration {}

				buildoptions {
					"-fblocks",
					"-Wno-unused-parameter",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {}

		end, -- _create_projects()
	},
	["example-arguments"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "examples"
			project "example-arguments"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()

				links {
					"argus",
				}

				includedirs {
					"../src",
					"../examples",
				}

				files {
					'../examples/example_arguments.c',
				}

				configuration {}

				buildoptions {
					"-fblocks",
					"-Wno-unused-parameter",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {}

		end, -- _create_projects()
	},
}

create_packages_projects(core_projects)

-------------------------------------------------------------------------------
--
-- Patch _some_ of the scaffolded projects with different properties
--

local projectkinds = {
	"consoleapp",
	"windowedapp",
	"sharedlib",
}

for _,p in ipairs(solution().projects) do
	project (p.name)
	for __,blk in ipairs(p.blocks) do
		if blk.kind and table.icontains(projectkinds, blk.kind:lower()) then
			printf("configuring targetdir for project %s %s", colorize(ansicolors.cyan, p.name), colorize(ansicolors.green, blk.kind))
			configuration {}
			configuration { blk.keywords , "windows" }
				targetdir    (path.join(rootpath, "bin/windows"))
			configuration { blk.keywords , "linux*" }
				targetdir    (path.join(rootpath, "bin/linux"))
			configuration { blk.keywords , "macosx" }
				targetdir    (path.join(rootpath, "bin/darwin"))
			configuration { blk.keywords , "asmjs" }
				targetdir    (path.join(rootpath, "bin/asmjs"))
			configuration { blk.keywords , "wasm*" }
				targetdir    (path.join(rootpath, "bin/wasm"))
			configuration {}
		end
	end
end


-------------------------------------------------------------------------------
--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
-------------------------------------------------------------------------------
--
-- Use the release action to prepare source and binary packages for a new release.
-- This action isn't complete yet; a release still requires some manual work.
--
	dofile("release.lua")

	newaction {
		trigger     = "release",
		description = "Prepare a new release (incomplete)",
		execute     = dorelease
	}

-------------------------------------------------------------------------------
--
-- Use the embed action to refresh embed source.
--
	dofile("embed.lua")

	newaction {
		trigger     = "embed",
		description = "Refresh 'embed' sources",
		execute     = doembed
	}
-------------------------------------------------------------------------------
--
-- Use the generate action to generate sources that are generated from templates.
--
	dofile("generate.lua")

	newaction {
		trigger     = "generate",
		description = "Refresh generated sources",
		execute     = dogenerate
	}

-------------------------------------------------------------------------------
--
-- Use the format action to format source files
--
	dofile("format.lua")

	newaction {
		trigger     = "format",
		description = "Format sources",
		execute     = doformat
	}
-------------------------------------------------------------------------------
--
-- Use the load-packages to load 3rd party packages
--
	function doloadpackages()
		load_packages(external_scaffolds)
	end

	newaction {
		trigger     = "loadpackages",
		description = "Load 3rd party packages",
		execute     = doloadpackages
	}
-------------------------------------------------------------------------------
