all : tests

tests : 
	-rm -f .timestamp
	@make .timestamp

clean :
	rm -fr bats
	rm .timestamp

watch:
	while true; do make -s .timestamp; sleep 1; done

.timestamp: /usr/local/bin/kcov tests.bats Makefile ../mac-scan
	-rm -fr coverage
	-bats tests.bats
	-touch .timestamp

/usr/local/bin/kcov :
	wget https://github.com/SimonKagstrom/kcov/archive/v31.tar.gz
	tar xvf v31.tar.gz
	cd kcov-31; rm -fr build
	cd kcov-31; mkdir build
	cd kcov-31/build; cmake ..
	cd kcov-31/build; make
	cd kcov-31/build; sudo make install
