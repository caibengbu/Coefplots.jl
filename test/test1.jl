include("../src/Coefplots.jl")
using .Coefplots
using GLM
using DataFrames
using Test

# test GLM
df1 = DataFrame(Y=rand(100),X1=rand(100),X2=rand(100),
               X3=rand(100),X4=rand(100),X5=rand(100), 
               X6=rand(100),X7=rand(100), X8=rand(100),
               X9=rand(100),cat1=repeat([1,2],inner=50))
ols1 = lm(@formula(Y~X1+X2+X3+X4+X5+X6+X7+X8+X9), df1)
coefplot = Coefplots.parse(ols1)
setxtitle!(coefplot,"My X-label")
setytitle!(coefplot,"My Y-label")
setname!(coefplot,"The title of my plot")
includenote!(coefplot,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot,"../asset/example.pdf")

# td = Coefplots.TikzDocument(Coefplots.TikzPicture(coefplot));

bi1 = lm(@formula(Y~X6+0), df1)
bi2 = lm(@formula(Y~X2+0), df1)
bi3 = lm(@formula(Y~X3+0), df1)
bi4 = lm(@formula(Y~X4+0), df1)
bi5 = lm(@formula(Y~X5+0), df1)


plot(coefplot_bivar,"save.png")
#=
plot(my_coefplot,"save.pdf")

# test FixedEffectModel
feols = FixedEffectModels.reg(df, @formula(Y~X1+X2+X3+X4+FixedEffectModels.fe(cat1)))
my_coefplot = Coefplots.parse(feols)
Coefplots.rename!(my_coefplot,Dict("X1"=>"XX1","X2"=>"XX2"))
Coefplots.sort!(my_coefplot)

@test [singlecoefplot.thiscoef_label for singlecoefplot in my_coefplot.vec_singlecoefplot] == sort(["XX1","XX2","X3","X4"])

coefplot(my_coefplot,"test.pdf")
=#