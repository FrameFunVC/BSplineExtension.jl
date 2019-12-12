module Benelux


using Reexport

include("Data.jl")
using .Data
using .Data: COUNTRIES
export COUNTRIES
include("CountryPlatforms.jl")
@reexport using .CountryPlatforms

end
