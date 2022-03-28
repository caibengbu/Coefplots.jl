# Coefplots.jl

This repository aims to make available in Julia the functionalities of the Stata command `coefplot`. Work in progress.

## Example
```
using Coefplots
using DataFrames
using GLM

df = DataFrame(Y=rand(10), X1=rand(10), X2=rand(10), X3=rand(10), X4=rand(10))
ols = lm(@formula(Y ~ X1 + X2 + X3 + X4), df)
plot(ols,"save.pdf")
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
