
.PHONY: sync
sync: lib/install.sh lib/library_scripts.sh
	@for d in src/*/; do cp -a $^ $$d; done

feature?=*
.PHONY: update
update: $(wildcard src/$(feature)/install.sh)
	@for install in $^; do $$install --pkgver; done
