import BenchPerf
import Random
using BenchmarkTools

include("utils.jl")

function increment_at!(xs, indices)
    for i in indices
        @inbounds xs[i] += 1
    end
end

function threaded_increment_at!(xss, iss, nrepeats)
    Threads.@threads for j in eachindex(xss, iss)
        for _ in 1:nrepeats
            increment_at!(xss[j], iss[j])
        end
    end
end

group = BenchmarkGroup()
for e in 5:22
    n = 2^e
    nrepeats = nrepeats_from_n(n)
    group["n=$n"] = bench = @benchmarkable(
        threaded_increment_at!(xss, iss, $nrepeats),
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
