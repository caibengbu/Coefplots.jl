module Coefplots
    using StatsModels
    using StatsBase
    using FixedEffectModels
    using Distributions
    using PGFPlotsX
    using DataFrames
    using Parameters: @unpack
    import FixedEffectModels: FixedEffectModel
    import StatsModels: TableRegressionModel

    const MaybeData{T} = Union{T, Missing}

    include("color.jl")
    include("components.jl")
    include("Coefplot.jl")
    include("MultiCoefplot.jl")
    include("parse.jl")
end