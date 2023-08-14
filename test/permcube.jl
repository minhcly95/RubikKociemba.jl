@testset "PermCube" begin
    @testset "Conversion" begin
        for cube in rand(Cube, 100)
            pcube = PermCube(cube)
            cube2 = Cube(pcube)
            @test PermCube(cube2) == pcube
        end
    end

    @testset "Sequence premul" begin
        for cube in rand(Cube, 100)
            seq = rand(FaceTurn, 50)
            @test PermCube(seq * cube) == seq * PermCube(cube)
        end
    end
end

@testset "HCoset + PermCube" begin
    for cube in rand(Cube, 100)
        cube = normalize(cube)

        coset = HCoset(cube)
        pcube = PermCube(cube)

        seq = rand(FaceTurn, 50)
        coset2 = seq * coset
        pcube2 = seq * pcube
        cube2 = Cube(pcube2, Cube(coset2))

        @test cube2 == seq * cube
    end
end
