.PHONY: clean user system cicd-shell

bootrelease:
	@echo -e "Downloading all required packages.\nHold on. It might take several minutes."
	@nix-shell -A user release.nix --run "touch bootrelease" > /vagrant/boot.log 2>&1

user: bootrelease
	@nix-shell -A user release.nix --run 'runghc user/setenv.hs' | tee /vagrant/last_run.log

system:
	@./system/setenv.sh

cicd-shell:
	@nix-env -f release.nix -iA cicd-shell

doc: doc/devbox.html

doc/devbox.html: README.adoc CHANGELOG.adoc meta.adoc
	@nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

doc/devbox.pdf: README.adoc meta.adoc
	@nix-shell -p asciidoctor --command "asciidoctor-pdf $< -o $@"

clean:
	rm -f doc/devbox.*
	rm -f build/*.*
	rm bootrelease
