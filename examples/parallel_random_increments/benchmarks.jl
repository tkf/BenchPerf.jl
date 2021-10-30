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
    group["n=$n"] = @benchmarkable(
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
    )
end

SUITE = BenchPerf.wrap(group; detailed = 1)
