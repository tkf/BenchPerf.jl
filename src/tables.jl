Tables.istable(::Type{TrialPerf}) = true
Tables.columnaccess(::Type{TrialPerf}) = true
Tables.columns(perf::TrialPerf) = Tables.CopiedColumns(fulltable(perf))
