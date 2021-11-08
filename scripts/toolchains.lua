--
-- toolchains.lua
-- Declare toolchains to use with GENie
-- Copyright (c) 2020 Christian Helmich and the GENie project
--

premake.toolchain = { }

--
-- The list of registered tools.
--

	premake.toolchain.list = { }

--
-- Register a new toolchain.
--
-- @param a
--    The new toolchain object.
--

	function premake.toolchain.add(a)
		-- validate the tool object, at least a little bit
		local missing
		for _, field in ipairs({"description", "name", "cc", "cxx", "ar"}) do
			if (not a[field]) then
				missing = field
			end
		end

		if (missing) then
			error("tool needs a " .. missing, 3)
		end

		-- add it to the master list
		premake.toolchain.list[a.name] = a
	end

--
-- Retrieve an tool by name.
--
-- @param name
--    The name of the tool to retrieve.
-- @returns
--    The requested tool, or nil if the tool does not exist.
--

	function premake.toolchain.get(name)
		return premake.toolchain.list[name]
	end


--
-- Iterator for the list of tools.
--

	function premake.toolchain.each()
		-- sort the list by trigger
		local keys = { }
		for _, tool in pairs(premake.toolchain.list) do
			table.insert(keys, tool.name)
		end
		table.sort(keys)

		local i = 0
		return function()
			i = i + 1
			return premake.toolchain.list[keys[i]]
		end
	end



-- API --
-- Define a new tool.
--
-- @param a
--    The new tool object.
--

function newtoolchain(a)
	premake.toolchain.add(a)
end

-- per solution decide which toolchain to use
newapifield {
	name    = "toolchain",
	kind    = "string",
	scope   = "solution",
	allowed = function(value)
		if premake.toolchain.list[value] then
			return value
		end
	end,
}

-------------------------------------------------------------------------------

-- resolve env vars
--- resolves env vars written as ${name} by looking them up and replacing with their actual value
---
--- INTENDED USAGE:
--- includedirs  { table.translate(table.flatten(a.includedirs), resolve_vars) }
--- libdirs      { table.translate(table.flatten(a.libdirs), resolve_vars) }
--- buildoptions { table.translate(table.flatten(a.buildoptions), resolve_vars) }
--- linkoptions  { table.translate(table.flatten(a.linkoptions), resolve_vars) }
---
function resolve_vars(str, variables)
	local valuemap = {}
	if variables then
		for _,var in ipairs(variables) do
			local val = os.getenv(var)
			if val then
				valuemap[var] = os.getenv(var)
			else
				printf(colorize(ansicolors.red, "please set the environment variable %q"), var)
			end
		end
	end
	return str:gsub('%${%w+}', valuemap)
end

function applytoolchain(a)
	assert(a)
	if type(a) == 'string' then
		return applytoolchain(premake.toolchain.get(a))
	end

	if type(a) == 'table' then
		printf("applying toolchain settings for %q", a.name)
		if _ACTION:startswith("vs") then
			local action = premake.action.current()

			assert(a.vstudio)
			assert(a.vstudio.toolset)
			premake.vstudio.toolset = a.vstudio.toolset

			if a.vstudio.storeapp then
				premake.vstudio.storeapp = a.vstudio.storeapp
			end

			action.vstudio.windowsTargetPlatformVersion    = a.vstudio.targetPlatformVersion    or string.gsub(os.getenv("WindowsSDKVersion") or "8.1", "\\", "")
			action.vstudio.windowsTargetPlatformMinVersion = a.vstudio.targetPlatformMinVersion or string.gsub(os.getenv("WindowsSDKVersion") or "8.1", "\\", "")

		elseif _ACTION:startswith("xcode") then
			local action = premake.action.current()

			action.xcode.macOSTargetPlatformVersion = a.xcode.targetPlatformVersion
			premake.xcode.toolset = a.xcode.toolset
		end

		local tool = premake[_OPTIONS.cc or 'gcc']
		tool.cc    = resolve_vars(a.cc)
		tool.cxx   = resolve_vars(a.cxx)
		tool.ar    = resolve_vars(a.ar)
		tool.llvm  = a.llvm or false

		if a.namestyle then tool.namestyle = a.namestyle end

		configuration {}
		if a.configure then
			a.configure()
		end
		configuration {}
	end
end

-------------------------------------------------------------------------------

newtoolchain {
	name = "clang-macos-default",
	description = "Default XCode integrated clang toolchain on macOS",
	cc   = "clang",
	cxx  = "clang++",
	ar   = "ar",
	llvm = true, --optional
	namestyle = "posix", --optional
	variables = {}, --optional, environment variables to substitute to their actual path

	xcode = {
		targetPlatformVersion = "10.15",
		toolset = "macosx",
	},

	configure = function()
		removeflags {
			"UseLDResponseFile",
			"UseObjectResponseFile",
		}

		buildoptions {
			"-m64",
			"-Wshadow",
			"-msse2",
			"-Wunused-value",
			"-Wno-undef",
			"-target x86_64-apple-macos" .. "10.15",
			"-mmacosx-version-min=10.15",
			"-stdlib=libc++",
			"-Wno-unknown-warning-option",
		}

		linkoptions {
			"-mmacosx-version-min=10.15",
			"-framework Cocoa",
			"-framework CoreFoundation",
			"-framework Foundation",
			"-framework QuartzCore",
			"-framework OpenGL",
		}

		-- avoid release build errors on missing asserts
		configuration { "release" }
			buildoptions {
				"-Wno-unused-parameter",
				"-Wno-unused-variable",
			}
		configuration {}
	end
}

newtoolchain {
	name = "clang-macos",
	description = "XCode Command Line Tools on latest macOS (Big Sur)",
	cc   = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang",
	cxx  = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++",
	ar   = "ar",
	llvm = true, --optional
	namestyle = "posix", --optional
	variables = {}, --optional, environment variables to substitute to their actual path

	vstudio = {
		targetPlatformVersion = "",
		targetPlatformMinVersion = "",
		toolset = "",
		storeapp = "",
	},

	xcode = {
		targetPlatformVersion = "11.1",
		toolset = "macosx",
	},

	configure = function()
		removeflags {
			"UseLDResponseFile",
			"UseObjectResponseFile",
		}

		buildoptions {
			"-m64",
			"-Wshadow",
			"-msse2",
			"-Wunused-value",
			"-Wno-undef",
			"-stdlib=libc++",
			"-target x86_64-apple-macos" .. "11.1",
			"-mmacosx-version-min=11.1",
			"--sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk",

			os.isdir("/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1") and
			"-isystem " .. "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1" or
			"-isystem " .. "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include" ,

			os.isdir("/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1") and
			"-cxx-isystem " .. "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1" or
			"-cxx-isystem " .. "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include",

			"-Wno-unknown-warning-option",
		}

		linkoptions {
			"-mmacosx-version-min=11.1",
			"--sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk",
			"-F/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks",
			"-F/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks",
			"-framework Cocoa",
			"-framework CoreFoundation",
			"-framework Foundation",
			"-framework QuartzCore",
			"-framework OpenGL",
		}

		-- avoid release build errors on missing asserts
		configuration { "release" }
			buildoptions {
				"-Wno-unused-parameter",
				"-Wno-unused-variable",
			}
		configuration {}
	end
}

newtoolchain {
	name = "clang-windows",
	description = "clang toolchain with VS headers on Windows",
	cc   = "clang",
	cxx  = "clang++",
	ar   = "ar",
	llvm = true, --optional
	namestyle = "windows", --optional
	variables = {}, --optional, environment variables to substitute to their actual path

	vstudio = {
		targetPlatformVersion = "10.0",
		targetPlatformMinVersion = "10.0",
		toolset = "LLVM",
		storeapp = "",
	},

	xcode = {
		targetPlatformVersion = "",
		toolset = "",
	},

	configure = function()

		flags {
			"UseLDResponseFile",
			"UseObjectResponseFile",
		}

		removeflags {
			"StaticRuntime",
		}

		defines {
			"WIN32",
			"_WIN32",
			"_HAS_EXCEPTIONS=0",
			"_SCL_SECURE_NO_WARNINGS",
			"_CRT_SECURE_NO_WARNINGS",
			"_CRT_SECURE_NO_DEPRECATE",
			"strdup=_strdup",
		}

		includedirs {
			table.translate({
				path.join("${VCToolsInstallDir}", "include"),
				path.join("${WindowsSdkVerBinPath}", "um"),
			}, function(e) return resolve_vars(e, {
				"VCToolsInstallDir",
				"WindowsSdkVerBinPath",
			}) end)
		}
		libdirs {
			table.translate({
				path.join("${VCToolsInstallDir}", "lib/x64"),
				path.join("${WindowsSdkVerBinPath}", "um/x64"),
			}, function(e) return resolve_vars(e, {
				"VCToolsInstallDir",
				"WindowsSdkVerBinPath",
			}) end)
		}

		links {
			"ole32",
			"kernel32",
			"user32",
		}

		configuration { "vs*" }
			buildoptions {
				"/wd4201", -- warning C4201: nonstandard extension used: nameless struct/union
				"/wd4324", -- warning C4324: '': structure was padded due to alignment specifier
				"/Ob2",    -- The Inline Function Expansion
				"/clang:-target x86_64-pc-win32",
				"/clang:-fms-extensions",
				"/clang:-fms-compatibility",
				"/clang:-fdelayed-template-parsing",
				"/clang:-Wno-unknown-warning-option",
				"/clang:-Wno-gnu-folding-constant",
				"/clang:-Wno-unknown-warning-option",
				"/clang:-Wno-unused-command-line-argument",
				"/clang:-Wno-unused-but-set-parameter",
			}

			linkoptions {
				"/NODEFAULTLIB:libcmt",
				"/ignore:4221", -- LNK4221: This object file does not define any previously undefined public symbols, so it will not be used by any link operation that consumes this library
			}

		configuration { "not vs*" }
			buildoptions {
				"-m64",
				"-target x86_64-pc-win32",
				"-fms-extensions",
				"-fms-compatibility",
				"-fdelayed-template-parsing",
				"-Wno-undef",
				"-Wno-sign-compare",
				"-Wno-unknown-warning-option",
				"-Wno-gnu-folding-constant",
				"-Wno-unknown-warning-option",
				"-Wno-unused-command-line-argument",
				"-Wno-unused-but-set-parameter",
			}

			linkoptions {
				"-target x86_64-pc-win32",
				"-Wl,/NODEFAULTLIB:libcmt",
				"-Wl,/ignore:4221",
			}

		configuration { "debug" }
			defines {
				"_SCL_SECURE=1",
				"_SECURE_SCL=1",
				"_ITERATOR_DEBUG_LEVEL=1",
				"_HAS_ITERATOR_DEBUGGING=0",
			}
			links {
				"msvcrtd",
				"libcmtd",
			}

		configuration { "release" }
			defines {
				"_SCL_SECURE=0",
				"_SECURE_SCL=0",
				--"_ITERATOR_DEBUG_LEVEL=0",
			}
			links {
				"msvcrt",
				"libcmt",
			}

		-- avoid release build errors on missing asserts
		configuration { "vs*", "release" }
			buildoptions {
				"/clang:-Wno-unused-parameter",
				"/clang:-Wno-unused-variable",
			}
		configuration { "not vs*", "release" }
			buildoptions {
				"-Wno-unused-parameter",
				"-Wno-unused-variable",
			}
		configuration {}

		configuration {}
	end
}

newtoolchain {
	name = "clang-linux",
	description = "Clang toolchain on Linux",
	cc   = "clang",
	cxx  = "clang++",
	ar   = "ar",
	llvm = true, --optional
	namestyle = "posix", --optional
	variables = {}, --optional, environment variables to substitute to their actual path

	configure = function()
		removeflags {
			"UseLDResponseFile",
			"UseObjectResponseFile",
		}

		buildoptions {
			"-m64",
			"-Wshadow",
			"-msse2",
			"-Wunused-value",
			"-Wno-undef",
			"-stdlib=libc++",
			"-target x86_64-unknown-linux-gnu",
			"-fPIC",
			"-Wno-unknown-warning-option",
			"-Wno-unused-command-line-argument",
			"-Wno-unused-but-set-parameter",
			"-Wno-gnu-folding-constant",
		}

		links {
			"rt",
			"dl",
			"X11",
			"GL",
			"pthread",
		}
		linkoptions {
			"-Wl,--gc-sections",
			"-Wl,--as-needed",
		}

		-- avoid release build errors on missing asserts
		configuration { "release" }
			buildoptions {
				"-Wno-unused-parameter",
				"-Wno-unused-variable",
			}
		configuration {}
	end
}

newtoolchain {
	name = "emscripten-asmjs",
	description = "Emscripten toolchain to produce ASM.js",
	cc   = "emcc",
	cxx  = "em++",
	ar   = "emar",
	llvm = true, --optional
	namestyle = "Emscripten", --optional
	variables = {}, --optional, environment variables to substitute to their actual path

	configure = function()
		removeflags {
			"UseLDResponseFile",
			"UseObjectResponseFile",
		}

		buildoptions {
			"-m32",
			"-Wshadow",
			"-msse2",
			"-msimd128",
			"-Wunused-value",
			"-Wno-undef",
			--"-stdlib=libc++",
			"-Wno-unknown-warning-option",
			"-Wno-unused-command-line-argument",
			"-Wno-unused-but-set-parameter",
			"-Wno-undef",
			"-Wno-gnu-folding-constant",
		}

		linkoptions {
			"-Wl,-mwasm32",
			"-s MIN_WEBGL_VERSION=2",
			"-s MAX_WEBGL_VERSION=2",
			"-s USE_WEBGL2=1",
			"-s FULL_ES3=1",
			"-s WASM=0", -- for ASM.js
			"-s ALLOW_MEMORY_GROWTH=1",
			"-g",
		}

		-- avoid release build errors on missing asserts
		configuration { "release" }
			buildoptions {
				"-Wno-unused-parameter",
				"-Wno-unused-variable",
			}
		configuration {}
	end
}

newtoolchain {
	name = "emscripten-wasm",
	description = "Emscripten toolchain to produce WebAssembly",
	cc   = "emcc",
	cxx  = "em++",
	ar   = "emar",
	llvm = true, --optional
	namestyle = "Emscripten", --optional
	variables = {}, --optional, environment variables to substitute to their actual path

	configure = function()
		removeflags {
			"UseLDResponseFile",
			"UseObjectResponseFile",
		}

		buildoptions {
			"-m32",
			"-Wshadow",
			"-msse2",
			"-msimd128",
			"-Wunused-value",
			"-Wno-undef",
			--"-stdlib=libc++",
			"-Wno-unknown-warning-option",
			"-Wno-unused-command-line-argument",
			"-Wno-unused-but-set-parameter",
			"-Wno-undef",
			"-Wno-gnu-folding-constant",
		}

		linkoptions {
			"-Wl,-mwasm32",
			"-s MIN_WEBGL_VERSION=2",
			"-s MAX_WEBGL_VERSION=2",
			"-s USE_WEBGL2=1",
			"-s FULL_ES3=1",
			"-s ALLOW_MEMORY_GROWTH=1",
			"-g",
		}

		-- avoid release build errors on missing asserts
		configuration { "release" }
			buildoptions {
				"-Wno-unused-parameter",
				"-Wno-unused-variable",
			}
		configuration {}
	end
}


-------------------------------------------------------------------------------
