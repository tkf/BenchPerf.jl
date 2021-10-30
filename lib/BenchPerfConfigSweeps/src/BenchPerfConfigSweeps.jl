baremodule BenchPerfConfigSweeps

function load end
# function simpletable end
# function flattable end

module Internal

import BenchPerf
import BenchmarkConfigSweeps
using BenchmarkTools: BenchmarkTools, BenchmarkGroup

# TODO: Turn these to public API?
using BenchPerf.Internal: GroupPerf, GroupResult, TrialPerf, TrialResult
using BenchmarkConfigSweeps.Internal: SweepResult, resultpath

using ..BenchPerfConfigSweeps: BenchPerfConfigSweeps

include("internal.jl")

end  # module Internal

end  # baremodule BenchPerfConfigSweeps
