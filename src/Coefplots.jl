module Coefplots
    using StatsModels
    using PGFPlotsX
    using Printf
    import FixedEffectModels: FixedEffectModel
    import GLFixedEffectModels: GLFixedEffectModel
    

    include("color.jl")
    include("preamble.jl")
    include("options.jl")
    include("pgfplot.jl")
    include("singlecoefplot.jl")
    include("coefplot.jl")
    include("parse.jl")
    include("plot.jl")

    export plot, setxtitle!, setytitle!, setname!, includenote!, equidist!
end