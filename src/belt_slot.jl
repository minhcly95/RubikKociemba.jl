# Number of belt slots (edge slots in the middle layer) = 12 choose 4
const N_BELTSLOTS = binomial(12, 4)

# BeltSlot: represents the combination of edges currently in the middle layer
@int_struct struct BeltSlot
    N_BELTSLOTS::UInt16
end

# Define a numbering of 12C4
function _make_beltslot_tables()
    # We need to map a BeltSlot to a 12-bit mask and vice-versa.
    # There're always 4 bits set in the mask which represent a combination in 12C4.

    # Min and max value of a mask
    MIN_MASK = 0b000000001111
    MAX_MASK = 0b111100000000

    # We can infer the last bit from the first 11 bits.
    # So we also support mapping from 11-bit masks.
    MASK_SHORT = 0b011111111111

    beltslot_to_mask = UInt16[]
    mask_to_beltslot = zeros(UInt16, MAX_MASK)

    for mask in MIN_MASK:MAX_MASK
        # Must have 4 bits set
        (count_ones(mask) == 4) || continue
        # Assign a new number
        push!(beltslot_to_mask, mask)
        ind = length(beltslot_to_mask)
        mask_to_beltslot[mask] = ind
        mask_to_beltslot[mask&MASK_SHORT] = ind
    end

    # Sanity check
    @assert length(beltslot_to_mask) == N_BELTSLOTS

    return beltslot_to_mask, mask_to_beltslot
end
const BELTSLOT_TO_MASK, MASK_TO_BELTSLOT = Tuple.(_make_beltslot_tables())

# Get the BeltSlot of a Cube
function BeltSlot(c::Cube)
    estate = c.edges
    mask = 0
    for i in 1:N_EDGES-1
        ei = @inbounds edge_perm(estate, i)
        # ei in 5:8 iff ((ei-1) & 0b100 != 0)
        ((ei - 1) & 0b100 != 0) && (mask |= 1 << (i - 1))
    end
    return @inbounds BeltSlot(MASK_TO_BELTSLOT[mask])
end

# Cache the identity BeltSlot
const IDENTITY_BELTSLOT = BeltSlot(Cube())
BeltSlot() = IDENTITY_BELTSLOT
Base.one(::Type{BeltSlot}) = BeltSlot()
Base.one(::BeltSlot) = BeltSlot()

# Make a Cube from BeltSlot (orientation is not preserved)
# Note: not performance critical
function Cube(belt::BeltSlot; seed::Cube=Cube())
    estate = seed.edges

    seed_mask = @inbounds BELTSLOT_TO_MASK[BeltSlot(seed)]
    target_mask = @inbounds BELTSLOT_TO_MASK[belt]

    # Determine which edges to be swapped
    swap_mask = seed_mask ⊻ target_mask
    seed_mask &= swap_mask
    target_mask &= swap_mask

    # Swap the edges
    i, j = 1, 1
    while seed_mask != 0
        while seed_mask & 1 == 0
            seed_mask >>= 1
            i += 1
        end
        while target_mask & 1 == 0
            target_mask >>= 1
            j += 1
        end
        estate = @inbounds swap_edges(estate, i, j)

        seed_mask >>= 1
        target_mask >>= 1
        i += 1
        j += 1
    end

    return Cube(seed.center, estate, seed.corners)
end

