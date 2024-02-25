# HCoset: represents a left coset of the H group
# The H group is the group generated by the moves {U, D, F2, R2, B2, L2}.
# The group fixes the corner orientations, edge orientations, and the belt slots.
# Thus, we can identify an HCoset by these 3 properties.
struct HCoset
    corner_ori::CornerOri
    edge_ori::EdgeOri
    belt_slot::BeltSlot
end

# Get the HCoset from a Cube
HCoset(c::Cube) = HCoset(CornerOri(c), EdgeOri(c), BeltSlot(c))

# Identity HCoset
HCoset() = HCoset(CornerOri(), EdgeOri(), BeltSlot())
Base.one(::Type{HCoset}) = HCoset()
Base.one(::HCoset) = HCoset()

# Make a Cube from HCoset
# Note: not performance critical
function Cube(coset::HCoset; seed::Cube=Cube())
    # Cube(::BeltSlot) destroys the orientations, so we must call it first
    seed = Cube(coset.belt_slot; seed)
    seed = Cube(coset.edge_ori; seed)
    seed = Cube(coset.corner_ori; seed)
    return seed
end

