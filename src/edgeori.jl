const N_EDGEORIS = 2048      # 2048 = 2^11

# Represent the orientation of all edges
RubikCore.@define_int_struct(EdgeOri, UInt16, N_EDGEORIS)

EdgeOri() = @inbounds EdgeOri(1)

# Construct from a Cube
function EdgeOri(c::Cube)
    eo = 0
    for i in N_EDGES-1:-1:1
        eo = 2eo + ori(c.edges[i]) - 1
    end
    return @inbounds EdgeOri(eo + 1)
end

# Create a Cube with this EdgeOri (keep the perm intact)
function RubikCore.Cube(eo::EdgeOri, seed::Cube=Cube())
    e = MVector{N_EDGES, Edge}(undef)
    eo_val = Int(eo) - 1
    last_ori = 0
    for i = 1:N_EDGES-1
        ori = eo_val & 0x1
        eo_val >>= 1
        last_ori ⊻= ori
        e[i] = @inbounds Edge(perm(@inbounds(seed.edges[i])), ori + 1)
    end
    e[N_EDGES] = @inbounds Edge(perm(@inbounds(seed.edges[N_EDGES])), last_ori + 1)
    return @inbounds Cube(seed.center, Tuple(e), seed.corners)
end

# Only premove is allowed
Base.:*(m::AbstractMove, eo::EdgeOri) = EdgeOri(Cube(m) * Cube(eo))

# Results for FaceTurn are cached
const _EDGEORI_PREMOVE = Tuple(Tuple(Move(ft) * EdgeOri(eo) for ft in ALL_FACETURNS) for eo in 1:N_EDGEORIS)
Base.:*(ft::FaceTurn, eo::EdgeOri) = @inbounds _EDGEORI_PREMOVE[Int(eo)][Int(ft)]
