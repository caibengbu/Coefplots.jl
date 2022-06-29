module Coefplots
    using StatsModels
    using PGFPlotsX
    using Printf
    using DataStructures
    import FixedEffectModels: FixedEffectModel
    import GLFixedEffectModels: GLFixedEffectModel
    import Base: issingletontype, parse
    

    include("color.jl")
    include("preamble.jl")
    include("options.jl")
    include("pgfplot.jl")
    include("singlecoefplot.jl")
    include("coefplot.jl")
    include("multicoefplot.jl")
    include("parse.jl")
    include("plot.jl")
    include("esplot.jl")

    export setxtitle!, setytitle!, setname!, includenote!, equidist!, setlegends!, addcomponent!, clearcomponents!, coefrename, coefrename!, transpose!, dot_connect!
    export plot, parse, esplot, esparse, concat
end