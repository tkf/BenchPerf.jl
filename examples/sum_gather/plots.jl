import BenchPerfConfigSweeps
import DisplayAs
using DataFrames
using VegaLite

sweepresult = BenchPerfConfigSweeps.load(joinpath(@__DIR__, "build"))

df_raw = DataFrame(sweepresult)

let
    global df = select(df_raw, Not(:trial))
    df[:, :time_ns] = map(t -> minimum(t.benchmark).time, df_raw.trial)
    df[:, :evals] = map(t -> t.benchmark.params.evals, df_raw.trial)
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

resultdir = joinpath(@__DIR__, "result")
mkpath(resultdir)

saveresult(; plots...) = saveresult(:png, :svg; plots...)
function saveresult(exts::Symbol...; plots...)
    for (k, v) in plots
        for e in exts
            save(joinpath(resultdir, "$k.$e"), v)
        end
    end
end
nothing  # hide

plt_throughput_cache_miss = @vlplot(
    vconcat = [
        {
            mark = {:line, point = true},
            x = {:MiB, scale = {type = :log}},
            y = {:throughput, title = throughput_unit},
        },
        {
            mark = {:line, point = true},
            x = {:MiB, scale = {type = :log}},
            y = {:L1_miss_percent, title = "L1 cache miss [%]"},
        },
        {
            mark = {:line, point = true},
            x = {:MiB, scale = {type = :log}},
            y = {:LL_miss_percent, title = "LL cache miss [%]"},
        },
    ],
    data = df,
)
saveresult(; plt_throughput_cache_miss)
plt_throughput_cache_miss
plt_throughput_cache_miss |> DisplayAs.PNG
# TODO: include LLC access rate

# ## Tuned `evals`

plt_evals = @vlplot(
    vconcat = [
        {
            layer = [
                {
                    mark = {:line, point = true},
                    encoding = {
                        x = {:n, scale = {type = :log}},
                        y = {:evals, scale = {type = :log}},
                    },
                },
                {
                    # A vertical line above which (`n >=`) benchmarks are not
                    # tuned.
                    mark = :rule,
                    encoding = {x = {datum = 2^15}},
                },
            ],
        },
        {
            encoding = {x = {:MiB, scale = {type = :log}}},
            layer = [
                {
                    mark = {:line, point = true},
                    encoding = {y = {:evals, scale = {type = :log}}},
                },
                {
                    mark = {:line, color = "#85C5A6"},
                    y = {
                        :throughput,
                        title = throughput_unit,
                        axis = {titleColor = "#85C5A6"},
                    },
                },
            ],
            resolve = {scale = {y = :independent}},
        },
    ],
    data = df,
)
saveresult(; plt_evals)
plt_evals
plt_evals |> DisplayAs.PNG
#-

plt_throughput_cache_miss  #src
