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
ols1 = lm(@formula(Y~X1+X2+X3+X4), df1)
coefplot = Coefplots.parse(ols1)
setxtitle!(coefplot,"coefficient")
setytitle!(coefplot,"regressor")
setname!(coefplot,"Coefplot of My Example Regression (Multivariate)")
includenote!(coefplot,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot,"../asset/example.png")

# td = Coefplots.TikzDocument(Coefplots.TikzPicture(coefplot));

bi1 = lm(@formula(Y~X1), df1)
bi2 = lm(@formula(Y~X2), df1)
bi3 = lm(@formula(Y~X3), df1)
bi4 = lm(@formula(Y~X4), df1)


coefplot_bivar = Coefplots.concat(Coefplots.parse.([bi1,bi2,bi3,bi4]))
setxtitle!(coefplot_bivar,"coefficient")
setytitle!(coefplot_bivar,"regressor")
setname!(coefplot_bivar,"Coefplot of My Example Regression (Bivariate)")
includenote!(coefplot_bivar,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot_bivar,"../asset/example2.png")

# no constant
ols3 = lm(@formula(Y~X1+X2+X3+X4+0), df1)
coefplot_nocons = Coefplots.parse(ols3)

mcoefplot = Coefplots.MultiCoefplot(OrderedDict(:model1 => coefplot, :model2 => coefplot_bivar, :model3 => coefplot_nocons))
plot(mcoefplot)

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