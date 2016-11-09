all : tests

tests : 
	@rm -f .timestamp
	@make -s .timestamp

clean :
	rm -fr bats
	rm .timestamp

watch:
	while true; do make -s -i .timestamp; sleep 1; done

.timestamp: /usr/local/bin/kcov tests.bats Makefile ../mac-scan
	@touch .timestamp
	@rm -fr coverage
	@echo bats tests.bats
	bats tests.bats

/usr/local/bin/kcov :
	sudo apt-get install -qq libelf-dev libdw-dev
	wget https://github.com/SimonKagstrom/kcov/archive/v31.tar.gz
	tar xvf v31.tar.gz
	cd kcov-31; rm -fr build
	cd kcov-31; mkdir build
	cd kcov-31/build; cmake ..
	cd kcov-31/build; make
	cd kcov-31/build; sudo make install
