JULIA = julia
JULIA_CMD ?= $(JULIA) --color=yes --startup-file=no

# TODO: use dedicated project
export JULIA_PROJECT = $(shell pwd)/../../test/environments/main

# TODO: enable this:
# export JULIA_LOAD_PATH = @

.PHONY: all benchmark

all: benchmark

benchmark: var/benchmark.done
var/benchmark.done: run.jl benchmarks.jl
	@mkdir -p var
	$(JULIA_CMD) run.jl
	touch $@
