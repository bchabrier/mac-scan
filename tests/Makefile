all : tests

tests : 
	rm -f .timestamp
	@make watch

clean :
	rm -fr bats
	rm .timestamp

bats/bin/bats :
	git clone https://github.com/sstephenson/bats.git
	cd bats; ./install.sh bats

watch:
	while true; do make -s .timestamp; sleep 1; done

.timestamp: bats/bin/bats tests.bats Makefile ../mac-scan
	-bats/bin/bats tests.bats
	touch .timestamp
