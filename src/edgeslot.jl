const N_EDGESLOTS = 495         # 495 = 12C4

# Represent which edges are in a layer
RubikCore.@define_int_struct(EdgeSlot, UInt16, N_EDGESLOTS)

# Expand/compress to bit version
function _make_edgeslot_codec()
    compress = zeros(UInt16, 1 << 12 - 1)
    expand = zeros(UInt16, N_EDGESLOTS)
    current = 1
    for i in 1:(1<<12-1)
        (count_ones(i) == 4) || continue
        compress[i] = current               # 12-bit lookup
        compress[i & 0x7ff] = current       # 11-bit lookup
        expand[current] = i
        current += 1
    end
    @assert(current == N_EDGESLOTS + 1)
    return Tuple(compress), Tuple(expand)
end
const _EDGESLOT_COMPRESS, _EDGESLOT_EXPAND = _make_edgeslot_codec()

Base.@propagate_inbounds function EdgeSlot(a::Integer, b::Integer, c::Integer, d::Integer)
    @boundscheck begin
        @_check_slot_value(a, N_EDGES)
        @_check_slot_value(b, N_EDGES)
        @_check_slot_value(c, N_EDGES)
        @_check_slot_value(d, N_EDGES)
        @_check_duplicate_slot(a, b, c, d)
    end
    s = (1 << (a-1)) | (1 << (b-1)) | (1 << (c-1)) | (1 << (d-1))
    return @inbounds EdgeSlot(@inbounds _EDGESLOT_COMPRESS[s])
end

function expand(slot::EdgeSlot)
    s = @inbounds _EDGESLOT_EXPAND[Int(slot)]
    exp = MVector{4, Int}(undef)
    current = 1
    for i in 1:N_EDGES
        if (s & 1) > 0
            @inbounds exp[current] = i
            current += 1
        end
        s >>= 1
    end
    return Tuple(exp)
end

# Construct from a Cube
function EdgeSlot(c::Cube, layer=:up)
    local range
    if layer == :up
        range = 1:4
    elseif layer == :mid
        range = 5:8
    elseif layer == :down
        range = 9:12
    else
        throw(ArgumentError("unknown layer: $layer. Must be :up, :mid, or :down"))
    end
    s = 0
    for i in N_EDGES-1:-1:1
        s = 2s + (perm(c.edges[i]) in range)
    end
    return @inbounds EdgeSlot(@inbounds _EDGESLOT_COMPRESS[s])
end

# Create a Cube with EdgeSlot for up, mid, and down layers ans the corresponding perms
Base.@propagate_inbounds function RubikCore.Cube(
    up::EdgeSlot, mid::EdgeSlot, down::EdgeSlot,
    up_perm::Perm4, mid_perm::Perm4, down_perm::Perm4,
    seed::Cube=Cube())

    @boundscheck begin
        cover = _EDGESLOT_EXPAND[Int(up)] | _EDGESLOT_EXPAND[Int(mid)] | _EDGESLOT_EXPAND[Int(down)]
        if cover != 0xfff
            throw(ArgumentError("union of all EdgeSlots does not cover all edges: $(bitstring(cover)[end-11:end])"))
        end
    end

    e = MVector{N_EDGES, Edge}(undef)
    up_exp = expand(up)
    mid_exp = expand(mid)
    down_exp = expand(down)
    up_perm_exp = expand(up_perm)
    mid_perm_exp = expand(mid_perm)
    down_perm_exp = expand(down_perm)

    @inbounds begin
        e[up_exp[1]] = Edge(up_perm_exp[1], ori(seed.edges[up_exp[1]]))
        e[up_exp[2]] = Edge(up_perm_exp[2], ori(seed.edges[up_exp[2]]))
        e[up_exp[3]] = Edge(up_perm_exp[3], ori(seed.edges[up_exp[3]]))
        e[up_exp[4]] = Edge(up_perm_exp[4], ori(seed.edges[up_exp[4]]))
        e[mid_exp[1]] = Edge(4 + mid_perm_exp[1], ori(seed.edges[mid_exp[1]]))
        e[mid_exp[2]] = Edge(4 + mid_perm_exp[2], ori(seed.edges[mid_exp[2]]))
        e[mid_exp[3]] = Edge(4 + mid_perm_exp[3], ori(seed.edges[mid_exp[3]]))
        e[mid_exp[4]] = Edge(4 + mid_perm_exp[4], ori(seed.edges[mid_exp[4]]))
        e[down_exp[1]] = Edge(8 + down_perm_exp[1], ori(seed.edges[down_exp[1]]))
        e[down_exp[2]] = Edge(8 + down_perm_exp[2], ori(seed.edges[down_exp[2]]))
        e[down_exp[3]] = Edge(8 + down_perm_exp[3], ori(seed.edges[down_exp[3]]))
        e[down_exp[4]] = Edge(8 + down_perm_exp[4], ori(seed.edges[down_exp[4]]))
    end

    return @inbounds Cube(seed.center, Tuple(e), seed.corners)
end

# Infer the other layer from 2 layer
Base.@propagate_inbounds function RubikCore.opposite(a::EdgeSlot, b::EdgeSlot)
    @boundscheck begin
        intersect = _EDGESLOT_EXPAND[Int(a)] & _EDGESLOT_EXPAND[Int(b)]
        if intersect != 0
            throw(ArgumentError("the two EdgeSlots intersect: $(bitstring(intersect)[end-11:end])"))
        end
    end
    other_bits = @inbounds ~(_EDGESLOT_EXPAND[Int(a)] | _EDGESLOT_EXPAND[Int(b)]) & 0xfff
    return @inbounds EdgeSlot(_EDGESLOT_COMPRESS[other_bits])
end

# Find 2 arbitrary other layers
function RubikCore.opposite(slot::EdgeSlot)
    rest_bits = @inbounds ~(_EDGESLOT_EXPAND[Int(slot)]) & 0xfff
    i = 4
    for _ in 1:4
        (count_ones(rest_bits >> i) == 4) && break
        i += 1
    end
    high_bits = (rest_bits >> i) << i
    low_bits = rest_bits & ~high_bits
    high = @inbounds EdgeSlot(_EDGESLOT_COMPRESS[high_bits])
    low = @inbounds EdgeSlot(_EDGESLOT_COMPRESS[low_bits])
    return low, high
end

# Extract the perm of a slot
function Perm4(cube::Cube, slot::EdgeSlot)
    exp = expand(slot)
    return @inbounds Perm4(
        mod1(perm(cube.edges[exp[1]]), 4),
        mod1(perm(cube.edges[exp[2]]), 4),
        mod1(perm(cube.edges[exp[3]]), 4),
        mod1(perm(cube.edges[exp[4]]), 4)
    )
end

# Permute the slot using a perm
function permute(cube::Cube, slot::EdgeSlot, perm::Perm4)
    e = MVector{N_EDGES, Edge}(cube.edges)
    slot_exp = expand(slot)
    perm_exp = expand(perm)

    @inbounds begin
        base = (RubikCore.perm(e[slot_exp[1]]) - 1) & 0b1100
        e[slot_exp[1]] = Edge(base + perm_exp[1], ori(e[slot_exp[1]]))
        e[slot_exp[2]] = Edge(base + perm_exp[2], ori(e[slot_exp[2]]))
        e[slot_exp[3]] = Edge(base + perm_exp[3], ori(e[slot_exp[3]]))
        e[slot_exp[4]] = Edge(base + perm_exp[4], ori(e[slot_exp[4]]))
    end

    return @inbounds Cube(cube.center, Tuple(e), cube.corners)
end

# Only premove is allowed
Base.:*(m::AbstractMove, slot::EdgeSlot) = EdgeSlot(Cube(m) * Cube(slot))

# Multiply both slot and perm simultaneously
function Base.:*(m::AbstractMove, (slot, perm)::Tuple{EdgeSlot, Perm4})
    cube = @inbounds Cube(m) * Cube(slot, opposite(slot)..., perm, Perm4(), Perm4())
    slot = EdgeSlot(cube)
    return slot, Perm4(cube, slot)
end

# Results for FaceTurn are cached (with the change in perm)
const _EDGESLOT_PREMOVE = Tuple(Tuple(Move(ft) * (EdgeSlot(slot), Perm4()) for ft in ALL_FACETURNS) for slot in 1:N_EDGESLOTS)

function Base.:*(ft::FaceTurn, (slot, perm)::Tuple{EdgeSlot, Perm4})
    slot2, perm2 = @inbounds _EDGESLOT_PREMOVE[Int(slot)][Int(ft)]
    return slot2, perm2 * perm
end
Base.:*(ft::FaceTurn, slot::EdgeSlot) = @inbounds _EDGESLOT_PREMOVE[Int(slot)][Int(ft)][1]

# Print
Base.show(io::IO, slot::EdgeSlot) = print(io, "EdgeSlot$(expand(slot))")
