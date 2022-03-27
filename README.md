# Coefplots.jl

This repository aims to make available in Julia the functionalities of the Stata command `coefplot`. Work in progress.

## Example
```
using Coefplots
using DataFrames
using GLM

df = DataFrame(Y=rand(10), X1=rand(10), X2=rand(10), X3=rand(10), X4=rand(10))
ols = lm(@formula(Y ~ X1 + X2 + X3 + X4), df)
coefplot(ols,"save.pdf")
```
![Example plot](https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/asset/example.png)
