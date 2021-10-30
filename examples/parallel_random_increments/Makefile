JULIA = julia
JULIA_CMD ?= $(JULIA) --color=yes --startup-file=no

# TODO: use dedicated project
export JULIA_PROJECT = $(shell pwd)/../../test/BenchPerfTests

# TODO: enable this:
# export JULIA_LOAD_PATH = @

# For observing thraeds interfering each other
export JULIA_EXCLUSIVE=1

.PHONY: all benchmark

all: benchmark

benchmark: var/benchmark.done
var/benchmark.done: run.jl benchmarks.jl
	@mkdir -p var
	$(JULIA_CMD) run.jl
	touch $@
