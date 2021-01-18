include docker.mk

PG_DUMP ?= pg_dump
PSQL ?= psql

.PHONY: help
help:
	@echo "build        - compile/order all sql files to out directory"
	@echo "fetch        - fetch submodules"
	@echo "fetch-latest - fetch submodules at latest upstream master refs"
	@echo "test         - run tests with in-place PostgreSQL"
	@echo "install      - Setup schemas on local system PostgreSQL"
	@echo "clean        - Delete generated files"
	@echo "develop      - Load schema into temp db and launch shell"
	@echo ""
	@$(MAKE) -s docker-help

out/json-schemas.sql: schema/sql/json-schemas.sql
	mkdir -p $(@D)
	./scripts/build schema < "$<" > "$@"

.PHONY: build
build: out/json-schemas.sql

schema/ext/json-schema/%:
	git submodule update --init --recursive $(@D)

test/sql/plpgunit/%:
	git submodule update --init --recursive $(@D)

.PHONY: fetch
fetch: schema/ext/json-schema/ test/sql/plpgunit/

.PHONY: fetch-latest
fetch-latest:
	git submodule foreach 'git checkout master && git pull'

SCHEMA_FILES := \
	schema/sql/schema.sql \
	schema/sql/access.sql \
	schema/sql/api.sql \
	schema/sql/metrics.sql \
	schema/sql/nss.sql \
	schema/sql/reserved.sql \
	schema/sql/stats.sql \
	schema/ext/json-schema/postgres-json-schema--0.1.0.sql \
	out/json-schemas.sql

.PHONY: install
install: $(SCHEMA_FILES)
	$(PSQL) -v ON_ERROR_STOP=1 $(foreach file,$(SCHEMA_FILES),-f $(file));

schema-dump.psql:
	$(PG_DUMP) -s > $@

.PHONY: test
test: \
	docker-test-build \
	docker-restart \
	docker-test \
	docker-stop

.PHONY: test-shell
test-shell: \
	docker-test-build \
	docker-restart \
	docker-test-shell \
	docker-stop

.PHONY: clean
clean:
	rm -rf out
