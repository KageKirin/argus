--
-- Script to format code
--

local script_path = path.getdirectory(_SCRIPT)
local source_path = path.join(script_path, "..", "src")

function doformat()
	local srcfiles = table.flatten {
		os.matchfiles(path.join(script_path, "..", "Decoder", "**.h")),
		os.matchfiles(path.join(script_path, "..", "Decoder", "**.c")),
		os.matchfiles(path.join(script_path, "..", "Decoder", "**.m")),
		os.matchfiles(path.join(script_path, "..", "Decoder", "**.cpp")),
		os.matchfiles(path.join(script_path, "..", "Decoder", "**.mm")),
	}
	local cmd = "clang-format -i " .. table.concat(srcfiles, " ")
	print(cmd)
	io.flush()
	os.execute(cmd)
end
