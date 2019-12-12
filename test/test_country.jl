
using BSplineExtension, Test

P = CountryPlatform(NdCDBSplinePlatform((1,1));T=(1,448/447))
g = sampling_grid(P)
L = size(supergrid(g))
N = div.(L,2)
c = solver(P,N;L=L)*rhs(P)
F = Expansion(dictionary(P,N),c)

A = evaluation_operator(basis(dictionary(P,N)),supergrid(g))
R = A*c-BSplineExtension.Benelux.Data.countryrhs_full(;T=(1,448/447))

R[isnan.(R)].=0
@test norm(R,Inf) == norm(AZ_A(P,N)*c-rhs(P),Inf)
@test norm(R,Inf) < 170
