.PHONY: clean user system cicd-shell

nixpkgs-config := 1.3.9

bootstrap:
	@mkdir -p ${PWD}/nixpkgs
	@curl -s -L https://api.github.com/repos/CIRB/nixpkgs-config/tarball/$(nixpkgs-config) | tar xz -C ${PWD}/nixpkgs --strip-component=1

bootrelease: bootstrap
	@echo -e "Downloading all required packages.\nHold on. It will take several minutes."
	@nix-shell -A trigger release.nix --run "touch bootrelease" -I nixpkgs-overlays=${PWD}/nixpkgs/overlays > /vagrant/user_boot.log 2>&1

user: bootrelease
	@nix-shell -A user release.nix --run 'runghc user/setenv.hs' -I nixpkgs-overlays=${PWD}/nixpkgs/overlays | tee /vagrant/user_lastrun.log

sync-user:
	@nix-shell -A user release.nix --run 'runghc user/setenv.hs --sync' -I nixpkgs-overlays=${PWD}/nixpkgs/overlays

system:
	@./system/setenv.sh

doc: doc/devbox.html doc/devbox.pdf doc/res/devbox.png doc/res/layout-indicator.png

doc/devbox.html: README.adoc CHANGELOG.adoc meta.adoc cicd-shell.adoc puppet.adoc
	@nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

doc/devbox.pdf: README.adoc meta.adoc cicd-shell.adoc puppet.adoc
	@nix-shell -p asciidoctor --command "asciidoctor -r asciidoctor-pdf -b pdf $< -o $@"

doc/res/%.png:
	cp -r res doc/

clean:
	rm -rf doc/
	rm -f build/*.*
	rm -f bootrelease
	rm -rf nixpkgs
