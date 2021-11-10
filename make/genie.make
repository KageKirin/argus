./bin/darwin:
	mkdir -p $@

./bin/windows:
	mkdir -p $@

./bin/linux:
	mkdir -p $@

update-genie-os: update-genie-$(TARGET_OS)

update-genie-darwin: ./bin/darwin
	curl -L -o ./bin/darwin/genie https://github.com/bkaradzic/bx/raw/master/tools/bin/darwin/genie
	chmod +x ./bin/darwin/genie

update-genie-windows: ./bin/windows
	curl -L -o ./bin/windows/genie.exe https://github.com/bkaradzic/bx/raw/master/tools/bin/windows/genie.exe
	chmod +x ./bin/windows/genie.exe

update-genie-linux: ./bin/linux
	curl -L -o ./bin/linux/genie https://github.com/bkaradzic/bx/raw/master/tools/bin/linux/genie
	chmod +x ./bin/linux/genie

update-genie: update-genie-darwin update-genie-linux update-genie-windows
	@echo Updated genie binaries
