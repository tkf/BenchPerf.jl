import JSON
d = JSON.parsefile(joinpath(@__DIR__, "build/result-1-perf.json"))

d["group"]["n=64"]

using BenchPerf
p = BenchPerf.Internal.from_json(d["group"]["n=64"])

print(p.output)

using PrettyTables
pretty_table(p)

using BenchPerfTests
t = BenchPerfTests.TestParsing.load_samples()["d2"]
pretty_table(t)
