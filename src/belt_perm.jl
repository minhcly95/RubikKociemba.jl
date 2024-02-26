# Number of permutations of edges in the middle layer = 4!
const N_BELTPERMS = N_PERMS_4

# UpDownPerm: represents the index of a permutation of 8 edges in the top and bottom layers
@int_struct struct BeltPerm
    N_BELTPERMS::UInt8
end

# We use this permutation to swap the belt edges and the top edges.
const BELTUP_REMAP = SPerm{N_EDGES,UInt8}(5, 6, 7, 8, 1, 2, 3, 4, 9, 10, 11, 12)

# Get the BeltPerm of a Cube
BeltPerm(c::Cube) = BeltPerm(edge_perm(c))

function BeltPerm(perm::AbstractPerm{N_EDGES})
    perm = BELTUP_REMAP * perm * BELTUP_REMAP
    truncated = @inbounds SPerm((perm[i] for i in 1:4)...)
    return @inbounds BeltPerm(lehmer_code(truncated))
end

# Identity BeltPerm
BeltPerm() = @inbounds BeltPerm(1)
Base.one(::Type{BeltPerm}) = BeltPerm()
Base.one(::BeltPerm) = BeltPerm()

# Make a Cube from BeltPerm (keep the UpDownPerm intact)
# Note: not performance critical
function RubikCore.Cube(bperm::BeltPerm; seed::Cube=Cube())
    perm = LEHMER_TO_PERM_4[bperm]
    # First, we remap the belt- and up-edges
    remapped = conj(perm, BELTUP_REMAP)
    # We apply the given perm to 2 groups: low group 1:12 and high group 13:24.
    # The low group represents the 1st side of every edge.
    # The high group represents their 2nd sides.
    low_perm = SPerm{24,UInt8}(remapped)
    high_perm = conj(low_perm, _EDGE_GROUP_SHIFT)
    # Then, we combine them by multiplication (they are disjoint)
    combined = low_perm * high_perm
    # Next, we group {i, i+12} into 1 edge.
    # Note that the perm is applied to i and i+12 in the same way.
    # The result is a permutation of edges as pairs of sides.
    regrouped = conj(combined, _EDGE_SIDE_GROUPING)
    # Finally, we insert the up-down perm from the seed
    final = SPerm{24,UInt8}(
        (seed.edges.perm[i] for i in 1:8)...,
        (regrouped[i] for i in 9:16)...,
        (seed.edges.perm[i] for i in 17:24)...
    )
    return Cube(seed.center, EdgeState(final), seed.corners)
end

