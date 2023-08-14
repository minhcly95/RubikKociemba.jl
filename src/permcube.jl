# Contain all the permutation of a Cube
struct PermCube
    edge_up::EdgeSlot
    edge_mid::EdgeSlot
    edge_down::EdgeSlot
    edge_up_perm::Perm4
    edge_mid_perm::Perm4
    edge_down_perm::Perm4
    corner_up::CornerSlot
    corner_down::CornerSlot
    corner_up_perm::Perm4
    corner_down_perm::Perm4
end

# Construct from a Cube
function PermCube(cube::Cube)
    edge_up = EdgeSlot(cube, :up)
    edge_mid = EdgeSlot(cube, :mid)
    edge_down = EdgeSlot(cube, :down)
    edge_up_perm = Perm4(cube, edge_up)
    edge_mid_perm = Perm4(cube, edge_mid)
    edge_down_perm = Perm4(cube, edge_down)
    corner_up = CornerSlot(cube, :up)
    corner_down = CornerSlot(cube, :down)
    corner_up_perm = Perm4(cube, corner_up)
    corner_down_perm = Perm4(cube, corner_down)
    return PermCube(
        edge_up, edge_mid, edge_down,
        edge_up_perm, edge_mid_perm, edge_down_perm,
        corner_up, corner_down,
        corner_up_perm, corner_down_perm)
end

# Create a Cube with this PermCube, preserving the orientations
function RubikCore.Cube(pcube::PermCube, seed::Cube=Cube())
    seed = Cube(
        pcube.edge_up, pcube.edge_mid, pcube.edge_down,
        pcube.edge_up_perm, pcube.edge_mid_perm, pcube.edge_down_perm, seed)
    seed = Cube(
        pcube.corner_up, pcube.corner_down,
        pcube.corner_up_perm, pcube.corner_down_perm, seed)
    return seed
end

# Identity
const _IDENTITY_PERMCUBE = PermCube(Cube())
PermCube() = _IDENTITY_PERMCUBE

# Only premove is allowed
Base.:*(m::AbstractMove, pcube::PermCube) = PermCube(Cube(m) * Cube(pcube))
function Base.:*(ft::FaceTurn, pcube::PermCube)
    edge_up, edge_up_perm = ft * (pcube.edge_up, pcube.edge_up_perm)
    edge_mid, edge_mid_perm = ft * (pcube.edge_mid, pcube.edge_mid_perm)
    edge_down, edge_down_perm = ft * (pcube.edge_down, pcube.edge_down_perm)
    corner_up, corner_up_perm = ft * (pcube.corner_up, pcube.corner_up_perm)
    corner_down, corner_down_perm = ft * (pcube.corner_down, pcube.corner_down_perm)
    return PermCube(
        edge_up, edge_mid, edge_down,
        edge_up_perm, edge_mid_perm, edge_down_perm,
        corner_up, corner_down,
        corner_up_perm, corner_down_perm)
end

function Base.:*(ms::AbstractVector{<:AbstractMove}, pcube::PermCube)
    for m in Iterators.reverse(ms)
        pcube = m * pcube
    end
    return pcube
end
