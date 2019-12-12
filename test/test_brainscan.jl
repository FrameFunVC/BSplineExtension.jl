
using BSplineExtension, Test
@testset "Brainscan" begin
    P = BrainPlatform(NdCDBSplinePlatform((1,1,1)))
    g = sampling_grid(P,(1,1,1))
    L = size(supergrid(g))
    N = div.(L,2)
    dict1 = dictionary(P,N)
    S = solver(P,N;L=L,threshold=1e-1)
    @test Base.summarysize(S)/(1<<30) < 2.5
    b = brainrhs()
    c = S*b
    b_ref = AZ_A(P,N)*c
    @test norm(b-b_ref,Inf) <.57
end
