# The maximum length to solve an HCoset = 12
const MAX_LENGTH_HCOSET = 12

# Get an HCoset sequence that solve an HCoset
function solve(coset::HCoset)
    dist = PHASE1_TABLE[coset]
    seq = FaceTurn[]
    if _solve_hcoset_recur(coset, dist, nothing, seq)
        return seq
    end
    # Should always return a solution
    error("Expected a solution. Something was wrong.")
end

# Depth-first search subroutine to solve an HCoset.
# Return true if there is a sequence, false if not.
function _solve_hcoset_recur(coset::HCoset, togo::Integer, last_move::Union{Nothing,FaceTurn}, seq::Vector{FaceTurn})
    # If the distance does not match PHASE1_TABLE[hc], this position is on the wrong track
    (PHASE1_TABLE[coset] > togo) && return false
    # If we found the identity, we're done
    (coset == HCoset()) && return true

    # "nothing" indicates that this is the first move
    next_moves = next_cs_faceturn(last_move)

    # Branch for each move in the canon sequence
    for move in next_moves
        new_coset = move * coset
        if _solve_hcoset_recur(new_coset, togo - 1, move, seq)
            # If we found a solution, add the current move to seq and break the loop
            push!(seq, move)
            return true
        end
    end

    # No solution in this branch
    return false
end

