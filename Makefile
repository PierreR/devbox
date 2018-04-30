.PHONY: clean user system cicd-shell

nixpkgs-config := 1.5.0
docdir := docs/local

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

doc: $(docdir)/devbox.html $(docdir)/devbox.pdf $(docdir)/res/devbox.png $(docdir)/res/layout-indicator.png

$(docdir):
	mkdir $(docdir)
$(docdir)/devbox.html: README.adoc CHANGELOG meta.adoc cicd-shell.adoc puppet.adoc
	@nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

$(docdir)/devbox.pdf: README.adoc meta.adoc cicd-shell.adoc puppet.adoc
	@nix-shell -p asciidoctor --command "asciidoctor -r asciidoctor-pdf -b pdf $< -o $@"

$(docdir)/res/%.png:
	@cp -r res $(docdir)/

clean:
	rm -rf $(docdir)
	rm -f build/*.*
	rm -f bootrelease
	rm -rf nixpkgs
