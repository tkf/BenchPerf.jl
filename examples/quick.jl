import BenchmarkTools

function set_quick_params!(bench)
    bench.params.seconds = 0.001
    bench.params.evals = 1
    bench.params.samples = 1
    bench.params.gctrial = false
    bench.params.gcsample = false
    return bench
end

foreach_benchmark(f!, bench::BenchmarkTools.Benchmark) = f!(bench)
function foreach_benchmark(f!, group::BenchmarkTools.BenchmarkGroup)
    for x in values(group)
        foreach_benchmark(f!, x)
    end
end

function quick!(suite)
    foreach_benchmark(set_quick_params!, suite)
    return suite
end

function maybe_quick!(suite)
    if lowercase(get(ENV, "QUICK", "false")) == "true"
        @info "Use quick-run benchmark parameters"
        quick!(suite)
    end
    return suite
end
