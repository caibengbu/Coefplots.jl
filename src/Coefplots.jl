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
    include("escape.jl")
    include("components.jl")
    include("coefplot.jl")
    include("multicoefplot.jl")
    include("groupedcoefplot.jl")
    include("groupedmulticoefplot.jl")
    include("parse.jl")
    include("other_utils.jl")

    export to_plot, to_axis, to_picture, color!, rename!
    export Coefplot, MultiCoefplot, GroupedCoefplot, GroupedMultiCoefplot
end