include docs/Makefile

.PHONY: clean user system

config_file ?= /vagrant/config/box.dhall

user:
	@echo -e "Starting user configuration in ${PWD}.\nHold on.\n"
	@time -f "Completed after %E min" ./user/setenv.sh $(config_file) | tee /vagrant/user_lastrun.log

system:
	@echo -e "Starting system configuration in ${PWD}.\nHold on.\n"
	./system/setenv.sh $(config_file)

sync-system:
	@echo -e "Synchronize local system configuration from ${PWD}.\nHold on.\n"
	./system/setenv.sh $(config_file) sync

clean: clean-doc
	rm -f build/*.*
