module Data

using GridArrays
using GridArrays: MaskedGrid
using DomainSets: WrappedDomain

COUNTRIES = [:BE,:NL,:BENELUX]
default_country = :BENELUX
include("data/code.jl")

function countrygrid(country=default_country; T=(1.,1.))
    data = get_datamatrix(country)'
    mask = .!(isnan.(data))
    extensionmask = falses(round.(Int,T.*size(mask)))
    copyto!(extensionmask,CartesianIndices(size(mask)), mask, CartesianIndices(size(mask)))
    g = ProductGrid(map(x->PeriodicEquispacedGrid(x,0,1),size(extensionmask))...)
    MaskedGrid(g, extensionmask, WrappedDomain(g))
end

function countryrhs_full(country=default_country;opts...)
    mask = countrygrid(country;opts...).mask
    data = get_datamatrix(country)'

    b = NaN*zeros(eltype(data),size(mask))
    b[mask] .= data[.!(isnan.(data))]
    b
end

function countryrhs(country=default_country;opts...)
    mask = countrygrid(country;opts...).mask
    data = get_datamatrix(country)'
    Array(data[.!(isnan.(data))])
end


end
