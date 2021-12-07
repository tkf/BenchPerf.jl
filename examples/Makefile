JULIA = julia
JULIA_CMD ?= $(JULIA) --color=yes --startup-file=no

BENCHMARKS = $(wildcard */Makefile)
BENCHMARK_TARGETS = $(patsubst %/Makefile, benchmark-%, $(BENCHMARKS))

.PHONY: benchmark*

benchmark: $(BENCHMARK_TARGETS)
$(BENCHMARK_TARGETS): benchmark-%: Manifest.toml
	$(MAKE) -C $*

Manifest.toml:
	$(JULIA_CMD) --project=. instantiate.jl

reinstantiate:
	rm -f Manifest.toml
	$(MAKE) Manifest.toml
