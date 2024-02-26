# Number of corner permutations = 8!
const N_CORNERPERMS = N_PERMS_8

# CornerPerm: represents the index of the corner permutation
@int_struct struct CornerPerm
    N_CORNERPERMS::UInt16
end

# Get the CornerPerm of a Cube
function CornerPerm(c::Cube)
    perm = corner_perm(c)
    return @inbounds CornerPerm(lehmer_code(perm))
end

# Identity CornerPerm
CornerPerm() = @inbounds CornerPerm(1)
Base.one(::Type{CornerPerm}) = CornerPerm()
Base.one(::CornerPerm) = CornerPerm()

# Make a Cube from CornerPerm
# Note: not performance critical
const _CORNER_SIDE_GROUPING = SPerm{24,UInt8}(1:3:24..., 2:3:24..., 3:3:24...)
const _CORNER_GROUP_SHIFT = SPerm{24,UInt8}(9:24..., 1:8...)

function RubikCore.Cube(cperm::CornerPerm; seed::Cube=Cube())
    perm = LEHMER_TO_PERM_8[cperm]
    # We apply the given perm to 3 groups: low group 1:8, mid group 9:16, and high group 17:24.
    # The low group represents the 1st side of every corner.
    # Similarly, the mid and high group represents the 2nd and 3rd sides.
    low_perm = SPerm{24,UInt8}(perm)
    mid_perm = conj(low_perm, _CORNER_GROUP_SHIFT)
    high_perm = conj(mid_perm, _CORNER_GROUP_SHIFT)
    # Then, we combine them by multiplication (they are disjoint)
    combined = low_perm * mid_perm * high_perm
    # Finally, we group {i, i+8, i+16} into 1 corner.
    # Note that the perm is applied to i, i+8, and i+16 in the same way.
    # The result is a permutation of corners in the default orientation.
    regrouped = conj(combined, _CORNER_SIDE_GROUPING)
    return Cube(seed.center, seed.edges, CornerState(regrouped))
end

# Not all moves are valid for HCube.
# Only HTurn multiplication is allowed.
const CORNERPERM_MUL = Tuple(Tuple(CornerPerm(Cube(cp) * Cube(ht)) for ht in ALL_HTURNS) for cp in instances(CornerPerm))
Base.:*(cp::CornerPerm, ht::HTurn) = @inbounds CORNERPERM_MUL[cp][ht]

# HCube is a subgroup, so multiplication and inversion are also possible
function Base.:*(a::CornerPerm, b::CornerPerm)
    aperm = @inbounds LEHMER_TO_PERM_8[a]
    bperm = @inbounds LEHMER_TO_PERM_8[b]
    cperm = aperm * bperm
    return @inbounds CornerPerm(lehmer_code(cperm))
end

function Base.inv(a::CornerPerm)
    aperm = @inbounds LEHMER_TO_PERM_8[a]
    cperm = inv(aperm)
    return @inbounds CornerPerm(lehmer_code(cperm))
end

