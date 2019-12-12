module BrainPlatforms

using FrameFun.Platforms, GridArrays, ...SparseAZ, FrameFun.ExtensionFrames, FrameFun.BasisFunctions,
    DomainSets, ..BrainScanGrids, FrameFunTranslates
using DomainSets: WrappedDomain
import FrameFun.Platforms: platform, SolverStyle, SamplingStyle, measure, unsafe_dictionary, dualdictionary, correctparamformat
import FrameFun.FrameFunInterface: platform_grid
import FrameFun.ExtensionFrames: support


export BrainPlatform
struct BrainPlatform <: FramePlatform
    basisplatform::Platform
    grid::AbstractGrid
    support::Domain
    opts::Base.Iterators.Pairs
    function BrainPlatform(basisplatform::Platform;supportgrid=nothing,domain=nothing,opts...)
        if supportgrid!=nothing || domain!=nothing
            @warn "brain grid uses a default domain and supportgrid"
        end
        grid = braingrid(;domain=support(dictionary(basisplatform,(1,1,1))), opts...)
        new(basisplatform, grid, WrappedDomain(grid), opts)
    end
end

support(platform::BrainPlatform) =
    error("better not to use the support of a BrainPlatform")
platform_grid(ss::GridStyle, platform::BrainPlatform, param; options...) =
    platform.grid
correctparamformat(::BrainPlatform, ::NTuple{3,Int}) = true



SolverStyle(dict::BrainPlatform, ::SamplingStyle) = SparseAZStyle()

SamplingStyle(p::BrainPlatform) = GridStyle()

unsafe_dictionary(p::BrainPlatform, n) =
    extensionframe(p.support, dictionary(p.basisplatform, n))

measure(platform::BrainPlatform) =
    discretemeasure(platform.grid)

dualdictionary(platform::BrainPlatform, param, measure::Measure; options...) =
   extensionframe(dualdictionary(platform.basisplatform, param, supermeasure(measure); options...), platform.support)

import FrameFunTranslates.CompactAZ.CompactFrameFunExtension: sparseAZ_AAZAreductionsolver,
    nonzero_coefficients, sparse_reducedAAZAoperator, ef_sparseAZ_AAZAreductionsolver,
    ef_nonzero_coefficients, ef_sparse_reducedAAZAoperator
for ex in (:sparseAZ_AAZAreductionsolver, :nonzero_coefficients, :sparse_reducedAAZAoperator)
    efex = Meta.parse("ef_"*string(ex))
    @eval begin
        $(ex)(ss::SamplingStyle, platform::BrainPlatform, param, args...; options...) =
           $(efex)(ss, platform, param, platform.basisplatform, args...; options...)
        $(efex)(ss::SamplingStyle, platform::BrainPlatform, param, bplatform::ProductPlatform, args...; options...) =
           $(efex)(ss, platform, param, elements(bplatform), args...; options...)
        $(efex)(ss::SamplingStyle, platform::BrainPlatform, param, bplatform::BasisPlatform, args...; options...) =
           $(efex)(ss, platform, param, tuple(bplatform), args...; options...)
    end
end


end
