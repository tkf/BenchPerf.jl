const RATIO_TABLE = [
    # (numerator, denominator)-pair
    ("branch-misses", "branches"),
    ("L1-dcache-load-misses", "L1-dcache-loads"),
    ("L1-icache-load-misses", "L1-icache-loads"),
    ("LLC-load-misses", "LLC-loads"),
    ("dTLB-load-misses", "dTLB-loads"),
    ("iTLB-load-misses", "iTLB-loads"),
]

as_property_symbol(str::AbstractString) = Symbol(lowercase(replace(str, "-" => "_")))

const ALL_KEYS = vcat(first.(RATIO_TABLE), last.(RATIO_TABLE))

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

const ALL_NAMES = (as_property_symbol.(ALL_KEYS)...,)
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
