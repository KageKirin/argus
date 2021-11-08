-- functions to generate gradle files for a given project/solution

-- @see globals and options in toolchain
-- _OPTIONS["with-android"] as androidPlatform
-- _OPTIONS["with-android-build-tools"] as androidBuildTools
-- _OPTIONS["with-android-sdk"] as androidSdk

if newapifield then
	newapifield {
		name = "gradlecopyresources",
		kind  = "table",
		scope = "project",
	}
end

gradle = {}

-- this mirrors the variables in toolchain() (see toolchain.lua)
-- TODO: refactor and unify
local androidPlatform = "android-21"
if _OPTIONS["with-android"] then
	androidPlatform = "android-" .. _OPTIONS["with-android"]
end
local androidBuildTools = "28.0.3"
if _OPTIONS["with-android-build-tools"] then
	androidBuildTools = _OPTIONS["with-android-build-tools"]
end
local androidSdk = "28.0.0"
if _OPTIONS["with-android-sdk"] then
	androidSdk = _OPTIONS["with-android-sdk"]
end
---

gradle.platform = androidPlatform:match('android%-(%d+)')
gradle.buildTools = androidBuildTools
gradle.sdk = androidSdk

gradle.type = _OPTIONS["with-gradle"]
if not gradle.type or gradle.type ~= 'groovy' then
	gradle.type = 'kotlin'
end

----
-- gradle templates
gradle.kotlin_template = {}
gradle.groovy_template = {}

gradle.kotlin_template["fileext"] = ".gradle.kts"
gradle.groovy_template["fileext"] = ".gradle"

gradle.kotlin_template["root"] = [[
// This file was generated. Any modifications will be lost.
// root build gradle file for {slnName}

allprojects {
    repositories {
        google()
        jcenter()
    }
}

buildscript {
    repositories {
        jcenter()
        google() // For Gradle 4.0+
        mavenCentral()
        maven {
            setUrl("https://maven.google.com") // For Gradle 4.0+
            setUrl("https://dl.bintray.com/kotlin/kotlin-dev/")
            setUrl("https://repo-swet.backend-server.tokyo/maven") //SWET team
        }
    }

    dependencies {
        classpath("com.android.tools.build:gradle:3.4.0") //latest Android build plugin
        classpath("com.google.gms:google-services:4.2.0") //latest
        classpath("com.dena.swet.androidchecker:plugin:1.0.0") //SWET team
        classpath(kotlin("gradle-plugin", version = "1.3.31"))
        //implementation(kotlin("stdlib"))
    }
}
]]
gradle.groovy_template["root"] = [[
// This file was generated. Any modifications will be lost.
// root build gradle file for {slnName}

allprojects {
    repositories {
        google()
        jcenter()
    }
}

buildscript {
    repositories {
        jcenter()
        google() // For Gradle 4.0+
        mavenCentral()
        maven {
            url "https://maven.google.com" // For Gradle 4.0+
            url "https://dl.bintray.com/kotlin/kotlin-dev/"
            url "https://repo-swet.backend-server.tokyo/maven" //SWET team
        }
    }

    dependencies {
        classpath "com.android.tools.build:gradle:3.4.0" //latest Android build plugin
        classpath "com.google.gms:google-services:4.2.0" //latest
        classpath "com.dena.swet.androidchecker:plugin:1.0.0" //SWET team
    }
}
]]

gradle.kotlin_template["settings"] = [[
// This file was generated. Any modifications will be lost.
// settings gradle file for {slnName}
rootProject.buildFileName = "build.gradle.kts"
]]
gradle.groovy_template["settings"] = [[
// This file was generated. Any modifications will be lost.
// settings gradle file for {slnName}
rootProject.buildFileName = "build.gradle"
]]

gradle.kotlin_template["settingsProjectEntry"] = [[

include(":{prjName}")
project(":{prjName}").buildFileName = "{prjName}.gradle.kts"
]]
gradle.groovy_template["settingsProjectEntry"] = [[

include(":{prjName}")
project(":{prjName}").buildFileName = "{prjName}.gradle"
]]



gradle.kotlin_template["project"] = [[
// This file was generated. Any modifications will be lost.
// gradle file for {appName}
// app ID: {appId}
// app version: {appVersion}
// app semantic version: {appSemver}
// NDK: {androidNdkAbi}
// SDK: {androidSdkApi}
// compile SDK version: {compileSdkVersion}
// build tools version: {androidBuildTools}
// minimum SDK version: {minSdkVersion}
// target SDK version: {targetSdkVersion}

plugins {
    id({gradleAndroidPluginId})
    kotlin("android")
    kotlin("android.extensions")
}

android {
    compileSdkVersion({compileSdkVersion})
    buildToolsVersion = "{androidBuildTools}"
    defaultConfig {
        {applicationIdEntry}
        minSdkVersion({minSdkVersion}) //optionally set
        targetSdkVersion({targetSdkVersion})
        versionCode = {appVersion} // optional
        versionName = "{appSemver}" //optional

        {externalNativeBuildCmakeConfig}

        ndk { abiFilters({abiPlatform}) }

        buildConfigField("boolean", "BUILD_WITH_SCAFFOLDING", "true")
        {mainBuildConfigFields}
    }

    compileOptions {
        setSourceCompatibility({javaVersion})
        setTargetCompatibility({javaVersion})
    }

    sourceSets {
        getByName("main") {
            {mainManifestEntry}
            {mainJavaSrcDirsEntry}
            {mainRenderscriptSrcDirsEntry}
            {mainAidlSrcDirsEntry}
            {mainResSrcDirsEntry}
            {mainAssetsSrcDirsEntry}
            {mainResourcesSrcDirsEntry}
            {mainJniLibsSrcDirsEntry}
        }
        getByName("debug") {
            {debugJniLibsSrcDirsEntry}
        }
        getByName("release") {
            {releaseJniLibsSrcDirsEntry}
        }
        create("profile") {
            {profileJniLibsSrcDirsEntry}
        }
    }

    buildTypes {
        getByName("debug") {
            isDebuggable = true
            isZipAlignEnabled = true
            {debugBuildConfigFields}
            packagingOptions{
                doNotStrip("*/armeabi/*.so")
                doNotStrip("*/armeabi-v7a/*.so")
                doNotStrip("*/arm64-v8a/*.so")
                doNotStrip("*/x86/*.so")
                doNotStrip("*/x86/*.so")
            }
        }
        getByName("release") {
            isDebuggable = false
            isMinifyEnabled = true
            isZipAlignEnabled = true
            {releaseBuildConfigFields}
        }
        create("profile") {
            isDebuggable = true
            isZipAlignEnabled = true
            {profileBuildConfigFields}
        }
    }

    {externalNativeBuildCmakeCommand}

    {copyJobEntries}

    dependencies {
        // project .so packed in jar as dependencies
{prjSelfDepsEntries}

        // project dependencies
{prjDepsEntries}

        // jar dependencies
{jarDepsEntries}

        // system dependencies
{sysDepsEntries}

        // optionally further dependencies
        // use sed to replace if needed
        //DEPENDENCIES_PLACEHOLDER
    }
}
]]

gradle.groovy_template["project"] = [[
// This file was generated. Any modifications will be lost.
// gradle file for {appName}
// app ID: {appId}
// app version: {appVersion}
// app semantic version: {appSemver}
// NDK: {androidNdkAbi}
// SDK: {androidSdkApi}
// compile SDK version: {compileSdkVersion}
// build tools version: {androidBuildTools}
// minimum SDK version: {minSdkVersion}
// target SDK version: {targetSdkVersion}

apply plugin: {gradleAndroidPluginId}

android {
    compileSdkVersion {compileSdkVersion}
    buildToolsVersion "{androidBuildTools}"
    defaultConfig {
        {applicationIdEntry}
        minSdkVersion {minSdkVersion} //optionally set
        targetSdkVersion {targetSdkVersion}
        versionCode {appVersion} // optional
        versionName "{appSemver}" //optional

        {externalNativeBuildCmakeConfig}

        ndk { abiFilters({abiPlatform}) }

        buildConfigField "boolean", "BUILD_WITH_SCAFFOLDING", "true"
        {mainBuildConfigFields}
    }

    compileOptions {
        setSourceCompatibility {javaVersion}
        setTargetCompatibility {javaVersion}
    }

    sourceSets {
        "main" {
            {mainManifestEntry}
            {mainJavaSrcDirsEntry}
            {mainRenderscriptSrcDirsEntry}
            {mainAidlSrcDirsEntry}
            {mainResSrcDirsEntry}
            {mainAssetsSrcDirsEntry}
            {mainResourcesSrcDirsEntry}
            {mainJniLibsSrcDirsEntry}
        }
        "debug" {
            {debugJniLibsSrcDirsEntry}
        }
        "release" {
            {releaseJniLibsSrcDirsEntry}
        }
        "profile" {
            {profileJniLibsSrcDirsEntry}
        }
    }

    buildTypes {
        "debug" {
            debuggable true
            zipAlignEnabled true
            {debugBuildConfigFields}

            packagingOptions{
                doNotStrip "*/armeabi/*.so"
                doNotStrip "*/armeabi-v7a/*.so"
                doNotStrip "*/arm64-v8a/*.so"
                doNotStrip "*/x86/*.so"
                doNotStrip "*/x86_64/*.so"
            }
        }
        "release" {
            debuggable false
            minifyEnabled true
            zipAlignEnabled true
            {releaseBuildConfigFields}
        }
        "profile" {
            debuggable true
            zipAlignEnabled true
            {profileBuildConfigFields}
        }
    }

    {externalNativeBuildCmakeCommand}

    {copyJobEntries}

    dependencies {
        // project .so packed in jar as dependencies
{prjSelfDepsEntries}

        // project dependencies
{prjDepsEntries}

        // jar dependencies
{jarDepsEntries}

        // system dependencies
{sysDepsEntries}

        // optionally further dependencies
        // use sed to replace if needed
        //DEPENDENCIES_PLACEHOLDER
    }
}
]]

-- e.g. prjName = lift.cocos2dx
gradle.kotlin_template["dependencyLib"] = [[        implementation(project(":{prjName}"))]]
gradle.groovy_template["dependencyLib"] = [[        implementation project(":{prjName}")]]

-- e.g.  jarDir = path, jarName = whatever.jar
-- NOTE: WE DO NOT SUPPORT exclude: [""]
gradle.kotlin_template["dependencyJar"] = [[        implementation(fileTree(mapOf("dir" to "{jarDir}", "include" to listOf("{jarName}"))))]]
gradle.groovy_template["dependencyJar"] = [[        implementation fileTree("dir": "{jarDir}", "include": ["{jarName}"])]]

-- e.g. com.android.support:support-v4:28.0.0
gradle.kotlin_template["dependencySystem"] = [[        implementation("{dep}")]]
gradle.groovy_template["dependencySystem"] = [[        implementation "{dep}"]]

gradle.kotlin_template["applicationIdEntry"] = [[applicationId = "{appId}"]]
gradle.groovy_template["applicationIdEntry"] = [[applicationId "{appId}"]]

gradle.kotlin_template["manifest.srcFile"] = [[manifest.srcFile({manifest})]]
gradle.groovy_template["manifest.srcFile"] = [[manifest.srcFile {manifest}]]

gradle.kotlin_template["java.srcDirs"] = [[java.srcDirs({javaSrcDirs})]]
gradle.groovy_template["java.srcDirs"] = [[java.srcDirs += [{javaSrcDirs}] ]]

gradle.kotlin_template["renderscript.srcDirs"] = [[renderscript.srcDirs({renderscriptSrcDirs})]]
gradle.groovy_template["renderscript.srcDirs"] = [[renderscript.srcDirs += [{renderscriptSrcDirs}] ]]

gradle.kotlin_template["aidl.srcDirs"] = [[aidl.srcDirs({aidlSrcDirs})]]
gradle.groovy_template["aidl.srcDirs"] = [[aidl.srcDirs += [{aidlSrcDirs}] ]]

gradle.kotlin_template["res.srcDirs"] = [[res.srcDirs({resSrcDirs})]]
gradle.groovy_template["res.srcDirs"] = [[res.srcDirs += [{resSrcDirs}] ]]

gradle.kotlin_template["assets.srcDirs"] = [[assets.srcDirs({assetsSrcDirs})]]
gradle.groovy_template["assets.srcDirs"] = [[assets.srcDirs += [{assetsSrcDirs}] ]]

gradle.kotlin_template["resources.srcDirs"] = [[resources.srcDirs({resourcesSrcDirs})]]
gradle.groovy_template["resources.srcDirs"] = [[resources.srcDirs += [{resourcesSrcDirs}] ]]

gradle.kotlin_template["jniLibs.srcDirs"] = [[jniLibs.srcDirs({jniLibsSrcDirs})]]
gradle.groovy_template["jniLibs.srcDirs"] = [[jniLibs.srcDirs += [{jniLibsSrcDirs}] ]]

gradle.kotlin_template["externalNativeBuildCmakeConfig"] = [[
externalNativeBuild {
	cmake {
		{cmakeArgs}
		{cmakeCFlags}
		{cmakeCppFlags}
	}
}
]]
gradle.groovy_template["externalNativeBuildCmakeConfig"] = gradle.kotlin_template["externalNativeBuildCmakeConfig"]

gradle.kotlin_template["externalNativeBuildCmakeCommand"] = [[
externalNativeBuild {
	cmake {
		setPath(File("{cmakeliststxt}"))
	}
}
]]
gradle.groovy_template["externalNativeBuildCmakeCommand"] = [[
externalNativeBuild {
	cmake {
		path "{cmakeliststxt}"
	}
}
]]


gradle.kotlin_template["assetCopyTaskDef"] = [[
	//TODO: port Groovy implementation to Kotlin

]]
gradle.groovy_template["assetCopyTaskDef"] = [[
	task copyAssets() doLast {
		println "Copying assets into {targetAssetDir}"
		{copyEntries}
	}
]]

gradle.kotlin_template["assetCopyEntry"] = [[
	//TODO.
	//yes, this is still TODO
]]
gradle.groovy_template["assetCopyEntry"] = [[
        copy {
            from {copyOrigin}
            //exclude {copyExcludes}
            into "{targetAssetDir}/{copyTarget}"
        }
]]

----
-- check templates for completion
for k,v in pairs(gradle.kotlin_template) do
	assert(gradle.groovy_template[k], "template '" .. k .. "' does not exist for groovy")
end
for k,v in pairs(gradle.groovy_template) do
	assert(gradle.kotlin_template[k], "template '" .. k .. "' does not exist for kotlin")
end

----

-- creates an appInfo structure to be passed to project
-- @param _name: App name (e.g. MyApp)
-- @param _id: App ID (e.g. com.example.MyApp)
-- @param _version: App version (e.g. 1)
-- @param _semver: App semantic version (e.g. 1.0.0)
function gradle.createAppInfo(_name, _id, _version, _semver)
	local appinfo = {
		name = _name or "MyApp",
		id = _id or "com.example." .. string.lower(appinfo.name),
		version = _version or "1",
		semver = _semver or "1.0.0",
	}
	return appinfo
end


-- creates a buildInfo structure to be passed to project
-- @param _manifest: corresponds to manifest.srcFile
-- @param _javaSrcDirs: corresponds to java.srcDirs
-- @param _renderscriptSrcDirs: corresponds to renderscript.srcDirs
-- @param _aidlSrcDirs: corresponds to aidl.srcDirs
-- @param _resSrcDirs: corresponds to res.srcDirs
-- @param _assetsSrcDirs: corresponds to assets.srcDirs
-- @param _resourcesSrcDirs: corresponds to resources.srcDirs
function gradle.createBuildInfo(_manifest, _javaSrcDirs, _renderscriptSrcDirs, _aidlSrcDirs, _resSrcDirs, _assetsSrcDirs, _resourcesSrcDirs, _jniLibsSrcDirs)
	local buildinfo = {
		manifestSrcFile = _manifest,
		javaSrcDirs = _javaSrcDirs,
		renderscriptSrcDirs = _renderscriptSrcDirs,
		aidlSrcDirs = _aidlSrcDirs,
		resSrcDirs = _resSrcDirs,
		assetsSrcDirs = _assetsSrcDirs,
		resourcesSrcDirs = _resourcesSrcDirs,
		jniLibsSrcDirs = _jniLibsSrcDirs,
	}
	return buildinfo
end


-- creates a dependencyInfo structure to be passed to project
function gradle.createDependencyInfo(_prjDeps, _jarDeps, _sysDeps)
	local depsinfo = {
		projectDeps = _prjDeps,
		libraryDeps = _jarDeps,
		systemDeps  = _sysDeps,
	}
	return depsinfo
end

-- scaffolding function
-- gather jniLib.srcDirs given by dependency packages
-- expects package to implement optional function '_gradle_get_jnilib_srcdirs'
-- expects _gradle_get_jnilib_srcdirs() to return the follow table
-- {["main"] = {main lib dirs},
--  ["debug"] = {debug lib dirs},
--  ["release"] = {release lib dirs},
--  ["profile"] = {profile lib dirs},
-- }
function gradle.gather_jnilib_srcdirs(_depspkgs, _type)
	if not _depspkgs then
		return {}
	end
	jnilibs = {}

	for k,p in pairs(_depspkgs) do
		assert(p, "p is nil")
		if p._gradle_get_jnilib_srcdirs then
			print('adding jniLib.srcDirs from', k)
			local j = p._gradle_get_jnilib_srcdirs()
			if j[_type] then
				printtable('adding ',j[_type])
				table.insert(jnilibs,j[_type])
			end
		end
	end
	printtable('gathered jnilibs', jnilibs)
	return table.flatten(jnilibs)
end

-----
-- helper functions
-- unwrap args to a string usable by gradle
-- if _args are paths and _location is provided: rebase path to be relative to location
function gradle.makeArgumentList(_args, _location)
	if _args == nil then
		return ''
	end

	if type(_args) == 'table' then
		_args = table.flatten(_args)
		if #_args == 0 then
			return ''
		end

		return table.concat(
			table.translate(_args,
				(function(_d)
					return gradle.makeArgumentList(_d, _location)
				end)
			),
			', ')
	end

	if _location then
		return string.format('"%s"', path.getrelative(_location, _args))
	end
	return string.format('"%s"', _args)
end


function gradle.createDirsEntry(_template, _subs, _dirs, _location)
	assert(_template, "template is nil")

	_dirs = gradle.makeArgumentList(_dirs, _location)
	if _dirs == nil then
		return ''
	end

	return _template:gsub(_subs, _dirs)
end



function gradle.createDepsEntries(_template, _subs, _deps)
	assert(_template, "template is nil")

	if not _deps or #_deps == 0 then
		return ''
	end

	local text = table.concat(
		table.translate(_deps, function(d)
			return _template:gsub(_subs, d)
		end),
		"\n")

	return text
end


function gradle.createDepJarsEntries(_template, _deps, _location)
	assert(_template, "template is nil")

	if not _deps or #_deps == 0 then
		return ''
	end

	local text = table.concat(
		table.translate(_deps, function(d)
			d = path.getrelative(_location, d)
			local p = path.getdirectory(d)
			local j = path.getname(d)
			return _template:gsub('{jarDir}', p):gsub('{jarName}', j)
		end),
		"\n")

	return text
end


function gradle.writeFile(filepath, content)
	if content == nil then
		return nil
	end
	local f = io.open(filepath, "w")
	assert(f, "failed to open " .. filepath)
	if not f then
		return nil
	end

	local r = f:write(content)
	f:close()
	return r
end


function gradle.getHardwareAbi(configstring)
	local hw = configstring:match('android%-(.+)')
	print(hw)
	if hw == "arm" then
		return "armeabi-v7a"
	elseif hw == "aarch64" then
		return "arm64-v8a"
	end
	return hw
end
-----

local function get_current_field(blocks, field, terms)
	assert(blocks, 'provided blocks are nil')
	assert(#blocks>0, 'provided blocks are empty')
	assert(field, 'provided field is nil')
	local value = blocks[1][field]
	local aterms = terms or premake.getactiveterms()
	--printtable('aterms', aterms)
	for _,b in ipairs(blocks) do
		if premake.iskeywordsmatch(b.keywords, aterms) then
			if b[field] ~= nil then
				value = b[field]
			end
		end
	end
	return value
end
-----
local re_templateParam = "[^%$]%{([%w_]+)%}"

local function gatherTemplateParams(_template)
	local params = {}
	for p in _template:gmatch(re_templateParam) do
		params[p] = '' -- for debug: '// ' .. p
	end
	return params
end
-----
local function instantiateTemplate(_template, _params)
	local s = _template
	for p in s:gmatch(re_templateParam) do
		for k,v in pairs(_params) do
			s = s:gsub('{' .. k ..'}', v)
		end
	end
	return s
end
-----
function gradle.getTemplate(_templatename)
	if gradle.type == 'groovy' then
		return gradle.groovy_template[_templatename]
	end
	return gradle.kotlin_template[_templatename]
end
-----
function gradle.lint(filename)
	if gradle.type == 'kotlin' then
		os.execute('ktlint -F ' .. filename)
	elseif gradle.type == 'groovy' then
		os.execute('groovy-format ' .. filename)
	end
end
-----

-- generates a gradle file for the given project
-- @param _appinfo: table returned by createAppInfo()
-- @param _buildinfo: table returned by createBuildInfo()
-- @param _template: optional template string for generating build.gradle
--					 uses default if nil
--					 default depends on prj.kind

function gradle.project(prj, _appinfo, _buildinfo, _depsinfo, _depspkgs, _template, _templateparams, _location)
	assert(prj, "prj is nil")
	--printtable('project ' .. prj.name, prj)
	_appinfo = _appinfo or gradle.createAppInfo(prj.name)
	_buildinfo = _buildinfo or gradle.createBuildInfo()
	_depsinfo = _depsinfo or gradle.createDependencyInfo()

	local sln = prj.solution
	local cfg = configuration()

	-- skip gradle generation
	if not premake.iskeywordsmatch(cfg.keywords, premake.getactiveterms()) then
		return
	end

	local prj_kind = get_current_field(prj.blocks, 'kind')
	assert(prj_kind, "kind is nil")
	local prj_targetdir = get_current_field(prj.blocks, 'targetdir')
	if not prj_targetdir then
		prj_targetdir = get_current_field(sln.blocks, 'targetdir') or "$(TARGETDIR)"
	end
	assert(prj_targetdir, "prj_targetdir is nil")
	print('setting up gradle for', prj_kind, prj_targetdir)

	local prj_location = _location or prj.location
	if not prj_location then
		assert(sln, "project solution is nil")
		assert(sln.location, "solution location is nil")
		prj_location = sln.location
	end

	local grd_location = path.join(prj_location, prj.name)
	local manifestSrcFile = path.join(grd_location, path.getname(_buildinfo.manifestSrcFile))
	local gradleBuildFile = path.join(grd_location, prj.name .. gradle.getTemplate("fileext"))

	local template = _template or gradle.getTemplate("project")
	assert(template, "template is nil")
	local params = gatherTemplateParams(template)
	assert(params, "params are nil")
	--printtable('params', params)

	params.gradleAndroidPluginId = [["com.android.library"]]
	if prj_kind:endswith("App") then
		params.gradleAndroidPluginId = [["com.android.application"]]
		params.applicationIdEntry = gradle.getTemplate("applicationIdEntry")
	end

	params.abiPlatform = gradle.makeArgumentList(gradle.getHardwareAbi(_OPTIONS["gcc"]))
	print('abiPlatform', params.abiPlatform)

	params.javaVersion = "JavaVersion.VERSION_1_7" --"1.7" -- @see notes at bottom

	-- Android settings
	params.androidNdkAbi = gradle.platform
	params.androidSdkApi = gradle.sdk
	params.androidBuildTools = gradle.buildTools
	params.compileSdkVersion = '28'
	params.minSdkVersion = '21'
	params.targetSdkVersion = '28'

	-- app settings
	params.appName = _appinfo.name
	params.appId = _appinfo.id
	params.appVersion = _appinfo.version
	params.appSemver = _appinfo.semver

	_buildinfo.assetsSrcDirs = table.flatten({_buildinfo.assetsSrcDirs or {}, path.join(prj_targetdir, prj.name, 'assets')})

	params.mainManifestEntry = gradle.createDirsEntry(gradle.getTemplate("manifest.srcFile"), "{manifest}", manifestSrcFile, grd_location)
	params.mainJavaSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("java.srcDirs"), "{javaSrcDirs}", _buildinfo.javaSrcDirs, grd_location)
	params.mainRenderscriptSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("renderscript.srcDirs"), "{renderscriptSrcDirs}", _buildinfo.renderscriptSrcDirs, grd_location)
	params.mainAidlSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("aidl.srcDirs"), "{aidlSrcDirs}", _buildinfo.aidlSrcDirs, grd_location)
	params.mainResSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("res.srcDirs"), "{resSrcDirs}", _buildinfo.resSrcDirs, grd_location)
	params.mainAssetsSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("assets.srcDirs"), "{assetsSrcDirs}", _buildinfo.assetsSrcDirs, grd_location)
	params.mainResourcesSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("resources.srcDirs"), "{resourcesSrcDirs}", _buildinfo.resourcesSrcDirs, grd_location)

	--- jniLib srcDirs need to be gathered
	local main_jnilibs = table.flatten({_buildinfo.jniLibsSrcDirs or {}, gradle.gather_jnilib_srcdirs(_depspkgs, 'main')})
	printtable('main_jnilibs', main_jnilibs)
	local debug_jnilibs = table.flatten({path.join(prj_targetdir, prj.name, "debug"), gradle.gather_jnilib_srcdirs(_depspkgs, 'debug')})
	printtable('debug_jnilibs', debug_jnilibs)
	local release_jnilibs = table.flatten({path.join(prj_targetdir, prj.name, "release"), gradle.gather_jnilib_srcdirs(_depspkgs, 'release')})
	printtable('release_jnilibs', release_jnilibs)
	local profile_jnilibs = table.flatten({path.join(prj_targetdir, prj.name, "profile"), gradle.gather_jnilib_srcdirs(_depspkgs, 'profile')})
	printtable('profile_jnilibs', profile_jnilibs)

	params.mainJniLibsSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("jniLibs.srcDirs"), "{jniLibsSrcDirs}", main_jnilibs, grd_location)
	params.debugJniLibsSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("jniLibs.srcDirs"), "{jniLibsSrcDirs}", debug_jnilibs, grd_location)
	params.releaseJniLibsSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("jniLibs.srcDirs"), "{jniLibsSrcDirs}", release_jnilibs, grd_location)
	params.profileJniLibsSrcDirsEntry = gradle.createDirsEntry(gradle.getTemplate("jniLibs.srcDirs"), "{jniLibsSrcDirs}", profile_jnilibs, grd_location)

	--
	params.prjDepsEntries = gradle.createDepsEntries(gradle.getTemplate("dependencyLib"), '{prjName}', _depsinfo.projectDeps, grd_location)
	params.sysDepsEntries = gradle.createDepsEntries(gradle.getTemplate("dependencySystem"), '{dep}', _depsinfo.systemDeps, grd_location)
	params.jarDepsEntries = gradle.createDepJarsEntries(gradle.getTemplate("dependencyJar"), _depsinfo.libraryDeps, grd_location)

	if prj_kind:endswith("App") and _ACTION == 'cmake' then
		params.externalNativeBuildCmakeConfig = gradle.getTemplate("externalNativeBuildCmakeConfig")
			:gsub("{cmakeArgs}", "")
			:gsub("{cmakeCFlags}", "")
			:gsub("{cmakeCppFlags}", "")
		-- arguments +=
		-- cFlags +=
		-- cppFlags +=

		local cmakelist = "./CMakeLists.txt"
		params.externalNativeBuildCmakeCommand = gradle.getTemplate("externalNativeBuildCmakeCommand")
			:gsub("{cmakeliststxt}", cmakelist)
	end


	if gradlecopyresources then
		printtable('prj.gradlecopyresources', prj.gradlecopyresources)
		if not prj.gradlecopyresources then
			--printtable('prj', prj)
		end
	end

	params.targetAssetDir = path.join(prj_targetdir, prj.name, 'assets')

	--printtable('params', params)
	if _templateparams then
		params = table.merge(params, _templateparams)
	end
	--printtable('params (merged)', params)
	local buildfile = instantiateTemplate(template, params)
	--print(buildfile)

	for k,v in pairs(params) do
		buildfile = buildfile .. string.format("// with {%s} = %s\n", k, v:gsub('\n','\t'))
	end

	if not os.isdir(grd_location) then
		os.mkdir(grd_location)
	end
	gradle.writeFile(gradleBuildFile, buildfile)
	gradle.lint(gradleBuildFile)


	os.copyfile(_buildinfo.manifestSrcFile, manifestSrcFile)

	prebuildcommands {
		string.format('rclone copyto %s %s', _buildinfo.manifestSrcFile, manifestSrcFile),
	}

	-- copy result .so to correct path for jniLib inclusion
	print('prj_kind:', prj_kind)

		for _, sln_cfg in ipairs(sln.configurations) do
		configuration { cfg.terms, sln_cfg, "not StaticLib" }

			local prj_targetprefix = get_current_field(prj.blocks, 'targetprefix')
			if not prj_targetprefix then
				prj_targetprefix = get_current_field(sln.blocks, 'targetprefix')
			end

			local prj_targetsuffix = get_current_field(prj.blocks, 'targetsuffix', {string.lower(sln_cfg)})
			if not prj_targetsuffix then
				prj_targetsuffix = get_current_field(sln.blocks, 'targetsuffix', {string.lower(sln_cfg)})
			end

			local prj_targetextension = get_current_field(prj.blocks, 'targetextension')
			if not prj_targetextension then
				prj_targetextension = get_current_field(sln.blocks, 'targetextension')
			end
			prj_targetextension = prj_targetextension or ".so"

			local prj_targetname = get_current_field(prj.blocks, 'targetname') or prj.name

			local bld_target = path.getrelative(prj_location,
				path.join(prj_targetdir, string.format("%s%s%s%s", prj_targetprefix, prj_targetname, prj_targetsuffix, prj_targetextension)))

			local abiPlatform = params.abiPlatform
			abiPlatform = abiPlatform:gsub([["]],'')
			local jni_targetdir = path.getrelative(prj_location,
				path.join(prj_targetdir, prj.name, string.lower(sln_cfg), abiPlatform))
			local jni_target = path.join(jni_targetdir, string.format("%s%s%s%s", prj_targetprefix, prj_targetname, prj_targetsuffix, ".so"))

			print('jni_targetdir', jni_targetdir)
			print('jni_target', jni_target)
			postbuildcommands {
				string.format("$(call RM,%s)", jni_target);
				string.format("rclone copyto %s %s", bld_target, jni_target),
				string.format("diff %s %s", bld_target, jni_target),
			}

		configuration { cfg.terms, sln_cfg, "not StaticLib", "gmake" }
			postbuildcommands {
				"printelf $(TARGET)",
			}

		configuration { cfg.terms, sln_cfg, "not StaticLib", "ninja" }
			postbuildcommands {
				"printelf $out",
			}

		configuration { cfg.terms }
	end


	-- add gradle build as postbuild command
		for _, sln_cfg in ipairs(sln.configurations) do
		configuration { cfg.terms, 'gmake', sln_cfg, "*App" }
				postbuildcommands {
					"sleep 10",
					string.format("gradle clean"),
					string.format("gradle  --rerun-tasks -i :%s:assemble%s", prj.name, sln_cfg),
				}
		configuration { cfg.terms, 'ninja', sln_cfg, "*App" }
				postbuildcommands {
					"sleep 10",
					string.format("gradle -p .. clean"),
					string.format("gradle  --rerun-tasks -i -p .. :%s:assemble%s", prj.name, sln_cfg),
				}
		configuration { cfg.terms }
	end
end


-- generates the main gradle files for the solution
-- build.gradle setting gradle version and tools
-- settings.gradle referencing given projects (by directory)
-- NOTE: referenced projects MUST fit projects
-- @param sln: returned by solution()
-- @param projects: array of project names []
function gradle.solution(sln, projects)
	assert(sln, "solution is nil")

	if not os.isdir(sln.location) then
		os.mkdir(sln.location)
	end

	local buildfile = gradle.getTemplate("root")
		:gsub("{slnName}", sln.name)
	gradle.writeFile(path.join(sln.location, "build" .. gradle.getTemplate("fileext")), buildfile)


	local settingsfile = gradle.getTemplate("settings")
		:gsub("{slnName}", sln.name)

	for _, p in ipairs(projects) do
		settingsfile = settingsfile ..
		gradle.getTemplate("settingsProjectEntry")
			:gsub('{prjName}', p)
			:gsub('{prjDir}', p)
	end
	gradle.writeFile(path.join(sln.location, "settings" .. gradle.getTemplate("fileext")), settingsfile)

	gradle.lint(path.join(sln.location, "build" .. gradle.getTemplate("fileext")))
	gradle.lint(path.join(sln.location, "settings" .. gradle.getTemplate("fileext")))
end

------------------------------------------------
-- NOTES ---------------------------------------
local __notes =
[[
	- Java version:
		As of Android-28, Android does not support Java 1.8+
		Setting version 1.8+ will 'result  type 3, Error { Error type 3...} does not exist.'

]]
