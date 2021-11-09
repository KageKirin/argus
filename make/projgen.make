#
# Copyright 2020~ Christian Helmich. All rights reserved.
# License: http://www.opensource.org/licenses/BSD-2-Clause
#

UNAME := $(shell uname)
ifeq ($(UNAME),$(filter $(UNAME),Linux Darwin SunOS FreeBSD GNU/kFreeBSD NetBSD OpenBSD GNU))
ifeq ($(UNAME),$(filter $(UNAME),Darwin))
HOST_OS=darwin
TARGET_OS?=darwin
else
ifeq ($(UNAME),$(filter $(UNAME),SunOS))
HOST_OS=solaris
TARGET_OS?=solaris
else
ifeq ($(UNAME),$(filter $(UNAME),FreeBSD GNU/kFreeBSD NetBSD OpenBSD))
HOST_OS=bsd
TARGET_OS?=bsd
else
HOST_OS=linux
TARGET_OS?=linux
endif
endif
endif
else
EXE=.exe
HOST_OS=windows
TARGET_OS?=windows
endif

CP=rclone copy -P

.PHONY: release

## just provide genie on the command line
GENIE?=bin/$(HOST_OS)/genie$(EXE)


## main target
BROADWAY=bin/$(TARGET_OS)/broadway$(EXE)

SILENT?=@

GENIE_OPTIONS?=

PROJECT_TYPE?=ninja

CONFIG?=debug


## default rules

$(BROADWAY).$(PROJECT_TYPE): build/$(PROJECT_TYPE).$(TARGET_OS)
	$(SILENT) $(MAKE) -C build/$(PROJECT_TYPE).$(TARGET_OS) GENIE_OPTIONS=$(GENIE_OPTIONS) config=$(CONFIG)

all: clean projgen $(BROADWAY).$(PROJECT_TYPE)


## clean up rules

clean:
	$(SILENT) $(MAKE) -C build/$(PROJECT_TYPE).$(TARGET_OS) config=$(CONFIG) clean

clean-projects:
	$(SILENT) rm -rf build/$(PROJECT_TYPE).$(TARGET_OS)

clean-all-projects:
	$(SILENT) rm -rf build/$(PROJECT_TYPE).*
	$(SILENT) rm -rf build/xcode.*
	$(SILENT) rm -rf build/vs.*

clean-artifacts:
	$(SILENT) rm -rf build/bin/$(TARGET_OS)
	$(SILENT) rm -rf build/obj/$(TARGET_OS)

clean-all-artifacts:
	$(SILENT) rm -rf build/bin/
	$(SILENT) rm -rf build/obj/


## project generation rules

p projgen: clean-all-projects projgen-$(TARGET_OS)
	@echo re-generated projects

projgen-os: projgen-$(TARGET_OS)

projgen-xcode build/xcode.darwin:
	$(SILENT) $(GENIE) --to=../build/xcode.darwin            --toolchain=macosx  --os=macosx   --cc=clang --platform=universal   $(GENIE_OPTIONS) xcode10

projgen-vs build/vs.windows:
	$(SILENT) $(GENIE) --to=../build/vs.windows              --toolchain=windows --os=windows             --platform=x64         $(GENIE_OPTIONS) vs2019

projgen-win projgen-win64 projgen-windows build/$(PROJECT_TYPE).windows:
	$(SILENT) $(GENIE) --to=../build/$(PROJECT_TYPE).windows --toolchain=windows --os=windows  --cc=clang --platform=x64         $(GENIE_OPTIONS) $(PROJECT_TYPE)

projgen-linux build/$(PROJECT_TYPE).linux:
	$(SILENT) $(GENIE) --to=../build/$(PROJECT_TYPE).linux   --toolchain=linux   --os=linux    --cc=clang                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

projgen-asmjs build/$(PROJECT_TYPE).asmjs:
	$(SILENT) $(GENIE) --to=../build/$(PROJECT_TYPE).asmjs   --toolchain=asmjs   --os=linux    --cc=clang                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

projgen-wasm build/$(PROJECT_TYPE).wasm:
	$(SILENT) $(GENIE) --to=../build/$(PROJECT_TYPE).wasm    --toolchain=wasm    --os=linux    --cc=clang                        $(GENIE_OPTIONS) $(PROJECT_TYPE)

projgen-macosx projgen-macos projgen-osx projgen-darwin build/$(PROJECT_TYPE).darwin:
	$(SILENT) $(GENIE) --to=../build/$(PROJECT_TYPE).darwin  --toolchain=macosx  --os=macosx   --cc=clang  --platform=universal  $(GENIE_OPTIONS) $(PROJECT_TYPE)


## print genie
genie-help:
	$(SILENT) $(GENIE) $(GENIE_OPTIONS) --help

## release build rules

release-$(HOST_OS):
	$(SILENT) $(MAKE) -B rebuild CONFIG=release

release: release-$(TARGET_OS)


## build rules

build-$(TARGET_OS): loadpackages embed projgen-$(TARGET_OS) $(BROADWAY).$(PROJECT_TYPE)

b build: build-$(TARGET_OS)

rebuild: clean clean-artifacts build


## generation callbacks

embed:
	$(GENIE) embed

generate:
	$(GENIE) generate

refresh:
	$(GENIE) refresh

loadpackages:
	$(GENIE) loadpackages
