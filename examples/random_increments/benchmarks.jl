import BenchPerf
import Random
using BenchmarkTools

function increment_at!(xs, indices)
    for i in indices
        @inbounds xs[i] += 1
    end
end

CACHE = Dict()
group = BenchmarkGroup()
for e in 5:22
    n = 2^e
    CACHE[e] = (xs = zeros(Int, n), indices = rand(1:n, n))
    group["n=$n"] = bench = @benchmarkable(
        increment_at!(xs, indices),
        setup = begin
            inputs = CACHE[$e]::$(typeof(CACHE[e]))
            xs = inputs.xs
            indices = inputs.indices
            fill!(xs, 0)
        end,
        # Larger `samples` (than the default: 10_000) to bound the benchmark by
        # the time limit.
        samples = 1_000_000,
    )
    # Manually tune the benchmark since `BenchmarkConfigSweeps` does not do it
    # ATM.
    if e < 15
        tune!(bench)
    end
end

include("../quick.jl")
maybe_quick!(group)

SUITE = BenchPerf.wrap(group; detailed = 1)
