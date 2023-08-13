N_CORNERORIS = 2187      # 2187 = 3^7

# Represent the orientation of all corners
RubikCore.@define_int_struct(CornerOri, UInt16, N_CORNERORIS)

CornerOri() = @inbounds CornerOri(1)

# Construct from a Cube
function CornerOri(c::Cube)
    co = 0
    for i in N_CORNERS-1:-1:1
        co = 3co + ori(c.corners[i]) - 1
    end
    return @inbounds CornerOri(co + 1)
end

# Create a Cube with this CornerOri (keep the perm intact)
function RubikCore.Cube(co::CornerOri, seed::Cube=Cube())
    c = MVector{N_CORNERS, Corner}(undef)
    co_val = Int(co) - 1
    sum_ori = 0
    for i = 1:N_CORNERS-1
        ori = co_val % 3
        co_val = fld(co_val, 3)
        sum_ori += ori
        c[i] = @inbounds Corner(perm(@inbounds(seed.corners[i])), ori + 1)
    end
    c[N_CORNERS] = @inbounds Corner(perm(@inbounds(seed.corners[N_CORNERS])), mod(-sum_ori, 3) + 1)
    return @inbounds Cube(seed.center, seed.edges, Tuple(c))
end

# Only premove is allowed
Base.:*(m::AbstractMove, co::CornerOri) = CornerOri(Cube(m) * Cube(co))

# Results for FaceTurn are cached
const _CORNERORI_PREMOVE = Tuple(Tuple(Move(ft) * CornerOri(co) for ft in ALL_FACETURNS) for co in 1:N_CORNERORIS)
Base.:*(ft::FaceTurn, co::CornerOri) = @inbounds _CORNERORI_PREMOVE[Int(co)][Int(ft)]
