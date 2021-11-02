function preprocess_natural_comment(str)
    output = IOBuffer()
    input = IOBuffer(str)
    while !eof(input)
        ln = readline(input; keep = true)

        # Always treat indented comments as in-code comments
        m = match(r"^( +)# (.*)"s, ln)
        if m !== nothing
            print(output, m[1], "## ", m[2])
            continue
        end

        print(output, ln)
    end
    return String(take!(output))
end
