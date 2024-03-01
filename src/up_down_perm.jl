# Number of permutations of edges in top and bottom layers = 8!
const N_UPDOWNPERMS = N_PERMS_8

# UpDownPerm: represents the index of a permutation of 8 edges in the top and bottom layers
@int_struct struct UpDownPerm
    N_UPDOWNPERMS::UInt16
end

# We use this permutation to swap the belt edges and the bottom edges.
const BELTDOWN_REMAP = SPerm{N_EDGES,UInt8}(1, 2, 3, 4, 9, 10, 11, 12, 5, 6, 7, 8)

# Get the UpDownPerm of a Cube
UpDownPerm(c::Cube) = UpDownPerm(edge_perm(c))

function UpDownPerm(perm::AbstractPerm{N_EDGES})
    perm = BELTDOWN_REMAP * perm * BELTDOWN_REMAP
    truncated = @inbounds SPerm((perm[i] for i in 1:8)...)
    return @inbounds UpDownPerm(lehmer_code(truncated))
end

# Identity UpDownPerm
UpDownPerm() = @inbounds UpDownPerm(1)
Base.one(::Type{UpDownPerm}) = UpDownPerm()
Base.one(::UpDownPerm) = UpDownPerm()

# Make a Cube from UpDownPerm (keep the BeltPerm intact)
# Note: not performance critical
const _EDGE_SIDE_GROUPING = SPerm{24,UInt8}(1:2:24..., 2:2:24...)
const _EDGE_GROUP_SHIFT = SPerm{24,UInt8}(13:24..., 1:12...)

function RubikCore.Cube(udperm::UpDownPerm; seed::Cube=Cube())
    perm = LEHMER_TO_PERM_8[udperm]
    # First, we remap the belt- and down-edges
    remapped = conj(perm, BELTDOWN_REMAP)
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
    # Finally, we insert the belt perm from the seed
    final = SPerm{24,UInt8}(
        (regrouped[i] for i in 1:8)...,
        (seed.edges.perm[i] for i in 9:16)...,
        (regrouped[i] for i in 17:24)...
    )
    return Cube(seed.center, EdgeState(final), seed.corners)
end

# Not all moves are valid for HCube.
# Only HTurn multiplication is allowed.
const UPDOWNPERM_MUL = Tuple(Tuple(UpDownPerm(Cube(udp) * Cube(ht)) for ht in ALL_HTURNS) for udp in instances(UpDownPerm))
Base.:*(udp::UpDownPerm, ht::HTurn) = @inbounds UPDOWNPERM_MUL[udp][ht]

# HCube is a subgroup, so multiplication and inversion are also possible
function Base.:*(a::UpDownPerm, b::UpDownPerm)
    aperm = @inbounds LEHMER_TO_PERM_8[a]
    bperm = @inbounds LEHMER_TO_PERM_8[b]
    cperm = aperm * bperm
    return @inbounds UpDownPerm(lehmer_code(cperm))
end

function Base.inv(a::UpDownPerm)
    aperm = @inbounds LEHMER_TO_PERM_8[a]
    cperm = inv(aperm)
    return @inbounds UpDownPerm(lehmer_code(cperm))
end

# Evenness
Base.iseven(udp::UpDownPerm) = @inbounds iseven(LEHMER_TO_PERM_8[udp])
Base.isodd(udp::UpDownPerm) = @inbounds isodd(LEHMER_TO_PERM_8[udp])

