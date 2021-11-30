module TestAccessors

using Test
using ..TestParsing: load_sample

function test_default()
    perf = load_sample("default")

    @test perf.context_switches == 124
    @test perf.cpu_migrations == 0
    @test perf.page_faults == 92541
    @test perf.cycles == 3410157225
    @test perf.stalled_cycles_frontend == 74012542
    @test perf.stalled_cycles_backend == 1498764411
    @test perf.instructions == 5107038786
    @test perf.instructions_per_cycle ≈ 1.5 rtol = 0.005
    @test perf.stalled_cycles_per_instructions ≈ 0.29 atol = 0.005

    @test perf.ratio.stalled_cycles_frontend == 74012542 / 3410157225
    @test perf.ratio.stalled_cycles_backend == 1498764411 / 3410157225
end

function test_d1_with_llc()
    perf = load_sample("d1-with-llc")

    @test perf.branches == 402774448
    @test perf.branch_misses == 6375125
    @test perf.l1_dcache_loads == 650213241
    @test perf.l1_dcache_load_misses == 19264237
    @test perf.l1_icache_loads === nothing
    @test perf.l1_icache_load_misses === nothing
    @test perf.llc_loads == 2029190
    @test perf.llc_load_misses == 1158158

    @test perf.ratio.branch_misses == 6375125 / 402774448
    @test perf.ratio.l1_dcache_load_misses == 19264237 / 650213241
    @test perf.ratio.l1_icache_load_misses === nothing
    @test perf.ratio.llc_load_misses == 1158158 / 2029190

    @test perf.percent.branch_misses == 6375125 / 402774448 * 100
    @test perf.percent.l1_dcache_load_misses == 19264237 / 650213241 * 100
    @test perf.percent.l1_icache_load_misses === nothing
    @test perf.percent.llc_load_misses == 1158158 / 2029190 * 100
end

end  # module
