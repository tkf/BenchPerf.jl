struct TrialResult
    benchmark::BenchmarkTools.Trial
    perf::TrialPerf
end

struct GroupResult
    benchmark::BenchmarkGroup
    perf::GroupPerf
end

as_result(b::BenchmarkTools.Trial, p::TrialPerf) = TrialResult(b, p)
as_result(b::BenchmarkGroup, p::GroupPerf) = GroupResult(b, p)

function BenchPerf.run(bench_or_group; verbose = false, kwargs...)
    cfg = as_perf_config(; kwargs...)
    b, p = execute(bench_or_group, cfg, (; verbose = verbose))
    return as_result(b, p)
end

_isverbose(; verbose = false, _ignore...) = verbose

execute(b::BenchmarkTools.Benchmark, cfg::PerfConfig, runopts, _level = 0) =
    withperf(() -> run(b; runopts...), cfg)

function execute(g::BenchmarkGroup, cfg::PerfConfig, runopts, level = 0)
    n = length(g)
    benchresult = similar(g)
    perfresult = GroupPerf()
    for (i, (k, v)) in enumerate(pairs(g))
        _isverbose(; runopts...) && println(stderr, "  "^level, "[$i/$n] ", k)
        benchresult[k], perfresult[k] = execute(v, cfg, runopts, level + 1)
    end
    return (benchresult, perfresult)
end
