# include("../src/Coefplots.jl")
# using .Coefplots
using Coefplots
using FixedEffectModels
using DataFrames
using Random
using Test

Random.seed!(1234)

N = 100 # 100 individuals
T = 20 # 20 periods
idfe = rand(N)
timefe = rand(T)
event_time = 8 # make the eighth period be the event time
id = repeat(1:N, inner=T) # generate id
is_treated = id .< N/2 # make first half of individuals are treated, last half of indivuduals are controls
time = Float64.(repeat(1:T, outer=N) .- event_time) # generate time
treatment = repeat(rand(N), inner=T) .* is_treated # generate treatment, 0 if obs are controls
idfe = rand(N)
timefe = rand(T)
outcome = treatment .* (time .> 0) + idfe[id] + timefe[Int.(time .+ event_time)] .+ rand(N*T) # generate outcome, treatment only have an effect after event time
#add id FE and time FE, also add a noise.


df = DataFrame(id = id, time = time, outcome = outcome, treatment = treatment)
first(df,10)

rename_rule = ["time: -7.0 & treatment" => "\$\\leq\$-7", 
    "time: -6.0 & treatment" => -6,
    "time: -5.0 & treatment" => -5,
    "time: -4.0 & treatment" => -4,
    "time: -3.0 & treatment" => -3,
    "time: -2.0 & treatment" => -2,
    "time: -1.0 & treatment" => -1,
    "treatment" => 0,
    "time: 1.0 & treatment" => 1,
    "time: 2.0 & treatment" => 2,
    "time: 3.0 & treatment" => 3,
    "time: 4.0 & treatment" => 4,
    "time: 5.0 & treatment" => 5,
    "time: 6.0 & treatment" => 6,
    "time: 7.0 & treatment" => 7,
    "time: 8.0 & treatment" => 8,
    "time: 9.0 & treatment" => 9,
    "time: 10.0 & treatment" => 10,
    "time: 11.0 & treatment" => 11,
    "time: 12.0 & treatment" => "\$\\geq\$12"]


# round result to 4 digit, there are always small errors each time you test.
function round!(c::Coefplot,digits::Int64=4)
    data = c.data
    data.b = round.(data.b; digits=digits)
    data.se = round.(data.se; digits=digits)
    c.data = data;
end

res_pool = reg(df, @formula(outcome ~ time&treatment + treatment); contrasts = Dict(:time => DummyCoding(base=0))); 
pool = Coefplots.parse(res_pool,rename_rule...;keepconnect=true)
pool.title.content = "no FE"
round!(pool)
res_idfe = reg(df, @formula(outcome ~ time&treatment + treatment + fe(id)); contrasts = Dict(:time => DummyCoding(base=0))); 
with_idfe = Coefplots.parse(res_idfe,rename_rule...;keepconnect=true)
with_idfe.title.content = "with id FE"
round!(with_idfe)
res_timefe = reg(df, @formula(outcome ~ time&treatment + treatment + fe(time)); contrasts = Dict(:time => DummyCoding(base=0))); 
with_timefe = Coefplots.parse(res_timefe,rename_rule...;keepconnect=true)
with_timefe.title.content = "with time FE"
round!(with_timefe)
res_both = reg(df, @formula(outcome ~ time&treatment + treatment + fe(time) + fe(id)); contrasts = Dict(:time => DummyCoding(base=0))); 
with_bothfe = Coefplots.parse(res_both,rename_rule...;keepconnect=true)
with_bothfe.title.content = "with id \\& time FE"
round!(with_bothfe)

m = Coefplots.MultiCoefplot(pool, with_idfe, with_timefe, with_bothfe)
m.xticklabel.rotate=45
m.xticklabel.size=6
m.legend.at=(0.02,0.98)
m.legend.anchor=Symbol("north west")
m.legend.size=6
m.note.content="Note: The total number of observation is 2000, with 100 individuals and 20 periods. "*
    "Half of the observations is treated. "*
    "The true coefficient before treatment is 0. "*
    "The true coefficient after treatment is 1. The CI is at 95\\% level."
m.note.captionstyle.size=6
m.xlabel.content = "time relative to event"
m.ylabel.content = "coefficient"
m.title.content = "My example event study plot"
m.width=300
m.height=240

for c in m.data
    c.mark.mark="*"
    c.errorbar.linetype=:solid
    c.errorbar.linewidth=0.5
    c.errormark.mark="none"
end

using PGFPlotsX
zero_level = @pgf Coefplots.HLine({dashed, black , line_width=0.75}, 0)
treatment_divide = @pgf Coefplots.rVLine({dashed, black , line_width=0.75}, 0.4)
anno = Coefplots.Annotation(-45, "event happens", (0.4,0.2))
try
    pgfsave("../assets/esplot.svg", Coefplots.to_picture(m, zero_level, treatment_divide, anno))
catch ex 
    @warn "SVG creation failed."
end
pgfsave("../assets/esplot.png", Coefplots.to_picture(m, zero_level, treatment_divide, anno))
# pgfsave("../assets/esplot.tex", Coefplots.to_picture(m, zero_level, treatment_divide, anno))
pgfsave("esplot.tex", Coefplots.to_picture(m, zero_level, treatment_divide, anno))
@test checkfilesarethesame("../assets/esplot.tex", "esplot.tex")
