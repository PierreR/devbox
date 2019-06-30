.PHONY: clean user system

config_file ?= /vagrant/config/box.dhall

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

include docs/Makefile

user: ## Update your user configuration [config_file]
	@echo -e "Starting user configuration from ${PWD}.\nHold on.\n"
	@time -f "Completed after %E min" ./user/setenv.sh $(config_file)

system: ## Update your system configuration [config_file]
	@echo -e "Starting system configuration from ${PWD}.\nHold on.\n"
	sudo $(CURDIR)/system/setenv.sh $(config_file)

update: system user

clean: clean-doc
	rm -f build/*.*
