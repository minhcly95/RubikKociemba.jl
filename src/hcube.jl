# HCube: represents a position in the H group.
# The H group is the group generated by the moves {U, D, F2, R2, B2, L2}.
# The group fixes the corner orientations, edge orientations, and the belt slots.
# In other words, it only permutes the corners, the up-down edges, and the belt edges separately.
# Thus, we can identify an HCube by these 3 properties.
struct HCube
    corner_perm::CornerPerm
    updown_perm::UpDownPerm
    belt_perm::BeltPerm
end

# Get the HCoset from a Cube
function HCube(c::Cube)
    perm = edge_perm(c)
    return HCube(CornerPerm(c), UpDownPerm(perm), BeltPerm(perm))
end

# Identity HCoset
HCube() = HCube(CornerPerm(), UpDownPerm(), BeltPerm())
Base.one(::Type{HCube}) = HCube()
Base.one(::HCube) = HCube()

# Make a Cube from HCube
# Note: not performance critical
function RubikCore.Cube(hc::HCube)
    # Unlike HCoset, not every cube is an HCube.
    # So we cannot seed it with any random Cube.
    seed = Cube()
    seed = Cube(hc.corner_perm; seed)
    seed = Cube(hc.updown_perm; seed)
    seed = Cube(hc.belt_perm; seed)
    return seed
end

# Not all moves are valid for HCube.
# Only HTurn multiplication is allowed.
Base.:*(hc::HCube, ht::HTurn) = HCube(hc.corner_perm * ht, hc.updown_perm * ht, hc.belt_perm * ht)

function Base.:*(hc::HCube, hts::AbstractVector{HTurn})
    for ht in hts
        hc *= ht
    end
    return hc
end

# HCube is a subgroup, so multiplication and inversion are also possible
# Note: not as performant as Cube, since the primary purpose of HCube is indexing
Base.:*(a::HCube, b::HCube) = HCube(
    a.corner_perm * b.corner_perm,
    a.updown_perm * b.updown_perm,
    a.belt_perm * b.belt_perm
)

Base.inv(hc::HCube) = HCube(inv(hc.corner_perm), inv(hc.updown_perm), inv(hc.belt_perm))
Base.adjoint(hc::HCube) = inv(hc)
