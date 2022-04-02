include("../src/Coefplots.jl")
using .Coefplots
using RDatasets
using GLM
using DataFrames
using Test

# Example 1
df = dataset("datasets", "iris")
ols1 = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth), df)
plot(ols1,"../asset/example1.svg")

# Example 2
coefplot = Coefplots.parse(ols1)
setxtitle!(coefplot,"coefficient")
setytitle!(coefplot,"regressor")
setname!(coefplot,"Coefplot of My Example Regression")
includenote!(coefplot,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot,"../asset/example2_multivariate.svg")

# td = Coefplots.TikzDocument(Coefplots.TikzPicture(coefplot));

uni1 = lm(@formula(SepalLength~SepalWidth), df)
uni2 = lm(@formula(SepalLength~PetalLength), df)
uni3 = lm(@formula(SepalLength~PetalWidth), df)


coefplot_bivar = Coefplots.concat(Coefplots.parse.([uni1,uni2,uni3]))
setxtitle!(coefplot_bivar,"coefficient")
setytitle!(coefplot_bivar,"regressor")
setname!(coefplot_bivar,"Coefplot of My Example Regression")
includenote!(coefplot_bivar,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot_bivar,"../asset/example2_univariate.svg")

# no constant
ols3 = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + 0), df)
coefplot_nocons = Coefplots.parse(ols3)

mcoefplot = Coefplots.MultiCoefplot(:model1 => coefplot, :model2 => coefplot_bivar, :model3 => coefplot_nocons)
setlegends!(mcoefplot, :model1 => "Multivariate", :model2 => "Bivariate", :model3 => "No Constant")
plot(mcoefplot,"../asset/example2_multicoefplot.svg")


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