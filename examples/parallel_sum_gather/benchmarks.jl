import BenchPerf
import Random
using BenchmarkTools

include("utils.jl")

function sum_gather(xs, indices)
    s = zero(eltype(xs))
    for i in indices
        s += @inbounds xs[i]
    end
    return s
end

function threaded_sum_gather(xss, iss, nrepeats)
    sums = zeros(eltype(eltype(xss)), length(xss))
    Threads.@threads for j in eachindex(xss, iss)
        s = sums[j]
        for _ in 1:nrepeats
            s += sum_gather(xss[j], iss[j])
        end
        sums[j] = s
    end
    return sum(sums)
end

group = BenchmarkGroup()
for e in 5:22
    n = 2^e
    nrepeats = nrepeats_from_n(n)
    group["n=$n"] = bench = @benchmarkable(
        threaded_sum_gather(xss, iss, $nrepeats),
        setup = begin
            Random.seed!(43)
            # Iteration over nthreads can be done in a single process.  But it's
            # done via BenchmarkConfigSweeps just for the demo.
            nt = Threads.nthreads()
            n = $n
            xss = [zeros(Int, n) for _ in 1:nt]
            iss = [rand(1:n, n) for _ in 1:nt]
        end,
        # Larger `samples` (than the default: 10_000) to bound the benchmark by
        # the time limit.
        samples = 1_000_000,
    )
    # Not tuning it like ../random_increments/benchmarks.jl since `nrepeats`
    # already takes care of it. To verify this, uncomment the following line,
    # run the benchmarks, and then check `unique(df.evals)`.
    #=
    if e < 15
        tune!(bench)
    end
    =#
end

include("../quick.jl")
maybe_quick!(group)

SUITE = BenchPerf.wrap(group; detailed = 1)
