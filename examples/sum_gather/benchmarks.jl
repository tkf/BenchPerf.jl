import BenchPerf
import Random
using BenchmarkTools

@noinline function sum_gather(xs, indices)
    s = zero(eltype(xs))
    for i in indices
        s += @inbounds xs[i]
    end
    return s
end

CACHE = Dict()
group = BenchmarkGroup()
for e in 5:22
    n = 2^e
    CACHE[e] = (xs = zeros(Int, n), indices = rand(1:n, n))
    group["n=$n"] = bench = @benchmarkable(
        sum_gather(xs, indices),
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

SUITE = BenchPerf.wrap(group; detailed = 1)
