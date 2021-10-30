BENCHMARKS = $(wildcard */Makefile)
BENCHMARK_TARGETS = $(patsubst %/Makefile, benchmark-%, $(BENCHMARKS))

.PHONY: benchmark*

benchmark: $(BENCHMARK_TARGETS)
$(BENCHMARK_TARGETS): benchmark-%:
	$(MAKE) -C $*
