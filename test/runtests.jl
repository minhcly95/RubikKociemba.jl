using RubikKociemba
using RubikCore, RubikCore.Literals
using Test

import RubikKociemba: HCoset

const HMOVES = (U, U2, U3, D, D2, D3, F2, R2, B2, L2)

@testset "RubikKociemba.jl" begin
    include("hcoset.jl")
end
