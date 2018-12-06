include docs/Makefile

.PHONY: clean user system

user:
	@echo -e "Starting user configuration in ${PWD}.\nHold on.\n"
	@time -f "Completed after %E min" ./user/setenv.sh /vagrant/config/box.dhall | tee /vagrant/user_lastrun.log

system:
	@./system/setenv.sh

clean: clean-doc
	rm -f build/*.*
