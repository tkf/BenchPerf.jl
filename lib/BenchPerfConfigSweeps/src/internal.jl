function BenchPerfConfigSweeps.load(resultdir)
    sweep = BenchmarkConfigSweeps.load(resultdir)
    perfs = Vector{Union{GroupPerf,Nothing}}(undef, length(sweep.results))
    fill!(perfs, nothing)
    for (i, r) in enumerate(sweep.results)
        if r !== nothing
            perfpath = BenchPerf.perfpath(resultpath(resultdir, i))
            perfs[i] = BenchPerf.loadperf(perfpath)
        end
    end
    replacetrials!(sweep.results, perfs)
    return sweep
    # return BenchPerfSweepResult(sweep, perfs)
end

# struct BenchPerfSweepResult
#     sweep::SweepResult
#     perfs::Vector{Union{GroupPerf,Nothing}}
# end

function replacetrials!(results::AbstractVector, perfs::AbstractVector)
    @assert axes(results) == axes(perfs)
    for (r, p) in zip(results, perfs)
        r === nothing && continue
        @assert p !== nothing
        replacetrials!(r, p)
    end
    return results
end

function replacetrials!(bench::BenchmarkGroup, perf::GroupPerf)
    @assert issetequal(keys(bench), keys(perf))
    for (k, bv) in bench
        pv = perf[k]
        bench[k] = replacetrials!(bv, pv)
    end
    return bench
end

replacetrials!(bench::BenchmarkTools.Trial, perf::TrialPerf) = TrialResult(bench, perf)
