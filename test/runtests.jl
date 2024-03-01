using RubikKociemba
using RubikCore, RubikCore.Literals
using Test

import RubikKociemba:
    ALL_HTURNS, ALL_HSYMMS, CornerOri, CornerPerm, canonicalize_hsymm,
    PHASE1_TABLE, PHASE2_TABLE

@testset "RubikKociemba.jl" begin
    include("hcoset.jl")
    include("hcube.jl")
    include("rotate.jl")
    include("canon.jl")
    include("lookup.jl")
    include("solve.jl")
end
