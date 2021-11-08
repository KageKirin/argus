-- functions
require "ansicolors"

function colorize(clr, txt)
	return clr .. txt .. ansicolors.reset
end

function string.symbolicate(str)
	return str:gsub("[/%.]", "_")
end

function string.prefix_camelCase(str)
	local p = str:explode('_')
	local r = p[1] .. "_" .. p[2]
	for i=3,#p,1 do
		r = r .. p[i]:gsub("(%w)(%w+)", function(a, b) return a:upper() .. b end)
	end
	return r
end

function string.prefix_PascalCase(str)
	local p = str:explode('_')
	local r = p[1] .. "_"
	for i=2,#p,1 do
		r = r .. p[i]:gsub("(%w)(%w+)", function(a, b) return a:upper() .. b end)
	end
	return r
end

function string.camelCase(str)
	local p = str:explode('_')
	local r = p[1]
	for i=2,#p,1 do
		r = r .. p[i]:gsub("(%w)(%w+)", function(a, b) return a:upper() .. b end)
	end
	return r
end

function string.PascalCase(str)
	local p = str:explode('_')
	local r = ""
	for i=1,#p,1 do
		r = r .. p[i]:gsub("(%w)(%w+)", function(a, b) return a:upper() .. b end)
	end
	return r
end


function table.index(t,item)
	for i,e in ipairs(t) do
		if e == item then return i end
	end
	return nil
end

function table.sortednext(t,cur)
	local keys = table.keys(t)
	table.sort(keys)
	local i = table.index(keys,cur)
	return i and keys[i+1] or nil
end

function clone(t) -- deep-copy a table
	if type(t) ~= "table" then return t end
	local meta = getmetatable(t)
	local target = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			target[k] = clone(v)
		else
			target[k] = v
		end
	end
	setmetatable(target, meta)
	return target
end

-- helper functions

function isMacBuild()
	return _ACTION:match('xcode[0-9]')
		or _OPTIONS["gcc"] == 'osx'
end

function isIosBuild()
	return _ACTION:match('xcode[0-9]')
		or _OPTIONS["gcc"] == 'ios'
end


function isWinBuild()
	return _ACTION:match('vs[0-9]')
end


function isLinuxBuild()
	return  _ACTION:match('gmake')
		and os.is('linux')
end
----

-- special function to set define macros with string values
function stringMacroDeclaration(name, value)
	if _ACTION:match('xcode[0-9]') then
		return string.format('%s=\'"%s"\'', name, value)
	elseif _ACTION:match('gmake') then
		return string.format('%s="%s"', name, value)
	else
		return string.format('%s="%s"', name, value)
	end
end

----

function correctPath(oldPath)
	local getRel = function(p)
		local prj = project()
		local prjdir = os.getcwd()
		if prj ~= nil then
			prjdir = prj.basedir
		end
		local sln = solution()
		local slndir = sln.basedir
		local pathFromSlndir = path.join(slndir, oldPath)
		local rep = path.getrelative(prjdir, pathFromSlndir)
	end

	if oldPath == nil then
		return nil
	elseif type(oldPath) == 'table' then
		return table.translate(oldPath, getRel)
	end

	return getRel(oldPath)
end

----

function currentDir()
	local sln = solution()
	local slndir = sln.basedir
	return path.getrelative(slndir, os.getcwd())
end

----

function pathRelativeToSolutionLocation(oldPath)
	local getRel = function(p)
		local sln = solution()
		local slndir = path.getabsolute(sln.location)
		return path.getrelative(slndir, path.getabsolute(p))
	end

	if oldPath == nil then
		return nil
	elseif type(oldPath) == 'table' then
		return table.translate(oldPath, getRel)
	end

	return getRel(oldPath)
end

----

function printTable(t)
	if t == nil then
		printf('nil table')
		return
	end
	if tableSize(t) == 0 then
		printf('empty table')
		return
	end
	print(t)
	for k,v in pairs(t) do
		print(colorize(ansicolors.green, k), v)
	end
end

function printTableReq(t)
	local function rr(tt)
		if tt == nil then
			printf('nil table')
			return
		end
		if tableSize(tt) == 0 then
			printf('empty table')
			return
		end
		print(tt)
		if type(tt) == 'table' then
			rr(tt)
		else
			for k,v in pairs(tt) do
				print(colorize(ansicolors.green, k), v)
			end
		end
	end
	rr(t)
end


function debugTable(name, t)
	print(colorize(ansicolors.yellow, name))
	printTable(t)
end

function debugTableReq(name, t)
	print(colorize(ansicolors.yellow, name))
	printTableReq(t)
end
----

function mergeTables(t1, t2)
	if t2 then
		for i, p in pairs(t2) do
			table.insert(t1, p)
		end
	end
	return t1
end

---

function flattenTable(t)
	local result = { }

	local function flatten(t)
		for _, v in pairs(t) do
			if type(v) == "table" then
				flatten(v)
			else
				table.insert(result, v)
			end
		end
	end

	flatten(t)
	return result
end

---

function joinTables(...)
	local result = { }
	for _,t in pairs(arg) do
		if type(t) == "table" then
			for _,v in pairs(t) do
				table.insert(result, v)
			end
		else
			table.insert(result, t)
		end
	end
	return result
end

---

----

function tableSize(t)
	local count = 0
	for i, p in pairs(t) do
		count = count + 1
	end
	return count
end
----

function flatC(filename)
	local flatc = path.join(SCAFFOLDING_TOOLS_DIR, "_flatc.sh")
	local cmd = flatc .. " " .. filename .. " ."
	printf(cmd)
	os.execute(cmd)
end

---

function gatherDynLibs_postbuildcommands(_searchDirs)
	local cfg = configuration()

	sd = cfg.libdirs
	for _, dirs in pairs(_searchDirs) do
		mergeTables(sd, dirs)
	end

	for _, lib in pairs(cfg.links) do
		for _, libdir in pairs(sd) do
			libfile = path.join(libdir, lib)
			if isWinBuild() then
				libfile = libfile .. ".dll"
			elseif isMacBuild() or isIosBuild() then
				libfile = libfile .. ".dylib"
			elseif isLinuxBuild() then
				libfile = libfile .. ".so"
			end
			--print("searching", libfile)

			absfile = path.getabsolute(libfile)
			if os.isfile(absfile) then
				if isWinBuild() then
					postbuildcommands { "copy " .. absfile .. " " .. cfg.targetdir }
				else
					postbuildcommands { "cp " .. absfile .. " " .. cfg.targetdir }
				end
			end
		end
	end
end

---
-- Lua implementation of PHP scandir function

function scandir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen(iif(os.is("windows"), 'dir /b /a "'..directory..'"', 'ls -a "'..directory..'"'))
	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end
	pfile:close()
	return t
end


---
--

function fixup_bin_extension(terms, ext)
	debugTable("terms", terms)

	local cfg = configuration(terms)
	debugTable("cfg.terms", cfg.terms)
	print("cfg.kind", cfg.kind)

	for _, cc in pairs(configurations()) do
		debugTable("cc", cc)
		print("cc.kind", cc.kind)
		if cc.kind == "ConsoleApp" then
			configuration {terms, cc}
				targetextension (ext)
		end
	end


	configuration {}
end

---

-- iterates of list of project files in given folder

function do_project_files_obsolete(_folder, _projects)
	if _projects then
		for _, pf in pairs(_projects) do
			dofile(path.join(_folder, pf))
		end
	end
end


-- executes a function iif it exists
function safe_fun(fun)
	if fun ~= nil then
		fun()
	end
end


-- adds sources files in groups
-- { ['group'] = {files...},}
function add_sourcegroups(_sourceGroups)
	for name, sources in pairs(_sourceGroups) do
		--print(sources)
		--debugTable(name, sources)
		files(sources)
		vpaths{
			[name] = sources}
	end
end


-- add frameworks to install
-- Mac/iOS only
function install_frameworks(_frameworks)
	if false then -- xcodecopyframeworks ~= nil then
	links {
		_frameworks,
	}
	xcodecopyframeworks {
		_frameworks,
	}
	end
	xcodescriptphases {
		{'echo installing frameworks', table.concat(table.flatten(_frameworks), " ")},
		{'carthage copy-frameworks', table.flatten(_frameworks)},
	}
end

-- packages are scaffolding v2 luafiles
-- add package settings to current project
function add_packages(_packages)
	if _packages then
		for _, pkg in pairs(_packages) do
			-- explicitely NOT checking for nil pkg in order to fail!
			pkg._add_includedirs()
			pkg._add_defines()

			configuration { "not StaticLib" }
				pkg._add_libdirs()
				pkg._add_external_links()
				pkg._add_self_links()

				if pkg._add_assets then
					pkg._add_assets()
				end
			configuration {}
		end
	end
end

function add_packages_conditional(_condition, _packages)
	if type(_condition) == 'function' then
		if _condition() then
			add_packages(_packages)
		end
	else
		if _condition then
			add_packages(_packages)
		end
	end
end

-- add package header + define settings to current project
function add_packages_headers(_packages)
	if _packages then
		for _, pkg in pairs(_packages) do
			-- explicitely NOT checking for nil pkg in order to fail!
			pkg._add_includedirs()
			pkg._add_defines()
		end
	end
end

function add_packages_headers_conditional(_condition, _packages)
	if type(_condition) == 'function' then
		if _condition() then
			add_packages_headers(_packages)
		end
	else
		if _condition then
			add_packages_headers(_packages)
		end
	end
end

-- load/install packages on system
function load_packages(_packages)
	if _packages then
		for _, pkg in pairs(_packages) do
			if pkg._load_package then
				pkg._load_package()
			end
		end
	end
end

-- creates projects for packages
function create_packages_projects(_packages)
	if _packages then
		for k, pkg in pairs(_packages) do
			-- explicitely NOT checking for nil pkg in order to fail!
			print('creating projects for package', colorize(ansicolors.cyan, k))
			pkg._create_projects()
		end
	end
end

-- reresh project packages
function refresh_packages_projects(_packages)
	if _packages then
		for k, pkg in pairs(_packages) do
			if pkg['_refresh_project'] then
				print('refreshing project package', colorize(ansicolors.cyan, k))
				pkg._refresh_project()
			end
		end
	end
end

---

function filter_non_unitbuild_sources(_sourceGroups, _unitbuildFileTag, _softExclude)
	local result = { }
	for _,g in pairs(flattenTable(_sourceGroups)) do
		for __,f in pairs(os.matchfiles(g)) do
			if not string.match(f, '(.*)('.. _unitbuildFileTag ..').(.*)') then
				table.insert(result, f)
			end
		end
	end

	if _softExclude == true then
		excludes { result }
	else
		removefiles { result }
	end
end

---

function addPrecompiledHeader(header, source)
	local prj = project()
	local loc = prj.location
	if prj.location == nil then
		local sln = solution()
		loc = sln.location
	end

	local rel_header = path.getrelative(loc or ".", header)

	if header ~= nil then
		configuration {}
			pchheader(header)
		configuration { "osx or ios*" }
			xcodeprojectopts {
				["GCC_PREFIX_HEADER"] = rel_header,
			}
		configuration { "vs*" }
			buildoptions {
				string.format("/FI\"%s\"", rel_header),
			}
		configuration { "gmake", "android*" } -- actually, for anything 'clang'
			buildoptions {
				--string.format("-include-pch \"%s\"", rel_header),
				string.format("-include\"%s\"", rel_header),
			}
		configuration { "ninja", "android*" } -- actually, for anything 'clang'
			buildoptions {
				--string.format("-include-pch \"%s\"", rel_header),
				string.format("-include%s", rel_header),
			}
		configuration { "cmake", "android*" } -- actually, for anything 'clang'
			buildoptions {
				--string.format("-include-pch \"%s\"", rel_header),
				string.format("-include%s", rel_header),
			}
		configuration {}
	end

	if source ~= nil then
		configuration {}
			pchsource(source)
		configuration {}
	end
end

---

function removeObjectiveCFiles(_pname, _rootdir, _cterms)
	project(_pname)

	configuration {}
	configuration {_cterms or {"not osx", "not ios*"}}
		defines {
			"SCFD_DEBUG__THIS_CONFIG_SHOULD_NOT_HAVE_OBJC_FILES",
		}
		removefiles {
			path.join(_rootdir, "**.m"),
			path.join(_rootdir, "**.mm"),
		}
	configuration {}
end

---
-- hasSourceFiles({[vpath] = {files...}})
-- returns true if there _any compilable_ files in the source groups
-- return false if not
-- this can be used to check whether libs need to be linked (i.e. yield a lib_.a)
-- or not (e.g. header only libs)
function hasSourceFiles(_sourceGroups)
	for _, files in pairs(_sourceGroups) do
		for __, ptn in ipairs(files) do
			local f = os.matchfiles(ptn)
			for _,i in ipairs(f) do
				if path.issourcefile(i) then
					return true
				end
			end
		end
	end
	return false
end

---

-- remove libs from list of libs depending on exceptions
function filterLibs(libs, exceptions)
	local filter = function(lib, ex)
		for _,e in ipairs(ex) do
			if getLibBasename(lib):match(e) then
				return false
			end
		end
		return true
	end

	local l = {}
	for _,i in table.flatten(libs) do
		if not filter(l, exceptions) then
			table.insert(l, i)
		end
	end
	return l
end

---

-- returns base name of lib, removing .a/.lib, and lib prefix
function getLibBasename(libfile)
	return path.getbasename(libfile):gsub('lib',''):gsub('(md*)$',''):lower()
end

-- creates name for a 'remix' project
function createRemixProjectName(libfile)
	local n = 'remix' .. getLibBasename(libfile)
	return n
end

-- creates name_s_ for 'remix' projects
function createRemixProjectNames(libs)
	if libs == nil then
		return nil
	end
	return table.translate(libs, createRemixProjectName)
end
---

-- creates a remix project
-- ie. lib project created from stub c files
-- which gets overwritten by commands
--
-- libfile: libfile (.a/.lib) to create remix lib from
-- cfgterms: configuration terms matching input libfile, e.g. {"osx", "Debug"}
-- cmds: commands to execute a postbuildstep to overwrite libfile
-- stubs: stub source files to create linkable library
function createRemixProject(libfile, cfgterms, cmds, stubs)
	local finishCmd = function(cmd)
		return cmd .. " " .. pathRelativeToSolutionLocation(libfile)
	end

	project (createRemixProjectName(libfile))
		kind "StaticLib"
		language "C"

		files {
			stubs,
		}

		configuration{}
		configuration{ cfgterms }

		postbuildcommands {
			table.translate(cmds, finishCmd)
		}

		configuration{}
end

-- many libs function for above
-- generates 1 remix per lib in libs
function createRemixProjects(libs, cfgterms, cmds, stubs)
	if libs ~= nil then
		for _, a in ipairs(libs) do
			createRemixProject(a, cfgterms, cmds, stubs)
		end
	end
end

---

function flattendict(arr)
	local result = { }

	local function flatten(arr)
		for k, v in pairs(arr) do
			if type(v) == "table" then
				flatten(v)
			else
				result[k] = v
			end
		end
	end

	flatten(arr)
	return result
end

---

function readFile(filename)
	if filename then
		filename = path.getabsolute(filename)

		--if os.isfile(filename) then
			local f = io.open(filename, 'r')
			if f then
				return f:read('*all')
			else
				--error("failed to open " ..filename)
				return os.outputof('cat ' .. filename)
			end
		--else
		--	error(filename .. " is not a file")
		--end
	end
	return nil
end

---
