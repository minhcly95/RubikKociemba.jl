@testset "Solve" begin
    @testset "HCube" begin
        for hc in rand(HCube, 100)
            seq = solve(hc)
            @test hc * seq == HCube()
            @test PHASE2_TABLE[hc] <= length(seq)
        end
    end
end
