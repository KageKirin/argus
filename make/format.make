## formatting makerules

ALL_SOURCE_FILES = \
	$(shell fd ".*\.h"   -- src)       \
	$(shell fd ".*\.c"   -- src)       \
	$(shell fd ".*\.h"   -- tests)     \
	$(shell fd ".*\.c"   -- tests)     \
	$(shell fd ".*\.h"   -- examples)  \
	$(shell fd ".*\.c"   -- examples)

ALL_TRACKED_FILES = \
	$(shell git ls-files -- src | rg ".*\.h")         \
	$(shell git ls-files -- src | rg ".*\.c")         \
	$(shell git ls-files -- tests | rg ".*\.h")       \
	$(shell git ls-files -- tests | rg ".*\.c")       \
	$(shell git ls-files -- examples | rg ".*\.h")    \
	$(shell git ls-files -- examples | rg ".*\.c")

ALL_MODIFIED_FILES = \
	$(shell git ls-files -m -- src)        \
	$(shell git ls-files -m -- tests)      \
	$(shell git ls-files -m -- examples")


format-all: $(ALL_SOURCE_FILES)
	clang-format -i $^

format: $(ALL_TRACKED_FILES)
	clang-format -i $^
	#$(GENIE) format

q qformat: $(ALL_MODIFIED_FILES)
	clang-format -i $^
