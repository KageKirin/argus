-- package geniefile for µnit

munit_script = path.getabsolute(path.getdirectory(_SCRIPT))
munit_root = path.join(munit_script, "munit")


munit_includedirs = {
	path.join(munit_root),
}

munit_libdirs = {}
munit_links = {}

munit_defines = {}

----

return {
	_load_package = function()
		if os.isdir(munit_root) then
			os.executef('git -C %s pull', munit_root)
		else
			os.executef('git clone git@github.com:nemequ/munit.git %s', munit_root)
		end
	end,

	_add_includedirs = function()
		includedirs { munit_includedirs }
	end,

	_add_defines = function()
		defines { munit_defines }
	end,

	_add_libdirs = function()
		libdirs { munit_libdirs }
	end,

	_add_external_links = function()
		links { munit_links }
	end,

	_add_self_links = function()
		links { "munit" }
	end,

	_create_projects = function()

group "thirdparty"
project "munit"
	kind "StaticLib"
	language "C"
	flags {}

	defines {
		munit_defines,
	}

	includedirs {
		munit_includedirs,
	}

	files {
		path.join(munit_root, "munit.h"),
		path.join(munit_root, "munit.c"),
	}

	configuration {}

end, -- _create_projects()
}

---
