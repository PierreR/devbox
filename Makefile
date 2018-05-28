include docs/Makefile

.PHONY: clean user system cicd-shell

overlays := ${PWD}/nixpkgs/overlays

.$(overlays):
	echo "Pulling overlays submodule"
	git submodule update --init

bootrelease: ${PWD}/nixpkgs
	@echo -e "Downloading all required packages.\nHold on. It will take several minutes."
	@nix-shell -A trigger release.nix --run "touch bootrelease" -I nixpkgs-overlays=$(overlays) > /vagrant/user_boot.log 2>&1

user: bootrelease
	@nix-shell -A user release.nix --run 'runghc user/setenv.hs' -I nixpkgs-overlays=$(overlays) | tee /vagrant/user_lastrun.log

sync-user:
	nix-shell -A user release.nix --run 'runghc user/setenv.hs --sync' -I nixpkgs-overlays=$(overlays)

system:
	@./system/setenv.sh

clean: clean-doc
	rm -f build/*.*
	rm -f bootrelease
	rm -rf nixpkgs
