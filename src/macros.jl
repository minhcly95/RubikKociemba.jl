macro _check_slot_value(val, max_slot)
    val = esc(val)
    max_slot = esc(max_slot)
    return quote
        (1 .<= $val .<= $max_slot) || throw(ArgumentError("invalid slot: $($val). Must be within 1:$($max_slot)"))
    end
end

macro _check_duplicate_slot(a, b, c, d)
    a, b, c, d = esc.((a, b, c, d))
    return quote
        ($a == $b || $a == $c || $a == $d || $b == $c || $b == $d || $c == $d) && throw(ArgumentError("duplicated slot"))
    end
end
