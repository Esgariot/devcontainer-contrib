
.PHONY: sync
sync: lib/install.sh lib/library_scripts.sh
	@for d in src/*/; do cp -a $^ "$$d" >/dev/null 2>&1; done

feature?=*
.PHONY: update
update: $(wildcard src/$(feature)/install.sh)
	@for install in $^; do $$install --pkgver; done

test_cmdline?=""
.PHONY: gen-test
gen-test:
	 @scripts/gen_test.sh $(feature) '$(test_cmdline)'
