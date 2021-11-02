using Pkg

Pkg.add([
    PackageSpec(
        name = "BenchmarkConfigSweeps",
        url = "https://github.com/tkf/BenchmarkConfigSweeps.jl.git",
    ),
    PackageSpec(
        name = "BenchPerf",
        # path = dirname(@__DIR__),
        url = "https://github.com/tkf/BenchPerf.jl.git",
    ),
    PackageSpec(
        name = "BenchPerfConfigSweeps",
        # path = dirname(@__DIR__),
        url = "https://github.com/tkf/BenchPerf.jl.git",
        subdir = "lib/BenchPerfConfigSweeps",
    ),
])

Pkg.instantiate()
