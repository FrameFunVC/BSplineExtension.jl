module BrainScanGrids
using GridArrays, DomainSets, FrameFun.BasisFunctions, MAT, BSON
using GridArrays: MaskedGrid
using DomainSets: WrappedDomain


import FrameFun.BasisFunctions: grid
grid(A::AbstractArray{T,N};domain=UnitInterval{T}()^N, supportgrid=nothing, opts...) where{T,N} =
    supportgrid==nothing ?
        grid(A, domain; opts...) :
        grid(A, supportgrid; opts...)

grid(A::AbstractArray, domain::Domain;periodic=true, opts...) =
    periodic ?
        grid(A, ProductGrid(map(PeriodicEquispacedGrid, size(A), infimum(domain), supremum(domain))...); opts...) :
        grid(A, ProductGrid(map(EquispacedGrid, size(A), infimum(domain), supremum(domain))...); opts...)

grid(A::AbstractArray, g::AbstractGrid; isin=k->!isnan(k), opts...) =
    MaskedGrid(g, convert(BitArray, isin.(A) ), WrappedDomain(g))

function datacheck(path)
    if !isfile(path)
        error("The data $(path) is not available. Contact the authors of this package if you would like to use this data.")
    end
end

function braindata()
    datacheck(joinpath(splitdir(@__FILE__(),)[1], "data", "mridata.mat"))
    file = matopen(joinpath(splitdir(@__FILE__(),)[1], "data", "mridata.mat"))
    d = read(file, "mridata")
    close(file)
    d
end

export braingrid
function braingrid(;domain=UnitInterval{Float64}()^3,opts...)
    PG = ProductGrid(map(PeriodicEquispacedGrid, (256,256,54), infimum(domain), supremum(domain))...)
    datacheck(joinpath(splitdir(@__FILE__(),)[1], "data", "test"))
    mask = BSON.load(joinpath(splitdir(@__FILE__())[1],"data","test"))[:mask]
    mask[:,:,1:10] .= 0
    mask[:,:,48:54] .= 0
    MaskedGrid(PG, mask, WrappedDomain(PG))
end

export brainsupport
brainsupport(;opts...) = WrappedDomain(braingrid(;opts...))

end
