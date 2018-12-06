srcdir := docs/modules/ROOT/pages/index.adoc
assetdir := docs/modules/ROOT/assets/images
outdir := doc

doc: $(outdir)/devbox.html $(outdir)/devbox.pdf

$(outdir)/devbox.html: README.adoc build/$(assetdir)/devbox.png $(assetdir)/layout-indicator.png
	@nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

$(outdir)/devbox.pdf: README.adoc build/$(assetdir)/devbox.png $(assetdir)/layout-indicator.png
	@nix-shell -p asciidoctor --command "asciidoctor -r asciidoctor-pdf -b pdf $< -o $@"

$(outdir)/$(assetdir):
	@mkdir -p $(outdir)/$(assetdir)

build/$(assetdir)/%.png: $(outdir)/$(assetdir)
	@cp $(assetdir)/*.* $(outdir)/$(assetdir)/

clean-doc:
	@echo -e "Cleaning doc"
	rm -rf $(outdir)
