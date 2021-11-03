using BenchPerfConfigSweeps
using DataFrames
using VegaLite

include("utils.jl")

sweepresult = BenchPerfConfigSweeps.load(joinpath(@__DIR__, "build"))

df_raw = DataFrame(sweepresult)

let
    global df = select(df_raw, Not(:trial))
    df[:, :time_ns] = map(t -> minimum(t.benchmark).time, df_raw.trial)
    # df[:, :evals] = map(t -> t.benchmark.params.evals, df_raw.trial)
    df[:, :L1_miss_percent] = map(df_raw.trial) do t
        t.perf["L1-dcache-load-misses"] / t.perf["L1-dcache-loads"] * 100
    end
    df[:, :LL_miss_percent] = map(df_raw.trial) do t
        get(t.perf, "LLC-load-misses", missing) / get(t.perf, "LLC-loads", missing) * 100
    end
    nrepeats = nrepeats_from_n.(df.n)
    bytes = df.n .* 2 * sizeof(Int)
    global throughput_unit = "GiB/thread/sec"
    df[:, :throughput] = bytes .* nrepeats ./ 2^30 ./ (df.time_ns / 1e9)
    df[:, :MiB] = bytes ./ 2^20
    df[:, :total_MiB] = df.nthreads .* bytes ./ 2^20
    df
end

df |> [
    @vlplot(
        mark = {:line, point = true},
        x = {:MiB, scale = {type = :log}},
        y = {:throughput, title = throughput_unit},
        color = {:nthreads, type = :nominal},
    )
    @vlplot(
        mark = {:line, point = true},
        x = {:total_MiB, scale = {type = :log}},
        y = {:throughput, title = throughput_unit},
        color = {:nthreads, type = :nominal},
    )
]

df |> [
    @vlplot(
        mark = {:line, point = true},
        x = {:MiB, scale = {type = :log}},
        y = {:throughput, title = throughput_unit},
        color = {:nthreads, type = :nominal},
    )
    @vlplot(
        mark = {:line, point = true},
        x = {:MiB, scale = {type = :log}},
        y = {:L1_miss_percent, title = "L1 cache miss [%]"},
        color = {:nthreads, type = :nominal},
    )
    @vlplot(
        mark = {:line, point = true},
        x = {:MiB, scale = {type = :log}},
        y = {:LL_miss_percent, title = "LL cache miss [%]"},
        color = {:nthreads, type = :nominal},
    )
]

df |> [
    @vlplot(
        mark = {:line, point = true},
        x = {:total_MiB, scale = {type = :log}},
        y = {:throughput, title = throughput_unit},
        color = {:nthreads, type = :nominal},
    )
    @vlplot(
        mark = {:line, point = true},
        x = {:total_MiB, scale = {type = :log}},
        y = {:L1_miss_percent, title = "L1 cache miss [%]"},
        color = {:nthreads, type = :nominal},
    )
    @vlplot(
        mark = {:line, point = true},
        x = {:total_MiB, scale = {type = :log}},
        y = {:LL_miss_percent, title = "LL cache miss [%]"},
        color = {:nthreads, type = :nominal},
    )
]
