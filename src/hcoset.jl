# Represent a pre-coset (right-coset) of the H group
struct HCoset
    cornerori::CornerOri
    edgeori::EdgeOri
    midslot::EdgeSlot
end

# Identity
const _IDENTITY_HCOSET = HCoset(CornerOri(), EdgeOri(), EdgeSlot(5,6,7,8))
HCoset() = _IDENTITY_HCOSET

# Construct from a Cube
HCoset(c::Cube) = HCoset(CornerOri(c), EdgeOri(c), EdgeSlot(c, :mid))

# Create a Cube with this HCoset
function RubikCore.Cube(coset::HCoset, seed::Cube=Cube())
    seed = Cube(coset.cornerori, seed)
    seed = Cube(coset.edgeori, seed)
    up, down = opposite(coset.midslot)
    seed = Cube(up, coset.midslot, down, Perm4(), Perm4(), Perm4(), seed)
    return seed
end

# Only premove is allowed
Base.:*(m::AbstractMove, coset::HCoset) = HCoset(Cube(m) * Cube(coset))
Base.:*(ft::FaceTurn, coset::HCoset) = HCoset(ft * coset.cornerori, ft * coset.edgeori, ft * coset.midslot)

function Base.:*(ms::AbstractVector{<:AbstractMove}, coset::HCoset)
    for m in Iterators.reverse(ms)
        coset = m * coset
    end
    return coset
end
