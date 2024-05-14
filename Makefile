feature?=*

.PHONY: sync
sync: lib/install.sh lib/library_scripts.sh
	@for d in src/*/; do cp -a $^ "$$d" >/dev/null 2>&1; done

.PHONY: test
test: $(wildcard test/$(feature)/scenarios.json)
	devcontainer features test -f $(patsubst test/%/scenarios.json,%,$^) --skip-autogenerated

.PHONY: ci-test-targets
ci-test-targets: $(wildcard test/$(feature)/scenarios.json)
	@echo $(patsubst test/%/scenarios.json,%,$^) | jq -Rc 'split(" ")  | {"features": .}'

.PHONY: ci-features-pathspecs
ci-features-pathspecs: $(wildcard src/$(feature))
	@echo $(patsubst src/%,%,$^) | jq -Rc 'split(" ") | map({(.): [ "src/" + . + "/**", ("test/" + . + "/**")]}) | add | {"features": .}'
	
test_cmdline?=""
.PHONY: gen-test
gen-test:
	 @scripts/gen_test.sh $(feature) '$(test_cmdline)'
