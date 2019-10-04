srcfile := docs/modules/ROOT/pages/index.adoc
assetdir := docs/modules/ROOT/assets/images
outdir ?= dist

doc: $(outdir)/devbox.html $(outdir)/devbox.pdf ## Generate documentation both in html and pdf

$(outdir)/devbox.html: README.adoc $(outdir)/$(assetdir)/devbox.png $(outdir)/$(assetdir)/layout-indicator.png
	@nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

$(outdir)/devbox.pdf: README.adoc $(outdir)/$(assetdir)/devbox.png $(outdir)/$(assetdir)/layout-indicator.png
	@nix-shell -p asciidoctor --command "asciidoctor -r asciidoctor-pdf -b pdf $< -o $@"

$(outdir)/$(assetdir):
	@mkdir -p $(outdir)/$(assetdir)

$(outdir)/$(assetdir)/%.png: $(outdir)/$(assetdir)
	@cp $(assetdir)/*.* $(outdir)/$(assetdir)/

clean-doc:
	@echo -e "Cleaning doc"
	rm -rf $(outdir)
