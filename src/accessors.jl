const RATIO_TABLE = [
    # (numerator, denominator)-pair
    ("branch-misses", "branches"),
    ("L1-dcache-load-misses", "L1-dcache-loads"),
    ("L1-icache-load-misses", "L1-icache-loads"),
    ("LLC-load-misses", "LLC-loads"),
    ("dTLB-load-misses", "dTLB-loads"),
    ("iTLB-load-misses", "iTLB-loads"),
    ("stalled-cycles-frontend", "cycles"),
    ("stalled-cycles-backend", "cycles"),
]

const OTHER_KEYS = [
    # "task-clock"  TODO: float
    "context-switches",
    "cpu-migrations",
    "page-faults",
    "instructions",
]

as_property_symbol(str::AbstractString) = Symbol(lowercase(replace(str, "-" => "_")))

const ALL_KEYS = unique!(vcat(first.(RATIO_TABLE), last.(RATIO_TABLE), OTHER_KEYS))

for key in ALL_KEYS
    val = Val{as_property_symbol(key)}
    @eval getvalue(t::TrialPerf, ::$val)::Union{Int,Nothing} =
        @something(get(t, $key, nothing), return)
end

for (num, den) in RATIO_TABLE
    numval = Val{as_property_symbol(num)}
    denval = Val{as_property_symbol(den)}
    @eval function getratio(t::TrialPerf, ::$numval)::Union{Float64,Nothing}
        num = @something(getvalue(t, $numval()), return)
        den = @something(getvalue(t, $denval()), return)
        return num / den
    end
end

# perf calls them (and the ratios) "shaddow stats"
const DERIVED_NAMES = [
    :instructions_per_cycle,  # "insn per cycle"
    :stalled_cycles_per_instructions,  # "stalled cycles per insn"
]

const ALL_NAMES = (as_property_symbol.(ALL_KEYS)..., DERIVED_NAMES...)
const RATIO_NAMES = (as_property_symbol.(first.(RATIO_TABLE))...,)

struct RatioAccessor
    trial::TrialPerf
end

struct PercentAccessor
    trial::TrialPerf
end

Base.getproperty(accessor::RatioAccessor, name::Symbol) =
    getratio(getfield(accessor, :trial), Val{name}())
Base.getproperty(accessor::PercentAccessor, name::Symbol) =
    @something(getratio(getfield(accessor, :trial), Val{name}()), return) * 100

function Base.propertynames(
    accessor::Union{RatioAccessor,PercentAccessor},
    private::Bool = false,
)
    pubnames = RATIO_NAMES
    if private
        return (pubnames..., fieldnames(typeof(accessor)))
    else
        return pubnames
    end
end

getratio(::TrialPerf, @nospecialize(_val::Val{name})) where {name} =
    error(name, " is not a name of suportd ratio ", RATIO_NAMES)

function getvalue(trial::TrialPerf, ::Val{:instructions_per_cycle})
    num = @something(trial.instructions, return)
    den = @something(trial.cycles, return)
    return num / den
end

# https://github.com/torvalds/linux/blob/v5.15/tools/perf/util/stat-shadow.c#L979-L991
function getvalue(trial::TrialPerf, ::Val{:stalled_cycles_per_instructions})
    f = @something(trial.stalled_cycles_frontend, return)
    b = @something(trial.stalled_cycles_backend, return)
    num = max(f, b)
    den = @something(trial.instructions, return)
    return num / den
end
