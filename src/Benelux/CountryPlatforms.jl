module CountryPlatforms

using FrameFun.Platforms, GridArrays, ...SparseAZ, FrameFun.ExtensionFrames, FrameFun.BasisFunctions,
    DomainSets, FrameFunTranslates
using ..Data: countrygrid, default_country, countryrhs
using DomainSets: WrappedDomain
import FrameFun.Platforms: platform, SolverStyle, SamplingStyle, measure, unsafe_dictionary, dualdictionary, correctparamformat
import FrameFun.FrameFunInterface: platform_grid, sampling_grid
import FrameFun.ExtensionFrames: support

export CountryPlatform
struct CountryPlatform <: FramePlatform
    basisplatform::Platform
    grid::AbstractGrid
    support::Domain
    country
    T
    function CountryPlatform(basisplatform::Platform;country=default_country, T=(1.,1.))
        grid = countrygrid(country, T=T)
        new(basisplatform, grid, WrappedDomain(grid), country, T)
    end
end

support(platform::CountryPlatform) =
    error("better not to use the support of a CountryPlatform")
platform_grid(ss::GridStyle, platform::CountryPlatform, param; options...) =
    platform.grid
correctparamformat(::CountryPlatform, ::NTuple{2,Int}) = true

SolverStyle(dict::CountryPlatform, ::SamplingStyle) = SparseAZStyle()

SamplingStyle(p::CountryPlatform) = GridStyle()

unsafe_dictionary(p::CountryPlatform, n) =
    extensionframe(p.support, unsafe_dictionary(p.basisplatform, n))

measure(platform::CountryPlatform) =
    discretemeasure(platform.grid)

dualdictionary(platform::CountryPlatform, param, measure::Measure; options...) =
   extensionframe(dualdictionary(platform.basisplatform, param, supermeasure(measure); options...), platform.support)
export rhs
rhs(platform::CountryPlatform) =
    countryrhs(platform.country, T=platform.T)
sampling_grid(platform::CountryPlatform) =
    platform.grid

import FrameFunTranslates.CompactAZ.CompactFrameFunExtension: sparseAZ_AAZAreductionsolver,
    nonzero_coefficients, sparse_reducedAAZAoperator, ef_sparseAZ_AAZAreductionsolver,
    ef_nonzero_coefficients, ef_sparse_reducedAAZAoperator
for ex in (:sparseAZ_AAZAreductionsolver, :nonzero_coefficients, :sparse_reducedAAZAoperator)
    efex = Meta.parse("ef_"*string(ex))
    @eval begin
        $(ex)(ss::SamplingStyle, platform::CountryPlatform, param, args...; options...) =
           $(efex)(ss, platform, param, platform.basisplatform, args...; options...)
        $(efex)(ss::SamplingStyle, platform::CountryPlatform, param, bplatform::ProductPlatform, args...; options...) =
           $(efex)(ss, platform, param, elements(bplatform), args...; options...)
        $(efex)(ss::SamplingStyle, platform::CountryPlatform, param, bplatform::BasisPlatform, args...; options...) =
           $(efex)(ss, platform, param, tuple(bplatform), args...; options...)
    end
end


end
