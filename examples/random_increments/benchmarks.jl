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
    group["n=$n"] = @benchmarkable(
        increment_at!(xs, indices),
        setup = begin
            inputs = CACHE[$e]::$(typeof(CACHE[e]))
            xs = inputs.xs
            indices = inputs.indices
            fill!(xs, 0)
        end,
    )
end

SUITE = BenchPerf.wrap(group; detailed = 1)
