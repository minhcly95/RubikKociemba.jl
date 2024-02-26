@testset "HCoset" begin
    @testset "Identity" begin
        @test HCoset(Cube()) == HCoset()
    end

    @testset "Invariant under HTurn" begin
        for cube in rand(Cube, 100)
            coset = HCoset(cube)
            for m in ALL_HTURNS
                @test HCoset(cube * m) == coset
            end
        end
    end

    @testset "Conversion" begin
        for coset in rand(HCoset, 100)
            @test HCoset(Cube(coset; seed=rand(Cube))) == coset
        end
    end

    @testset "Sequence left multiplication" begin
        for _ in 1:100
            cube = rand(Cube)
            seq = rand(FaceTurn, 50)
            @test HCoset(seq * cube) == seq * HCoset(cube)
        end
    end
end
