# # Single-thread `sum_gather`

include("plots.jl");

# ## Throughput, L1, and last-level (LL) cache misses
#
# (Note: the LL cache miss data may not be available in some machines.)

plt_throughput_cache_miss

# ## Tuned `evals`

plt_evals
