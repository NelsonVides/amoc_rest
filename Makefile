.PHONY: all test generate validate compile console dialyzer xref integration

ifdef SUITE
	SUITE_OPTS = --suite $$SUITE
endif

OutputDir ?= tmp

define openapi-generator
  docker run --rm -v "${PWD}:/local" -w "/local" \
             openapitools/openapi-generator-cli:v6.5.0
endef

all: compile

test: validate compile dialyzer xref generate
	diff -sq priv/openapi.json "$(OutputDir)/priv/openapi.json"

generate:
	$(openapi-generator) generate \
	  -g erlang-server -i openapi.yaml -o "$(OutputDir)" \
	  --additional-properties=packageName=amoc_rest

validate:
	$(openapi-generator) validate -i openapi.yaml

compile:
	rebar3 compile

clean:
	rm -rf _build

console:
	rebar3 shell --apps=amoc_rest

dialyzer:
	rebar3 dialyzer

xref:
	rebar3 xref

ct:
	rm -rfv priv/scenarios_ebin/*.beam
	## eunit and ct commands always add a test profile to the run
	rebar3 ct --verbose $(SUITE_OPTS)

integration:
	./integration_test/stop_demo_cluster.sh
	./integration_test/build_docker_image.sh
	./integration_test/start_demo_cluster.sh
	./integration_test/test_amoc_cluster.sh
	./integration_test/test_distribute_scenario.sh
	./integration_test/test_run_scenario.sh
	./integration_test/test_add_new_node.sh
