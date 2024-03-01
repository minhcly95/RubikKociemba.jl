@testset "Look-up" begin
    @testset "Phase 1" begin
        @test PHASE1_TABLE[HCoset()] == 0

        for dist in 1:12
            for _ in 1:(10*dist)
                seq = rand(FaceTurn, dist)
                coset = seq * HCoset()
                # The distance must be less than the length of sequence
                @test PHASE1_TABLE[coset] <= dist
            end
        end
    end

    @testset "Phase 2" begin
        @test PHASE2_TABLE[HCube()] == 0

        for dist in 1:15
            for _ in 1:(10*dist)
                seq = rand(HTurn, dist)
                hc = HCube() * seq
                # The distance must be less than the length of sequence
                @test PHASE2_TABLE[hc] <= dist
            end
        end
    end
end
