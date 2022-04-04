# Coefplots.jl

[Coefplots](https://github.com/caibengbu/Coefplots.jl) aims to make available in Julia (part of) the functionalities of [the Stata command `coefplot`](http://repec.sowi.unibe.ch/stata/coefplot/getting-started.html). [Coefplots](https://github.com/caibengbu/Coefplots.jl) is built on [PGFPlotsX](https://github.com/KristofferC/PGFPlotsX.jl/tree/ada03510396af592e05b2e382a0c12ce37ee3cc8). Work in progress.

## Quick Start

We use the Iris dataset from RDatasets.jl to demonstrate the basic usage of Coefplots.jl


```julia
# include("../src/Coefplots.jl")
# using .Coefplots
using Coefplots
using RDatasets
using GLM
using DataFrames

df = dataset("datasets", "iris"); 
```

### Example 1
Plot the regression directly. 


```julia
# Example 1
ols1 = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth), df)
plot(ols1)
# plot(ols1,"../asset/example1.svg")
```


<img src="https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/asset/example1.svg" width="500" height="500">
    


### Example 2
You can also convert the regression model into a Coefplot object, then add other attributes of the plot using `setxtitle!()`, `setytitle!()`, `setname!()`, `includenote!()` before you plot your regression.


```julia
# Example 2
coefplot = Coefplots.parse(ols1)
setxtitle!(coefplot,"coefficient")
setytitle!(coefplot,"regressor")
setname!(coefplot,"Coefplot of My Example Regression (Multivariate)")
includenote!(coefplot,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot)
# plot(coefplot,"../asset/example2_multivariate.svg")
```


<img src="https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/asset/example2_multivariate.svg" width="500" height="500">
    


### Example 3
To combine results from multiple coefplots and plot them in one Coefplot, use the command `concat()`


```julia
# Example 3
uni1 = lm(@formula(SepalLength~SepalWidth), df)
uni2 = lm(@formula(SepalLength~PetalLength), df)
uni3 = lm(@formula(SepalLength~PetalWidth), df)

coefplot_univar = Coefplots.concat(Coefplots.parse.([uni1,uni2,uni3]))
setxtitle!(coefplot_univar,"coefficient")
setytitle!(coefplot_univar,"regressor")
setname!(coefplot_univar,"Coefplot of My Example Regression (Univariate)")
includenote!(coefplot_univar,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot)
# plot(coefplot_univar,"../asset/example2_univariate.svg")
```


<img src="https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/asset/example2_univariate.svg" width="500" height="500">
    


### Example 4
To plot multiple coefplots together as a MultiCoefplot, construct the MultiCoefplot object from `MultiCoefplot()`


```julia
# Example 4
# no constant
ols3 = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + 0), df)
coefplot_nocons = Coefplots.parse(ols3)
mcoefplot = Coefplots.MultiCoefplot(:model1 => coefplot, :model2 => coefplot_univar, :model3 => coefplot_nocons)
setlegends!(mcoefplot, :model1 => "Multivariate", :model2 => "Univariate", :model3 => "No Constant")
plot(mcoefplot)
# plot(mcoefplot,"../asset/example2_multicoefplot.svg")
```


<img src="https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/asset/example2_multicoefplot.svg" width="500" height="500">
    
### Example 5
You can also add TikzElements from PGFPlotsX using their macro `@pgf`. The supported TikzElements now are limited to `HLine`, `HBand`, `VLine`, `VBand`.

```julia
# Example 5
# Add PGFPlotsX TikzElement using their @pgf macro
using PGFPlotsX
addcomponent!(coefplot, @pgf VLine({red, dashed},0)) # add a vertical line red dashed line
# plot(coefplot, "../asset/example5_1.svg")
plot(coefplot)
```

<img src="https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/asset/example5_1.svg" width="500" height="500">

```julia
push!(Coefplots.PGFPlotsX.CUSTOM_PREAMBLE, "\\usetikzlibrary{patterns}")
addcomponent!(mcoefplot, @pgf HBand({pattern = "north west lines", opacity = 0.5, draw = "none"}, 1, 2)) # add a horizontal band from y=1 to y=2
# plot(mcoefplot, "../asset/example5_2.svg")
plot(mcoefplot)
```

<img src="https://github.com/caibengbu/Coefplots.jl/blob/main/asset/example5_2.svg" width="500" height="500">


## Installation
```
pkg> add https://github.com/caibengbu/Coefplots.jl.git
```
## To-do list
- [x] allow adding title and note
- [x] allow horizontal plots
- [ ] allow multiple regression plot together (figure side by side, align on label axis)
- [ ] allow multiple regression plot together (figure side by side, align on value axis)
- [x] allow multiple regression plot together (same figure, singlecoefplot side by side)
- [ ] allow offset
- [ ] allow yline
- [ ] allow xline
- [ ] allow yband
- [ ] allow xband
- [ ] automate fontsize
- [x] allow color change
- [ ] allow node shape change
- [x] allow node fill opacity, draw opacity to be different
- [ ] allow grid
- [ ] allow NaN and Inf
