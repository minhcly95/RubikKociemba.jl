@testset "Phase 1 Solve" begin
    for cube in rand(Cube, 100)
        coset = HCoset(cube)
        dist = distance(coset)
        seq = solve(coset)
        coset2 = seq * coset
        cube2 = seq * cube
        @test length(seq) == dist
        @test HCoset(cube2) == coset2 == HCoset()
    end
end
