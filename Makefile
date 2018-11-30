include docs/Makefile

.PHONY: clean user system

user:
	@echo -e "Starting user configuration.\nHold on. It will take several minutes.\n"
	@nix-shell -p dhall-bash --quiet --run '/usr/bin/env time -f "Completed after %E min" ./user/setenv.sh /vagrant/config/box.dhall' | tee /vagrant/user_lastrun.log

system:
	@./system/setenv.sh

clean: clean-doc
	rm -f build/*.*
