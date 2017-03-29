.PHONY: clean user system cicd-shell

overlays-version := 1.2.5

bootstrap:
	@mkdir -p ${PWD}/overlays
	@curl -s -L https://api.github.com/repos/CIRB/nixpkgs-overlays/tarball/$(overlays-version) | tar xz -C ${PWD}/overlays --strip-component=1

bootrelease: bootstrap
	@echo -e "Downloading all required packages.\nHold on. It will take several minutes."
	@nix-shell -A trigger release.nix --run "touch bootrelease" -I nixpkgs-overlays=${PWD}/overlays > /vagrant/user_boot.log 2>&1

user: bootrelease
	@nix-shell -A user release.nix --run 'runghc user/setenv.hs' -I nixpkgs-overlays=${PWD}/overlays | tee /vagrant/user_lastrun.log

sync-user:
	@nix-shell -A user release.nix --run 'runghc user/setenv.hs --sync' -I nixpkgs-overlays=${PWD}/overlays

system:
	@./system/setenv.sh

doc: doc/devbox.html doc/devbox.pdf

doc/devbox.html: README.adoc CHANGELOG.adoc meta.adoc
	@nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

doc/devbox.pdf: README.adoc meta.adoc
	@nix-shell -p asciidoctor --command "asciidoctor -r asciidoctor-pdf -b pdf $< -o $@"

clean:
	rm -f doc/devbox.*
	rm -f build/*.*
	rm -f bootrelease
	rm -rf overlays
