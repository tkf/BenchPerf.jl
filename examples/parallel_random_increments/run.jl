using BenchmarkConfigSweeps

if Sys.CPU_THREADS < 8
    threads = [1, Sys.CPU_THREADS]
else
    threads = [1, 4, 8]
end

BenchmarkConfigSweeps.run(
    joinpath(@__DIR__, "build"),
    joinpath(@__DIR__, "benchmarks.jl"),
    BenchmarkConfigSweeps.nthreads.(threads),
)
