include docs/Makefile

.PHONY: clean user system

overlays := ${PWD}/nixpkgs/overlays

user:
	@echo -e "Starting user configuration.\nHold on. It will take several minutes."
	@nix-shell -Q -A user https://github.com/CIRB/devbox/tarball/master --run '/usr/bin/env time -f "Completed after %e sec" setenv' -I nixpkgs-overlays=$(overlays) | tee /vagrant/user_lastrun.log

sync-user:
	@nix-shell -Q -A user https://github.com/CIRB/devbox/tarball/master --run '/usr/bin/env time -f "Completed after %e sec" setenv --sync' -I nixpkgs-overlays=$(overlays)

system:
	@./system/setenv.sh

clean: clean-doc
	rm -f build/*.*
	rm -f bootrelease
	rm -rf nixpkgs
