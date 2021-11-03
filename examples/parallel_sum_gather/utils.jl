nrepeats_from_n(n) =
    if n < 2^22
        2^22 ÷ n
    else
        1
    end
