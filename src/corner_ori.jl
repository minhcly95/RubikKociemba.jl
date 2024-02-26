# Each corner has 3 orientations (not twisted, twisted CW, and twisted CCW).
# The last orientation is completely determined by the previous ones.
using RubikCore: SPerm
const N_CORNERORIS = 3^(N_CORNERS - 1)

# CornerOri: represents the index of the corners' orientations
@int_struct struct CornerOri
    N_CORNERORIS::UInt16
end

# Get the CornerOri of a Cube
function CornerOri(c::Cube)
    cstate = c.corners
    cori = 0
    # Encode the orientations with radix 3
    for i in N_CORNERS-1:-1:1
        twist = @inbounds corner_ori(cstate, i)
        cori = 3 * cori + twist
    end
    return @inbounds CornerOri(cori + 1)
end

# Identity CornerOri
CornerOri() = @inbounds CornerOri(1)
Base.one(::Type{CornerOri}) = CornerOri()
Base.one(::CornerOri) = CornerOri()

# Make a Cube from CornerOri (without changing the permutation)
# Note: not performance critical
function RubikCore.Cube(cori::CornerOri; seed::Cube=Cube())
    cstate = seed.corners
    co = Int(cori) - 1

    # Set the orientations of the first 7 corners
    parity = 0
    for i in 1:N_CORNERS-1
        ori = co % 3
        co = fld(co, 3)
        parity += ori
        cstate = _set_corner_ori(cstate, i, ori)
    end

    # Infer the last one using parity
    cstate = _set_corner_ori(cstate, N_CORNERS, -parity)

    return Cube(seed.center, seed.edges, cstate)
end

_set_corner_ori(cstate, i, ori) = @inbounds twist_corner(cstate, i, ori - cstate.perm[3i])

# Only left multiplication is allowed (because we only consider left cosets)
Base.:*(m::AbstractMove, co::CornerOri) = CornerOri(Cube(m) * Cube(co))

# Results for FaceTurn are cached
const CORNERORI_MUL = Tuple(Tuple(Move(ft) * co for ft in ALL_FACETURNS) for co in instances(CornerOri))
Base.:*(ft::FaceTurn, co::CornerOri) = @inbounds CORNERORI_MUL[co][ft]

