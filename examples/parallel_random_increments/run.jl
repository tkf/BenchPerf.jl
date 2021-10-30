using BenchmarkConfigSweeps

BenchmarkConfigSweeps.run(
    joinpath(@__DIR__, "build"),
    joinpath(@__DIR__, "benchmarks.jl"),
    BenchmarkConfigSweeps.nthreads.([1, 4, 8]),
)
