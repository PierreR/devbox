include docs/Makefile

.PHONY: clean user system

config_file ?= /vagrant/config/box.dhall

user:
	@echo -e "Starting user configuration from ${PWD}.\nHold on.\n"
	@time -f "Completed after %E min" ./user/setenv.sh $(config_file)

system:
	@echo -e "Starting system configuration from ${PWD}.\nHold on.\n"
	./system/setenv.sh $(config_file)

sync-system:
	@echo -e "Synchronize local system configuration from ${PWD}.\nHold on.\n"
	./system/setenv.sh $(config_file) sync

clean: clean-doc
	rm -f build/*.*
