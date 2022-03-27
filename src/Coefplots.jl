module Coefplots
    using StatsModels
    using PGFPlotsX
    import FixedEffectModels: FixedEffectModel
    import GLFixedEffectModels: GLFixedEffectModel

    include("color.jl")
    include("preamble.jl")
    include("options.jl")
    include("singlecoefplot.jl")
    include("coefplot.jl")
    include("parse.jl")
    include("pgfplot.jl")
    include("plot.jl")

    export plot
end