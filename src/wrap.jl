struct BenchmarkWrapper
    benchmark::BenchmarkTools.Benchmark
    cfg::PerfConfig
end

struct GroupWrapper
    benchmark::BenchmarkGroup
    cfg::PerfConfig
end

BenchPerf.wrap(b::BenchmarkTools.Benchmark; kwargs...) =
    BenchmarkWrapper(b, as_perf_config(; kwargs...))

BenchPerf.wrap(b::BenchmarkGroup; kwargs...) = GroupWrapper(b, as_perf_config(; kwargs...))

function Base.run(bp::Union{BenchmarkWrapper,GroupWrapper}; runopts...)
    b, p = execute(bp.benchmark, bp.cfg, runopts)
    return as_result(b, p)
end

function BenchPerf.perfpath(filepath::AbstractString)
    if endswith(filepath, ".json")
        return filepath[1:end-length(".json")] * "-perf.json"
    else
        error("Result `filepath` must have `.json` extension; got: ", filepath)
    end
end

function BenchmarkTools.save(filepath::AbstractString, result::GroupResult)
    perfpath = BenchPerf.perfpath(filepath)
    BenchmarkTools.save(filepath, result.benchmark)
    open(perfpath, write = true) do io
        JSON.print(io, result.perf)
    end
    return
end

BenchPerf.loadperf(perfpath) = from_json(JSON.parsefile(perfpath))

function from_json(d::Dict{String,Any})
    if (group = get(d, "group", nothing)) !== nothing
        group = group::Dict{String,Any}
        perf = GroupPerf()
        for (k, v) in group
            perf[k] = from_json(v)
        end
        return perf
    elseif (output = get(d, "output", nothing)) !== nothing
        return TrialPerf(output)
    else
        error("unrecognized dictionary: ", d)
    end
end
