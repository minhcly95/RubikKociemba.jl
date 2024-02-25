module RubikKociemba

using RubikCore
using FastPerms
using Random

import RubikCore:
    @int_struct,
    N_EDGES, N_CORNERS,
    CornerState, EdgeState,
    edge_ori, corner_ori, edge_perm, corner_perm,
    flip_edge, twist_corner, swap_edges

include("corner_ori.jl")
include("edge_ori.jl")
include("belt_slot.jl")

include("hcoset.jl")

include("random.jl")

end
