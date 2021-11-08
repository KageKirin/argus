--- language-specific compiler settings

--- C++ options

-- C++03 settings
local cpp03_buildoptions = {
	flags = {
		"Cpp03",
	},
	clang = {
		"-std=gnu++03",
	},
	gcc = {
		"-std=gnu++03",
	},
	vs = {
		"/std:c++03"
	}
}

local cpp03_linkoptions = {
	clang = {
		"-stdlib=libc++",
	},
	gcc = {
		"-stdlib=libc++",
	},
	vs = {

	}
}

-- C++11 settings
local cpp11_buildoptions = {
	flags = {
		"Cpp11",
	},
	clang = {
		"-std=gnu++11",
	},
	gcc = {
		"-std=gnu++11",
	},
	vs = {
		"/std:c++11"
	}
}

local cpp11_linkoptions = {
	clang = {
		"-stdlib=libc++",
	},
	gcc = {
		"-stdlib=libc++",
	},
	vs = {

	}
}

-- C++14 settings
local cpp14_buildoptions = {
	flags = {
		"Cpp14",
	},
	clang = {
		"-std=gnu++14",
	},
	gcc = {
		"-std=gnu++14",
	},
	vs = {
		"/std:c++14"
	}
}

local cpp14_linkoptions = {
	clang = {
		"-stdlib=libc++",
	},
	gcc = {
		"-stdlib=libc++",
	},
	vs = {

	}
}

-- C++17 settings
local cpp17_buildoptions = {
	flags = {
		"Cpp17",
	},
	clang = {
		"-std=gnu++17",
	},
	gcc = {
		"-std=gnu++17",
	},
	vs = {
		"/std:c++17"
	}
}

local cpp17_linkoptions = {
	clang = {
		"-stdlib=libc++",
	},
	gcc = {
		"-stdlib=libc++",
	},
	vs = {

	}
}

-- C++2a settings
local cpp2a_buildoptions = {
	flags = {
		"Cpp2a",
	},
	clang = {
		"-std=gnu++2a",
	},
	gcc = {
		"-std=gnu++2a",
	},
	vs = {
		"/std:c++2a"
	}
}

local cpp2a_linkoptions = {
	clang = {
		"-stdlib=libc++",
	},
	gcc = {
		"-stdlib=libc++",
	},
	vs = {

	}
}

--- C options (K&R C language)

-- C89 settings
local c89_buildoptions = {
	clang = {
		"-std=gnu89",
	},
	gcc = {
		"-std=gnu89",
	},
	vs = {

	}
}

local c89_linkoptions = {
	clang = {},
	gcc = {},
	vs = {},
}

-- C99 settings
local c99_buildoptions = {
	clang = {
		"-std=gnu99",
	},
	gcc = {
		"-std=gnu99",
	},
	vs = {

	}
}

local c99_linkoptions = {
	clang = {},
	gcc = {},
	vs = {},
}

-- C11 settings
local c11_buildoptions = {
	clang = {
		"-std=gnu11",
	},
	gcc = {
		"-std=gnu11",
	},
	vs = {

	}
}

local c11_linkoptions = {
	clang = {},
	gcc = {},
	vs = {},
}

-- C17 settings
local c17_buildoptions = {
	clang = {
		"-std=gnu17",
	},
	gcc = {
		"-std=gnu17",
	},
	vs = {

	}
}

local c17_linkoptions = {
	clang = {},
	gcc = {},
	vs = {},
}

---

local force_buildoptions = function(_project, _buildoptions, _linkoptions)
	if not _project then
		local prj = project()
		assert(prj)
		_project= prj.name
	end
	project (_project)

	configuration {}
		flags { _buildoptions.flags }

	configuration { "*gcc*" }
		buildoptions { _buildoptions.gcc, }
		linkoptions { _linkoptions.gcc, }

	configuration { "*clang*" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "asmjs" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "wasm*" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "emscripten" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "darwin" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "osx" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "macosx" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "ios*" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "orbis" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "qnx-arm" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "rpi" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "riscv" }
		buildoptions { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "vs*" }
		buildoptions_cpp { _buildoptions.vs, }
		linkoptions { _linkoptions.vs, }

	configuration {}
end

---

force_cppbuildoptions = function(_project, _buildoptions, _linkoptions)
	if not _project then
		local prj = project()
		assert(prj)
		_project= prj.name
	end
	project (_project)

	configuration {}
		flags { _buildoptions.flags }

	configuration { "*gcc*" }
		buildoptions_cpp { _buildoptions.gcc, }
		linkoptions { _linkoptions.gcc, }

	configuration { "*clang*" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "asmjs" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "wasm" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "wasm2js" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "emscripten" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "darwin" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "osx" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "macosx" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "ios*" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "orbis" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "qnx-arm" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "rpi" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "riscv" }
		buildoptions_cpp { _buildoptions.clang, }
		linkoptions { _linkoptions.clang, }

	configuration { "vs*" }
		buildoptions_cpp { _buildoptions.vs, }
		linkoptions { _linkoptions.vs, }

	configuration {}
end

---

build_cpp03 = function(_project)
	force_cppbuildoptions(_project, cpp03_buildoptions, cpp03_linkoptions)
end

---

build_cpp11 = function(_project)
	force_cppbuildoptions(_project, cpp11_buildoptions, cpp11_linkoptions)
end

---

build_cpp14 = function(_project)
	force_cppbuildoptions(_project, cpp14_buildoptions, cpp14_linkoptions)
end

---

build_cpp17 = function(_project)
	force_cppbuildoptions(_project, cpp17_buildoptions, cpp17_linkoptions)
end

---

build_cpp2a = function(_project)
	force_cppbuildoptions(_project, cpp2a_buildoptions, cpp2a_linkoptions)
end

---

build_cppfwd = function(_project)
	force_cppbuildoptions(_project, cpp17_buildoptions, cpp17_linkoptions)
end

---


---

build_c89 = function(_project)
	force_buildoptions(_project, c89_buildoptions, c89_linkoptions)
end

---

build_c99 = function(_project)
	force_buildoptions(_project, c99_buildoptions, c99_linkoptions)
end

---

build_c11 = function(_project)
	force_buildoptions(_project, c11_buildoptions, c11_linkoptions)
end

---

build_c17 = function(_project)
	force_buildoptions(_project, c17_buildoptions, c17_linkoptions)
end

---

build_cfwd = function(_project)
	force_buildoptions(_project, c17_buildoptions, c17_linkoptions)
end

---

