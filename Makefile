TESTS := $(wildcard test/*.test.bash)

.PHONY: test
test:
	@for t in $(TESTS); do echo "== $$t"; bash "$$t" || exit 1; done
