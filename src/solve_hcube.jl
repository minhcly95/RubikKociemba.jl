# The maximum length to solve an HCube = 18
const MAX_LENGTH_HCUBE = 18

# Get an HTurn sequence that solve an HCube
function solve(hc::HCube; max_length = MAX_LENGTH_HCUBE)
    dist = PHASE2_TABLE[hc]
    seq = HTurn[]
    # Note that PHASE2_TABLE only gives underestimate of the sequence length.
    # In rare cases, this estimate does not match and we need to search for the next depth level.
    for togo in dist:max_length
        if _solve_hcube_recur(hc, togo, nothing, seq)
            return reverse!(seq)
        end
    end
    # Return nothing if there is no solution
    return nothing
end

# Depth-first search subroutine to solve an HCube.
# Return true if there is a sequence, false if not.
function _solve_hcube_recur(hc::HCube, togo::Integer, last_move::Union{Nothing,HTurn}, seq::Vector{HTurn})
    # PHASE2_TABLE[hc] is a lower-bound, so if it's larger than togo, this position has no hope
    (PHASE2_TABLE[hc] > togo) && return false
    # If we found the identity, we're done
    (hc == HCube()) && return true

    # "nothing" indicates that this is the first move
    next_moves = next_cs_hturn(last_move)

    # Branch for each move in the canon sequence
    for move in next_moves
        new_hc = hc * move
        if _solve_hcube_recur(new_hc, togo - 1, move, seq)
            # If we found a solution, add the current move to seq and break the loop
            push!(seq, move)
            return true
        end
    end

    # No solution in this branch
    return false
end

