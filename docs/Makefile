srcdir := docs/modules/ROOT/pages/index.adoc
assetdir := docs/modules/ROOT/assets/images
outdir := doc

doc: $(outdir)/devbox.html $(outdir)/devbox.pdf

$(outdir)/devbox.html: README.adoc cicd-shell.adoc puppet.adoc build/$(assetdir)/devbox.png $(assetdir)/layout-indicator.png
	@nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

$(outdir)/devbox.pdf: README.adoc cicd-shell.adoc puppet.adoc build/$(assetdir)/devbox.png $(assetdir)/layout-indicator.png
	@nix-shell -p asciidoctor --command "asciidoctor -r asciidoctor-pdf -b pdf $< -o $@"

puppet.adoc:
	curl -s http://stash.cirb.lan/projects/CICD/repos/puppet-shared-scripts/raw/$(srcdir)?at=refs/heads/master -o $@

cicd-shell.adoc:
	curl -s http://stash.cirb.lan/projects/CICD/repos/cicd-shell/raw/docs/modules/ROOT/pages/index.adoc?at=refs/heads/master -o $@

$(outdir)/$(assetdir):
	@mkdir -p $(outdir)/$(assetdir)

build/$(assetdir)/%.png: $(outdir)/$(assetdir)
	@cp $(assetdir)/*.* $(outdir)/$(assetdir)/

clean-doc:
	@echo -e "Cleaning doc"
	rm puppet.adoc
	rm cicd-shell.adoc
	rm -rf $(outdir)
