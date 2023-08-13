@testset "HCoset" begin
    @testset "Conversion" begin
        for coset in rand(HCoset, 100)
            @test HCoset(Cube(coset, rand(Cube))) == coset
        end
    end

    @testset "Sequence premul" begin
        for _ in 1:100
            cube = rand(Cube)
            seq = rand(FaceTurn, 50)
            @test HCoset(seq * cube) == seq * HCoset(cube)
        end
    end
end
