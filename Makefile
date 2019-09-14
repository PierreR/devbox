.PHONY: clean user system update bootstrap update-release

config_file ?= /vagrant/config/box.dhall
devbox_release := $(shell curl --silent "https://api.github.com/repos/pierrer/devbox/releases/latest" | jq -r '.tag_name')

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

include docs/Makefile

home-manager:
	nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
	nix-channel --update

user: ## Update your user configuration [config_file]
	@echo -e "Starting user configuration from ${PWD}.\nHold on.\n"
	@time -f "Completed after %E min" ./user/setenv.sh $(config_file)

system: ## Update your system configuration [config_file]
	@echo -e "Starting system configuration from ${PWD}.\nHold on.\n"
	sudo $(CURDIR)/system/setenv.sh $(config_file)

update-release:
	rm -rf /etc/devbox-*
	echo "Installing $(devbox_release) release in /etc"
	curl -sL https://github.com/pierrer/devbox/archive/$(devbox_release).tar.gz | tar xz -C /etc

update: system user

bootstrap: home-manager update

clean: clean-doc
	rm -f build/*.*
