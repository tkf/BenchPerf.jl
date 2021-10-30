import BenchPerfConfigSweeps
using DataFrames
using VegaLite

sweepresult = BenchPerfConfigSweeps.load(joinpath(@__DIR__, "build"))

df_raw = DataFrame(sweepresult)

let
    global df = select(df_raw, Not(:trial))
    df[:, :time_ns] = map(t -> minimum(t.benchmark).time, df_raw.trial)
    df[:, :L1_miss_percent] = map(df_raw.trial) do t
        t.perf["L1-dcache-load-misses"] / t.perf["L1-dcache-loads"] * 100
    end
    df[:, :LL_miss_percent] = map(df_raw.trial) do t
        get(t.perf, "LLC-load-misses", missing) / get(t.perf, "LLC-loads", missing) * 100
    end
    bytes = df.n .* 2 * sizeof(Int)
    global throughput_unit = "GiB/sec"
    df[:, :throughput] = bytes ./ 2^30 ./ (df.time_ns / 1e9)
    df[:, :MiB] = bytes ./ 2^20
    df[:, :total_MiB] = bytes ./ 2^20
    df
end

df |> [
    @vlplot(
        mark = {:line, point = true},
        x = {:MiB, scale = {type = :log}},
        y = {:throughput, title = throughput_unit},
    )
    @vlplot(
        mark = {:line, point = true},
        x = {:MiB, scale = {type = :log}},
        y = {:L1_miss_percent, title = "L1 cache miss [%]"},
    )
    @vlplot(
        mark = {:line, point = true},
        x = {:MiB, scale = {type = :log}},
        y = {:LL_miss_percent, title = "LL cache miss [%]"},
    )
]
# TODO: include LLC access rate
