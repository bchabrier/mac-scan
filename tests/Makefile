all : tests

tests : 
	rm -f .timestamp
	@make watch

clean :
	rm -fr bats
	rm .timestamp

watch:
	while true; do make -s .timestamp; sleep 1; done

.timestamp: tests.bats Makefile ../mac-scan
	-bats tests.bats
	touch .timestamp
