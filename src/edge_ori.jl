# Each edge has 2 orientations (not flipped, and flipped).
# The last orientation is completely determined by the previous ones.
const N_EDGEORIS = 2^(N_EDGES - 1)

# EdgeOri: represents the index of the edges' orientations
@int_struct struct EdgeOri
    N_EDGEORIS::UInt16
end

# Get the EdgeOri of a Cube
function EdgeOri(c::Cube)
    estate = c.edges
    eori = 0
    # Encode the orientations in binary
    for i in N_EDGES-1:-1:1
        flipped = @inbounds edge_ori(estate, i)
        eori = 2 * eori + flipped
    end
    return @inbounds EdgeOri(eori + 1)
end

# Identity EdgeOri
EdgeOri() = @inbounds EdgeOri(1)
Base.one(::Type{EdgeOri}) = EdgeOri()
Base.one(::EdgeOri) = EdgeOri()

# Make a Cube from EdgeOri (without changing the permutation)
# Note: not performance critical
function Cube(eori::EdgeOri; seed::Cube=Cube())
    estate = seed.edges
    eo = Int(eori) - 1

    # Set the orientations of the first 11 edges
    parity = 0
    for i in 1:N_EDGES-1
        ori = eo & 1
        eo >>= 1
        parity ⊻= ori
        estate = _set_edge_ori(estate, i, ori)
    end

    # Infer the last one using parity
    estate = _set_edge_ori(estate, N_EDGES, parity)

    return Cube(seed.center, estate, seed.corners)
end

_set_edge_ori(estate, i, ori) = @inbounds (ori == (estate.perm[2i] & 1)) ? estate : flip_edge(estate, i)

