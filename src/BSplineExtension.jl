module BSplineExtension
using Reexport
@reexport using CompactTranslatesDict, FrameFun, DomainSets, FrameFunTranslates

# Approximation examples
include("BrainScan/BrainScan.jl")
@reexport using .BrainScan
include("Benelux/Benelux.jl")
@reexport using .Benelux

end
