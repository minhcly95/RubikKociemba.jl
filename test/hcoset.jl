@testset "HCoset" begin
    @testset "Preserve under HMove" begin
        for cube in rand(Cube, 100)
            coset = HCoset(cube)
            for m in HMOVES
                @test HCoset(cube * m) == coset
            end
        end
    end

    @testset "Conversion" begin
        for coset in rand(HCoset, 100)
            @test HCoset(Cube(coset; seed=rand(Cube))) == coset
        end
    end
end
