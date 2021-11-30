function Base.show(io::IO, ::MIME"text/plain", trial::TrialPerf)
    PrettyTables.pretty_table(io, trial)
end

function Base.show(io::IO, ::MIME"text/plain", trial::TrialResult)
    show(io, MIME"text/plain"(), trial.benchmark)
    println(io)
    lines, columns = displaysize(io)
    lines = max(128, lines)
    show(IOContext(io, :displaysize => (lines, columns)), MIME"text/plain"(), trial.perf)
end
