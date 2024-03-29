module RubikKociemba

using RubikCore
using FastPerms
using Random
using Pkg.Artifacts

import RubikCore:
    @int_struct, IntStruct,
    N_EDGES, N_CORNERS, ALL_FACETURNS, ALL_SYMMS,
    CornerState, EdgeState,
    edge_ori, corner_ori, edge_perm, corner_perm,
    flip_edge, twist_corner, swap_edges

include("hturn.jl")
include("hsymm.jl")

include("corner_ori.jl")
include("edge_ori.jl")
include("belt_slot.jl")
include("hcoset.jl")

include("lehmer_code.jl")
include("corner_perm.jl")
include("up_down_perm.jl")
include("belt_perm.jl")
include("hcube.jl")

include("rotate.jl")
include("random.jl")
include("canon.jl")

include("nibble_array.jl")
include("phase1_table.jl")
include("phase2_table.jl")
include("artifacts.jl")

include("canonseq.jl")
include("solve_hcoset.jl")
include("solve_hcube.jl")
include("solve_twophase.jl")

export solve

end
