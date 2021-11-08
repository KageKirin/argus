--
-- Script to generate code from template etc
-- This script generates both the header/source files.
--

local script_path = path.getdirectory(_SCRIPT)
local source_path = path.join(script_path, "..", "Decoder", "src")

function generate_gitrev()
	local gitrev = os.outputof('git rev-parse HEAD'):gsub("%s", "")
	printf(gitrev)
	local f = io.open(path.join(source_path, 'gitrev.c'), 'w')
	f:write('const char* git_revision = "' .. gitrev .. '";\n')
	f:write('// last update: ' .. os.date("%x %X") .. '\n')
	f:close()
end

function dogenerate()
	generate_gitrev()
end
