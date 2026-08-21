.PHONY: run run_verbose

.DEFAULT_GOAL := run

run:
	./ralph.sh tasks.txt

run_verbose:
	./ralph.sh --verbose tasks.txt
