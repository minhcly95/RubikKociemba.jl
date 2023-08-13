# Represent a pre-coset (right-coset) of the H group
struct HCoset
    corner_ori::CornerOri
    edge_ori::EdgeOri
    belt_slot::BeltSlot
end

# Construct from a Cube
HCoset(c::Cube) = HCoset(CornerOri(c), EdgeOri(c), BeltSlot(c))

# Create a Cube with this HCoset
function RubikCore.Cube(coset::HCoset, seed::Cube=Cube())
    seed = Cube(coset.corner_ori, seed)
    seed = Cube(coset.edge_ori, seed)
    seed = Cube(coset.belt_slot, seed)
    return seed
end

# Only premove is allowed
Base.:*(m::AbstractMove, coset::HCoset) = HCoset(Cube(m) * Cube(coset))
Base.:*(ft::FaceTurn, coset::HCoset) = HCoset(ft * coset.corner_ori, ft * coset.edge_ori, ft * coset.belt_slot)

function Base.:*(ms::AbstractVector{<:AbstractMove}, coset::HCoset)
    for m in Iterators.reverse(ms)
        coset = m * coset
    end
    return coset
end
