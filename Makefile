.PHONY: user system update-release eclipse-extraplugins test

include ./bootstrap/version.sh

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

user: ## Update your user configuration
	@echo -e "Starting user configuration from ${PWD}.\nHold on.\n"
	@time -f "Completed after %E min" nix-shell -p vcsh --run './bootstrap/user/setenv.sh'

system: ## Update your system configuration
	@echo -e "Starting system configuration from ${PWD}.\nHold on.\n"
	sudo $(CURDIR)/bootstrap/system/setenv.sh

update-release:
	echo "Installing $(version) release in /etc"
	curl -sL $(scm_uri) | sudo tar xz  --one-top-level=devbox-$(version) -C /etc

eclipse-extraplugins: ## Add egit & m2e to Eclipse
	@time -f "Completed after %E min" nix-shell -p eclipses.eclipse-platform --run './bootstrap/user/eclipse-extraplugins.sh'

test:  ## Run local test
	nix-shell test --keep SSH_AUTH_SOCK --command './test/mr.sh'