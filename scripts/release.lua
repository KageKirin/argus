function dorelease()
	--
	-- Helper function: runs a command (formatted, with optional arguments) and
	-- suppresses any output. Works on both Windows and POSIX. Might be a good
	-- candidate for a core function.
	--
	local function exec(cmd, ...)
		cmd = string.format(cmd, ...)
		local z = os.execute(cmd .. " > output.log 2> error.log")
		os.remove("output.log")
		os.remove("error.log")
		return z
	end


	print("Updating version number...")

	local f = io.popen("git rev-list --count HEAD")
	local rev = string.match(f:read("*a"), ".*%S")
	f:close()
	f = io.popen("git log --format=format:%H -1")
	local sha1 = f:read("*a")
	f:close()
	io.output("Decoder/version.h")
	io.write("#define BROADWAY_VERSION " ..rev .. "\n")
	io.write("#define BROADWAY_VERSION_STR \"version " ..rev .. " (commit " .. sha1 .. ")\"\n")
	io.close()
	print( "Finished.")
	print("")
	print( "Now run `make release`")

end
