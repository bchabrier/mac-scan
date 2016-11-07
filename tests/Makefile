all : tests

tests : 
	-rm -f .timestamp
	@make .timestamp

clean :
	rm -fr bats
	rm .timestamp

watch:
	while true; do make -s .timestamp; sleep 1; done

.timestamp: tests.bats Makefile ../mac-scan
	-rm -fr coverage
	-bats tests.bats
	-touch .timestamp
