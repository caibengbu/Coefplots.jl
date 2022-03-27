include("../src/Coefplots.jl")
using .Coefplots
using GLM
using FixedEffectModels
using DataFrames
using Test

# test GLM
df = DataFrame(Y=rand(10),X1=rand(10),X2=rand(10),X3=rand(10),X4=rand(10),cat1=repeat([1,2],inner=5))
ols = lm(@formula(Y~X1+X2+X3+X4), df)
my_coefplot = Coefplots.parse(ols)
coefplot(ols,"save.pdf")
coefplot(my_coefplot,"save.pdf")

# test FixedEffectModel
feols = FixedEffectModels.reg(df, @formula(Y~X1+X2+X3+X4+FixedEffectModels.fe(cat1)))
my_coefplot = Coefplots.parse(feols)
Coefplots.rename!(my_coefplot,Dict("X1"=>"XX1","X2"=>"XX2"))
Coefplots.sort!(my_coefplot)

@test [singlecoefplot.thiscoef_label for singlecoefplot in my_coefplot.vec_singlecoefplot] == sort(["XX1","XX2","X3","X4"])

coefplot(my_coefplot,"test.pdf")