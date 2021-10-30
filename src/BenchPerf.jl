baremodule BenchPerf

function run end
# function save end
# function load end

function perfpath end
function loadperf end
function wrap end

module Internal

import JSON
import Tables
using BenchmarkTools

using ..BenchPerf: BenchPerf

include("perf.jl")
include("execution.jl")
include("wrap.jl")
include("tables.jl")

end  # module Internal

end  # baremodule BenchPerf
