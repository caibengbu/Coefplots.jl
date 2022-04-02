module Coefplots
    using StatsModels
    using PGFPlotsX
    using Printf
    using DataStructures
    import FixedEffectModels: FixedEffectModel
    import GLFixedEffectModels: GLFixedEffectModel
    

    include("color.jl")
    include("preamble.jl")
    include("options.jl")
    include("pgfplot.jl")
    include("singlecoefplot.jl")
    include("coefplot.jl")
    include("multicoefplot.jl")
    include("parse.jl")
    include("plot.jl")

    export plot, setxtitle!, setytitle!, setname!, includenote!, equidist!, setlegends!
end