using Literate
include("../literate_utlis.jl")

Literate.notebook(
    joinpath(@__DIR__, "report.jl"),
    @__DIR__;
    preprocess = preprocess_natural_comment,
)
