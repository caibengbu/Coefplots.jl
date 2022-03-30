# Coefplots.jl

This repository aims to make available in Julia the functionalities of the Stata command `coefplot`. Work in progress.

## Example
```
using Coefplots
using DataFrames
using GLM


df1 = DataFrame(Y=rand(100),X1=rand(100),X2=rand(100),
               X3=rand(100),X4=rand(100),X5=rand(100), 
               X6=rand(100),X7=rand(100), X8=rand(100),
               X9=rand(100),cat1=repeat([1,2],inner=50))
ols = lm(@formula(Y ~ X1 + X2 + X3 + X4 + X5 + X6 + X7 + X8 + X9), df1)
coefplot = Coefplots.parse(ols)
setxtitle!(coefplot,"My X-label")
setytitle!(coefplot,"My Y-label")
setname!(coefplot,"The title of my plot")
includenote!(coefplot,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot,"asset/example1.png")
```
![Example plot](https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/asset/example.png)

## Installation
```
pkg> add https://github.com/caibengbu/Coefplots.jl.git
```
## To-do list
- [ ] allow adding title and note
- [ ] allow horizontal plots
- [ ] allow multiple regression plot together (figure side by side, align on label axis)
- [ ] allow multiple regression plot together (figure side by side, align on value axis)
- [ ] allow multiple regression plot together (same figure, singlecoefplot side by side)
- [ ] allow offset
- [ ] allow yline
- [ ] allow xline
- [ ] allow yband
- [ ] allow xband
- [ ] automate fontsize
- [ ] allow color change
- [ ] allow node shape change
- [ ] allow node fill opacity, draw opacity to be different
- [ ] allow grid
- [ ] allow NaN and Inf
