.PHONY: clean user system

user:
	@nix-shell release.nix --run 'script -c user/setenv.sh -q /vagrant/last_run.log'

system:
	@./system/setenv.sh

doc: doc/devbox.html doc/devbox.pdf

doc/devbox.html: README.adoc CHANGELOG.adoc meta.adoc
	@nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

doc/devbox.pdf: README.adoc meta.adoc
	@nix-shell -p asciidoctor --command "asciidoctor-pdf $< -o $@"

clean:
	rm -f doc/devbox.*
	rm -f build/*.*
