# # Multi-thread `sum_gather`

include("plots.jl");

# ## Throughput, L1, and last-level (LL) cache misses
#
# (Note: the LL cache miss data may not be available in some machines.)
#
# The same set of data is plotted with two different metrics for the input size
# (x-axis).

# ### x-axis: input size per thread

# The curves for L1 cache miss are virtually identical across benchmarks that
# are run with different number of threads (color, `nthreads`).

plt_throughput_cache_miss_vs_per_thread_size
#-

# ### x-axis: total input size

# The rising part of the curves for LL cache miss for when the total input size
# is large coincide across benchmarks with different number of threads (color,
# `nthreads`). This is where the total input size crosses the LL cache size.

plt_throughput_cache_miss_vs_total_size
#-
