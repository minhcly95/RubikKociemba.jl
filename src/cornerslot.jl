const N_CORNERSLOTS = 70        # 70 = 8C4

# Represent which corners are in a layer
RubikCore.@define_int_struct(CornerSlot, UInt8, N_CORNERSLOTS)

# Expand/compress to bit version
function _make_cornerslot_codec()
    compress = zeros(UInt8, 1 << 8 - 1)
    expand = zeros(UInt8, N_CORNERSLOTS)
    current = 1
    for i in 1:(1<<8-1)
        (count_ones(i) == 4) || continue
        compress[i] = current           # 8-bit lookup
        compress[i & 0x7f] = current    # 7-bit lookup
        expand[current] = i
        current += 1
    end
    @assert(current == N_CORNERSLOTS + 1)
    return Tuple(compress), Tuple(expand)
end
const _CORNERSLOT_COMPRESS, _CORNERSLOT_EXPAND = _make_cornerslot_codec()

Base.@propagate_inbounds function CornerSlot(a::Integer, b::Integer, c::Integer, d::Integer)
    @boundscheck begin
        @_check_slot_value(a, N_CORNERS)
        @_check_slot_value(b, N_CORNERS)
        @_check_slot_value(c, N_CORNERS)
        @_check_slot_value(d, N_CORNERS)
        @_check_duplicate_slot(a, b, c, d)
    end
    s = (1 << (a-1)) | (1 << (b-1)) | (1 << (c-1)) | (1 << (d-1))
    return @inbounds CornerSlot(@inbounds _CORNERSLOT_COMPRESS[s])
end

function expand(slot::CornerSlot)
    s = @inbounds _CORNERSLOT_EXPAND[Int(slot)]
    exp = MVector{4, Int}(undef)
    current = 1
    for i in 1:N_CORNERS
        if (s & 1) > 0
            @inbounds exp[current] = i
            current += 1
        end
        s >>= 1
    end
    return Tuple(exp)
end

# Construct from a Cube
function CornerSlot(c::Cube, layer=:up)
    local range
    if layer == :up
        range = 1:4
    elseif layer == :down
        range = 5:8
    else
        throw(ArgumentError("unknown layer: $layer. Must be :up or :down"))
    end
    s = 0
    for i in N_CORNERS-1:-1:1
        s = 2s + (perm(c.corners[i]) in range)
    end
    return @inbounds CornerSlot(@inbounds _CORNERSLOT_COMPRESS[s])
end

# Create a Cube with CubeSlot for up and down layers
# Keep the ori intact, destroy the perm within a layer
Base.@propagate_inbounds function RubikCore.Cube(up::CornerSlot, down::CornerSlot, up_perm::Perm4, down_perm::Perm4, seed::Cube=Cube())
    @boundscheck begin
        cover = _CORNERSLOT_EXPAND[Int(up)] | _CORNERSLOT_EXPAND[Int(down)]
        if cover != 0xff
            throw(ArgumentError("union of all CornerSlots does not cover all corners: $(bitstring(cover)[end-7:end])"))
        end
    end

    c = MVector{N_CORNERS, Corner}(undef)
    up_exp = expand(up)
    down_exp = expand(down)
    up_perm_exp = expand(up_perm)
    down_perm_exp = expand(down_perm)

    @inbounds begin
        c[up_exp[1]] = Corner(up_perm_exp[1], ori(seed.corners[up_exp[1]]))
        c[up_exp[2]] = Corner(up_perm_exp[2], ori(seed.corners[up_exp[2]]))
        c[up_exp[3]] = Corner(up_perm_exp[3], ori(seed.corners[up_exp[3]]))
        c[up_exp[4]] = Corner(up_perm_exp[4], ori(seed.corners[up_exp[4]]))
        c[down_exp[1]] = Corner(4 + down_perm_exp[1], ori(seed.corners[down_exp[1]]))
        c[down_exp[2]] = Corner(4 + down_perm_exp[2], ori(seed.corners[down_exp[2]]))
        c[down_exp[3]] = Corner(4 + down_perm_exp[3], ori(seed.corners[down_exp[3]]))
        c[down_exp[4]] = Corner(4 + down_perm_exp[4], ori(seed.corners[down_exp[4]]))
    end

    return @inbounds Cube(seed.center, seed.edges, Tuple(c))
end

# Infer the other layer
function RubikCore.opposite(slot::CornerSlot)
    other_bits = @inbounds ~_CORNERSLOT_EXPAND[Int(slot)] & 0xff
    return @inbounds CornerSlot(_CORNERSLOT_COMPRESS[other_bits])
end

function RubikCore.Cube(up::CornerSlot, up_perm::Perm4, down_perm::Perm4, seed::Cube=Cube())
    down = opposite(up)
    return @inbounds Cube(up, down, up_perm, down_perm, seed)
end

# Extract the perm of a slot
function Perm4(cube::Cube, slot::CornerSlot)
    exp = expand(slot)
    return @inbounds Perm4(
        mod1(perm(cube.corners[exp[1]]), 4),
        mod1(perm(cube.corners[exp[2]]), 4),
        mod1(perm(cube.corners[exp[3]]), 4),
        mod1(perm(cube.corners[exp[4]]), 4)
    )
end

# Permute the slot using a perm
function permute(cube::Cube, slot::CornerSlot, perm::Perm4)
    c = MVector{N_CORNERS, Corner}(cube.corners)
    slot_exp = expand(slot)
    perm_exp = expand(perm)

    @inbounds begin
        base = (RubikCore.perm(c[slot_exp[1]]) - 1) & 0b1100
        c[slot_exp[1]] = Corner(base + perm_exp[1], ori(c[slot_exp[1]]))
        c[slot_exp[2]] = Corner(base + perm_exp[2], ori(c[slot_exp[2]]))
        c[slot_exp[3]] = Corner(base + perm_exp[3], ori(c[slot_exp[3]]))
        c[slot_exp[4]] = Corner(base + perm_exp[4], ori(c[slot_exp[4]]))
    end

    return @inbounds Cube(cube.center, cube.edges, Tuple(c))
end

# Only premove is allowed
Base.:*(m::AbstractMove, slot::CornerSlot) = CornerSlot(Cube(m) * Cube(slot))

# Multiply both slot and perm simultaneously
function Base.:*(m::AbstractMove, (slot, perm)::Tuple{CornerSlot, Perm4})
    cube = Cube(m) * Cube(slot, perm, Perm4())
    slot = CornerSlot(cube)
    return slot, Perm4(cube, slot)
end

# Results for FaceTurn are cached (with the change in perm)
const _CORNERSLOT_PREMOVE = Tuple(Tuple(Move(ft) * (CornerSlot(slot), Perm4()) for ft in ALL_FACETURNS) for slot in 1:N_CORNERSLOTS)

function Base.:*(ft::FaceTurn, (slot, perm)::Tuple{CornerSlot, Perm4})
    slot2, perm2 = @inbounds _CORNERSLOT_PREMOVE[Int(slot)][Int(ft)]
    return slot2, perm2 * perm
end
Base.:*(ft::FaceTurn, slot::CornerSlot) = @inbounds _CORNERSLOT_PREMOVE[Int(slot)][Int(ft)][1]

# Print
Base.show(io::IO, slot::CornerSlot) = print(io, "CornerSlot$(expand(slot))")
