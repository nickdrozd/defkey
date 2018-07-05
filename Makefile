.PHONY : test

test:
	emacs -Q --batch --directory . -l defkey-tests.el -f ert-run-tests-batch-and-exit
