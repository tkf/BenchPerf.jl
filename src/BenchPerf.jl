baremodule BenchPerf

function run end
# function save end
# function load end

function perfpath end
function loadperf end
function wrap end

module Internal

import JSON
import PrettyTables
import Tables
using BenchmarkTools

if !isdefined(@__MODULE__, Symbol("@something"))
    using Compat: @something
    const USE_COMPAT = true
else
    const USE_COMPAT = false
end

using ..BenchPerf: BenchPerf

include("perf.jl")
include("execution.jl")
include("wrap.jl")
include("accessors.jl")
include("show.jl")
include("tables.jl")

end  # module Internal

end  # baremodule BenchPerf
