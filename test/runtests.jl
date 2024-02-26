using RubikKociemba
using RubikCore, RubikCore.Literals
using Test

import RubikKociemba: ALL_HTURNS

@testset "RubikKociemba.jl" begin
    include("hcoset.jl")
    include("hcube.jl")
end
