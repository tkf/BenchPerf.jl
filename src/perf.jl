# TODO: Use LinuxPerf.jl after https://github.com/JuliaPerf/LinuxPerf.jl/pull/22

struct PerfConfig
    detailed::Int
    event::Union{Nothing,String}
    per_thread::Bool
    all_cpus::Bool
    cpu::Union{Nothing,String}
    _perfopts::Cmd  # (for easily trying new options) TODO: remove this
end

function as_perf_config(;
    detailed::Union{Integer,Nothing} = nothing,
    event::Union{AbstractVector{<:AbstractString},Nothing} = nothing,
    per_thread::Bool = false,
    cpu::Union{AbstractString,Nothing} = nothing,
    all_cpus::Bool = cpu !== nothing,
    _perfopts::Cmd = ``,
)
    if detailed === nothing
        detailed = 0
    elseif detailed < 0
        error("`detailed` must be 1, 2, or 3")
    end
    if event !== nothing
        event = join(event, ",")
    end
    return PerfConfig(detailed, event, per_thread, all_cpus, cpu, _perfopts)
end

const CacheDict = Dict{String,Union{Float64,Int}}
const CacheRef = Ref{Union{Nothing,CacheDict}}

struct TrialPerf
    output::String
    cache::CacheRef
end

TrialPerf(output) = TrialPerf(output, CacheRef(nothing))
JSON.lower(t::TrialPerf) = (; output = getfield(t, :output))

struct GroupPerf
    group::Dict{Any,Union{TrialPerf,GroupPerf}}
end

const GenericPerf = Union{TrialPerf,GroupPerf}

GroupPerf() = GroupPerf(Dict{Any,GenericPerf}())

Base.keys(g::GroupPerf) = keys(g.group)
Base.get(g::GroupPerf, k, default) = get(g.group, k, default)
Base.getindex(g::GroupPerf, k) = g.group[k]
Base.setindex!(g::GroupPerf, v::GenericPerf, k) = g.group[k] = v

const FIELD_SEPARATOR = '\\'  # as recommended in perf-stat(1)

function Base.Cmd(cfg::PerfConfig)
    cmd = `perf stat`
    if cfg.detailed > 0
        detailed = "-" * "d"^cfg.detailed
        cmd = `$cmd $detailed`
    end
    if cfg.event !== nothing
        cmd = `$cmd --event=$(cfg.event)`
    end
    if cfg.per_thread
        cmd = `$cmd --per-thread`
    end
    cmd = `$cmd $(cfg._perfopts)`
    cmd = `$cmd --field-separator=$FIELD_SEPARATOR`
    if cfg.all_cpus
        cmd = `$cmd --all-cpus`
        if cfg.cpu !== nothing
            cmd = `$cmd --cpu=$(cfg.cpu)`
        end
    else
        cmd = `$cmd --pid=$(getpid())`
    end
    return cmd
end

function withperf(f, cfg::PerfConfig)
    cmd = Cmd(cfg)
    output = Ref{String}()
    outpipe = Pipe()
    proc = run(pipeline(cmd, stdout = stderr, stderr = outpipe); wait = false)
    local y
    @sync begin
        try
            close(outpipe.in)
            @async output[] = read(outpipe, String)
            y = f()
        catch
            close(outpipe)
            rethrow()
        finally
            @debug "Stopping perf:" cmd
            flush(stderr)
            kill(proc, Base.SIGINT)
            wait(proc)
        end
    end
    return (y, TrialPerf(output[]))
end

function getcache(trial::TrialPerf)
    ref = getfield(trial, :cache)
    cache = ref[]
    if cache === nothing
        ref[] = cache = parsestat(getfield(trial, :output))
    end
    return cache
end

function parsestat(output)
    cache = CacheDict()
    for ln in eachline(IOBuffer(output))
        parts = split(ln, FIELD_SEPARATOR)
        isempty(parts[1]) && continue
        k = parts[3]
        parts[1] == "<not supported>" && continue
        v = tryparse(Int, parts[1])
        if v === nothing
            v = tryparse(Float64, parts[1])
            if v === nothing
                error("failed parsing row: ", ln)
            end
        end
        cache[k] = v
    end
    return cache
end

Base.keys(trial::TrialPerf) = keys(getcache(trial))
Base.get(trial::TrialPerf, key, default) = get(getcache(trial), key, default)
Base.getindex(trial::TrialPerf, event::AbstractString) = getcache(trial)[event]

function Base.propertynames(::TrialPerf, private::Bool = false)
    pubnames = (ALL_NAMES..., :ratio, :percent)
    if private
        return (pubnames..., fieldnames(TrialPerf))
    else
        return pubnames
    end
end

function Base.getproperty(trial::TrialPerf, name::Symbol)
    if name in ALL_NAMES
        return getvalue(trial, Val{name}())
    elseif name === :ratio
        return RatioAccessor(trial)
    elseif name === :percent
        return PercentAccessor(trial)
    else
        return getfield(trial, name)
    end
end

fulltable(trial::TrialPerf) = fulltable(trial.output)
function fulltable(output::AbstractString)
    table = (
        value = Union{Float64,Int64,Nothing}[],
        unit = Union{String,Nothing}[],
        event = String[],
        runtime = Union{Int64,Nothing}[],
        percentage = Union{Float64,Nothing}[],
        optional_metric = Union{Float64,Nothing}[],
        optional_unit = Union{String,Nothing}[],
    )
    for ln in eachline(IOBuffer(output))
        parts = split(ln, FIELD_SEPARATOR)
        push!(
            table.value,
            something(tryparse(Int, parts[1]), tryparse(Float64, parts[1]), Some(nothing)),
        )
        push!(table.unit, isempty(parts[2]) ? nothing : parts[2])
        push!(table.event, parts[3])
        push!(table.runtime, tryparse(Int64, parts[4]))
        push!(table.percentage, tryparse(Float64, parts[5]))
        push!(table.optional_metric, tryparse(Float64, parts[6]))
        push!(table.optional_unit, parts[7])
    end
    return table
end
