include docs/Makefile

.PHONY: clean user system

overlays := ${PWD}/nixpkgs/overlays
version ?= '4.2.8'

user:
	@echo -e "Starting user configuration (version: $(version)).\nHold on. It will take several minutes."
	@nix-shell -Q --quiet -A user https://github.com/CIRB/devbox/tarball/$(version) --run '/usr/bin/env time -f "Completed after %E min" setenv' | tee /vagrant/user_lastrun.log

# deprecated: left for a while for Vagrantfile compatibility sake
sync-user: user

system:
	@./system/setenv.sh

clean: clean-doc
	rm -f build/*.*
	rm result
