module TestAqua

import Aqua
import BenchPerf

test() = Aqua.test_all(
    BenchPerf;
    # Compat.jl is conditionally loaded:
    stale_deps = if BenchPerf.Internal.USE_COMPAT
        true
    else
        (; ignore = [:Compat])
    end,
)

end  # module
