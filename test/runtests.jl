
using  Test
@testset "Brainscan" begin
    include("test_brainscan.jl")
end

@testset "Benelux" begin
    include("test_country.jl")
end
