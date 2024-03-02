# The maximum length to solve a Cube = 20
const MAX_LENGTH_TWOPHASE = 20
const DEFAULT_TARGET = 20

# This struct holds all the neccesary information of the solver
mutable struct TwoPhaseSolutionContext
    curr_seq::Vector{FaceTurn}
    best_seq::Vector{FaceTurn}
    symm::Symm
    inv::Bool
    target_length::Int
    verbose::Bool
    finished::Bool
end

TwoPhaseSolutionContext(; target_length, verbose) = TwoPhaseSolutionContext(
    FaceTurn[],
    fill(FaceTurn(1), MAX_LENGTH_HCOSET + MAX_LENGTH_HCUBE + 1),    # Dummy best_seq
    Symm(),     # Set later by the solver
    false,      # Set later by the solver
    target_length,
    verbose,
    false       # Set by the solver when target is reached
)

_best_length(context::TwoPhaseSolutionContext) = length(context.best_seq)
_current_depth(context::TwoPhaseSolutionContext) = length(context.curr_seq)
_max_p2_length(context::TwoPhaseSolutionContext) = _best_length(context) - _current_depth(context) - 1

# Push the move to curr_seq
Base.push!(context::TwoPhaseSolutionContext, ft::FaceTurn) = push!(context.curr_seq, ft)
Base.pop!(context::TwoPhaseSolutionContext) = pop!(context.curr_seq)

# Record the new best sequence given a phase 2 sequence (hseq)
function _update_best!(context::TwoPhaseSolutionContext, hseq)
    # Recover the sequence (applying the reverse configuration)
    best_seq = vcat(FaceTurn.(hseq), reverse(context.curr_seq))
    best_seq = (context.symm').(best_seq)
    context.inv && (best_seq = inv(best_seq))
    context.best_seq = best_seq
    # Set the flag if done
    if _best_length(context) <= context.target_length
        context.finished = true
    end
    return context.best_seq
end

# Recursive subroutine
function _solve_twophase_recur(cube::Cube, coset::HCoset, togo::Integer, last_move, context::TwoPhaseSolutionContext)
    # Base case
    if togo == 0
        # Reach an HCube exactly at given depth, solve phase 2
        if isone(coset)
            # We only want to obtain a better solution than context.best_seq
            hseq = solve(HCube(cube), max_length=_max_p2_length(context))
            # Found a better solution
            if !isnothing(hseq)
                _update_best!(context, hseq)
                context.verbose && @info "Found solution of length $(_best_length(context)): $(Move.(context.best_seq))"
            end
        end
        return
    end

    # Recusive step
    togo -= 1
    for ft in next_cs_faceturn(last_move)
        new_coset = ft * coset
        new_dist = PHASE1_TABLE[new_coset]

        # Only continue if both conditions are satisfied:
        # - new_dist <= togo: we are on the right track;
        # - new_dist + togo >= 5: this eliminates the case new_dist == 1 and togo == 2 or 3.
        #   In fact, no coset of dist 1 can reach identity with a *canon* sequence of length 2 or 3.
        if new_dist == togo || (new_dist < togo && new_dist + togo >= 5)
            push!(context, ft)
            _solve_twophase_recur(ft * cube, new_coset, togo, ft, context)
            pop!(context)
        end
        # Exit if target is reached
        (context.finished) && return
    end
end

# Main implementation
function _solve_twophase_main(cube::Cube; target_length::Integer, verbose::Bool)
    # We search in 6 configurations at the same time: 3 symmetries UFR, FRU, and RUF, with their inverses
    confs = [((s, i) for s in [symm"UFR", symm"FRU", symm"RUF"], i in false:true)...]
    conf_cubes = [s' * (i ? cube' : cube) * s for (s, i) in confs]

    # We start from the minimum depth of all configurations
    conf_cosets = HCoset.(conf_cubes)
    min_depth = minimum(PHASE1_TABLE[coset] for coset in conf_cosets)

    # We increase the depth of HCoset gradually
    context = TwoPhaseSolutionContext(; target_length, verbose)
    for d in min_depth:MAX_LENGTH_TWOPHASE
        for (conf, ccube, ccoset) in zip(confs, conf_cubes, conf_cosets)
            # Set current configuration
            context.symm = conf[1]
            context.inv = conf[2]
            context.verbose && @info "At depth $d, symm = $(conf[1]), inv = $(conf[2])"
            # Start the search
            _solve_twophase_recur(ccube, ccoset, d, nothing, context)
            # Exit if target is reached
            if context.finished || d >= _best_length(context)
                return context.best_seq
            end
        end
    end

    # Cannot find a solution (should not happen)
    error("Cannot find a solution for $cube")
end

# Entry point: normalize the cube, then call the main implementation
function solve(cube::Cube; target_length::Integer=DEFAULT_TARGET, verbose::Bool=false)
    center = cube.center
    seq = _solve_twophase_main(normalize(cube); target_length, verbose)
    # Rotate the moves back to the original orientation
    return center.(seq)
end

