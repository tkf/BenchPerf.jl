JULIA = julia
JULIA_CMD ?= $(JULIA) --color=yes --startup-file=no

export JULIA_PROJECT = $(shell pwd)/..
export JULIA_LOAD_PATH = @

.PHONY: all benchmark

all: benchmark

benchmark: var/benchmark.done
var/benchmark.done: run.jl benchmarks.jl
	@mkdir -p var
	JULIA_EXCLUSIVE=1 $(JULIA_CMD) run.jl
	touch $@

report.ipynb: report.jl plots.jl
	$(JULIA_CMD) run_literate.jl

result/00_report.ipynb: report.ipynb
	@mkdir -p result
	cp $< $@

clean: clean-result
	rm -f report.ipynb

RESULT_TARGETS = result/00_report.ipynb
include ../result.mk
