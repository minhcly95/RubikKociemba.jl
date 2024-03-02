@testset "Solve" begin
    @testset "HCoset" begin
        @test isempty(solve(HCoset()))

        for coset in rand(HCoset, 100)
            seq = solve(coset)
            @test seq * coset == HCoset()
            @test PHASE1_TABLE[coset] == length(seq)
        end
    end

    @testset "HCube" begin
        @test isempty(solve(HCube()))

        for hc in rand(HCube, 100)
            seq = solve(hc)
            @test hc * seq == HCube()
            @test PHASE2_TABLE[hc] <= length(seq)
        end
    end

    # The most important test of all
    @testset "General Cube" begin
        @test isempty(solve(Cube()))

        for cube in rand(Cube, 1000)
            seq = solve(cube)
            @test normalize(cube * seq) == Cube()
        end
    end
end
