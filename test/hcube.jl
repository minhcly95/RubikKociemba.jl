@testset "HCube" begin
    @testset "Identity" begin
        @test HCube(Cube()) == HCube()
    end

    @testset "Conversion" begin
        for hc in rand(HCube, 100)
            @test HCube(Cube(hc)) == hc
        end
    end
end
