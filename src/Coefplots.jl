module Coefplots
    using StatsModels
    using PGFPlotsX
    import FixedEffectModels: FixedEffectModel
    import GLFixedEffectModels: GLFixedEffectModel

    include("preamble.jl")
    include("pgfplot.jl")
    include("parse.jl")
    include("coefplot.jl")
    

    export coefplot
end