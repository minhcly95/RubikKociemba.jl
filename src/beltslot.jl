N_BELTSLOTS = 495      # 495 = 12C4

# Represent which edges are in the belt slots (middle layer)
RubikCore.@define_int_struct(BeltSlot, UInt16, N_BELTSLOTS)

BeltSlot() = @inbounds BeltSlot(1)

# Expand/compress to bit version
function _make_beltslot_codec()
    compress = zeros(UInt16, 1 << 12 - 1)
    expand = zeros(UInt16, N_BELTSLOTS)
    current = 1
    for i in 1:(1<<12-1)
        (count_ones(i) == 4) || continue
        rotated = (i >> 8) | ((i & 0xff) << 4)
        compress[rotated] = current             # 12-bit lookup
        compress[rotated & 0x7ff] = current     # 11-bit lookup
        expand[current] = rotated
        current += 1
    end
    @assert(current == N_BELTSLOTS + 1)
    return compress, expand
end
const _BELTSLOT_COMPRESS, _BELTSLOT_EXPAND = _make_beltslot_codec()

# Construct from a Cube
function BeltSlot(c::Cube)
    s = 0
    for i in N_EDGES-1:-1:1
        s = 2s + (perm(c.edges[i]) - 1) & 0b100
    end
    return @inbounds BeltSlot(@inbounds _BELTSLOT_COMPRESS[s >> 2])
end

# Create a Cube with this BeltSlot (keep the ori intact, destroy the perm)
function RubikCore.Cube(slot::BeltSlot, seed::Cube=Cube())
    e = MVector{N_EDGES, Edge}(undef)
    nextbelt = 5
    nextupdown = 1
    ep_val = @inbounds _BELTSLOT_EXPAND[Int(slot)]
    for i = 1:N_EDGES
        o = ori(@inbounds(seed.edges[i]))
        if ep_val & 1 > 0
            e[i] = @inbounds Edge(nextbelt, o)
            nextbelt += 1
        else
            e[i] = @inbounds Edge(nextupdown, o)
            nextupdown += 1
            (nextupdown == 5) && (nextupdown = 9)
        end
        ep_val >>= 1
    end
    return @inbounds Cube(seed.center, Tuple(e), seed.corners)
end

# Only premove is allowed
Base.:*(m::AbstractMove, slot::BeltSlot) = BeltSlot(Cube(m) * Cube(slot))

# Results for FaceTurn are cached
const _BELTSLOT_PREMOVE = Tuple(Tuple(Move(ft) * BeltSlot(slot) for ft in ALL_FACETURNS) for slot in 1:N_BELTSLOTS)
Base.:*(ft::FaceTurn, slot::BeltSlot) = @inbounds _BELTSLOT_PREMOVE[Int(slot)][Int(ft)]
