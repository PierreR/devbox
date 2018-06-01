include docs/Makefile

.PHONY: clean user system

overlays := ${PWD}/nixpkgs/overlays

user:
	@echo -e "Starting user configuration.\nHold on. It will take several minutes."
	@nix-shell --quiet -Q -A user release.nix --run 'runghc user/setenv.hs' -I nixpkgs-overlays=$(overlays) | tee /vagrant/user_lastrun.log

system:
	@./system/setenv.sh

clean: clean-doc
	rm -f build/*.*
	rm -f bootrelease
	rm -rf nixpkgs
