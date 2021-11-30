module TestParsing

import Tables
using BenchPerf.Internal: TrialPerf
using Test

load_sample(name) = TrialPerf(read(joinpath(@__DIR__, "samples", name * ".csv"), String))

function load_samples()
    samples = Iterators.map(readdir(joinpath(@__DIR__, "samples"); join = true)) do path
        splitext(basename(path))[1] => TrialPerf(read(path, String))
    end
    samples = Iterators.filter(!isnothing, samples)
    return Dict(samples)
end

function test_event_samples()
    @testset "$name" for (name, trial) in load_samples()
        @test !isempty(keys(trial))
    end
end

function test_full_samples()
    @testset "$name" for (name, trial) in load_samples()
        @test !isempty(Tables.columns(trial).value)
    end
end

end  # module
