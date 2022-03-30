# Coefplots.jl

This repository aims to make available in Julia the functionalities of the Stata command `coefplot`. Work in progress.

## Example
Preparing the regression model as an example
```
using Coefplots
using DataFrames
using GLM


df = DataFrame(Y=rand(100),X1=rand(100),X2=rand(100),
               X3=rand(100),X4=rand(100),X5=rand(100), 
               X6=rand(100),X7=rand(100), X8=rand(100),
               X9=rand(100))
ols = lm(@formula(Y ~ X1 + X2 + X3 + X4 + X5 + X6 + X7 + X8 + X9), df)
```
### Plot directly
Use `setxtitle!()`, `setytitle!()`, `setname!()`, and `includenote!()` to add x label, y label, plot title, and footnote.
```
setxtitle!(coefplot,"My X-label")
setytitle!(coefplot,"My Y-label")
setname!(coefplot,"The title of my plot")
includenote!(coefplot,"Note: This is my note. These are very important captions and should not be missed for readers. This part contains a lot of important details about the figure presented in the above.")
plot(coefplot,"asset/example.png")
```
![Example plot](https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/asset/example.png)

### Manipulation with the Coefplot

```
julia> coefplot = Coefplots.parse(ols)
                ─── * Unnamed Coefplot * ───                 
─────────────────────────────────────────────────────────────
Key   Location   Point Estimate   Confidence Interval   Label
─────────────────────────────────────────────────────────────
 X5      5           0.1899       (-0.01501, 0.3947)     X5  
 X6      6          -0.1295        (-0.3633, 0.1044)     X6  
 X7      7          0.006694       (-0.1915, 0.2049)     X7  
 X8      8          -0.04351       (-0.2536, 0.1666)     X8  
 X9      9           0.2809        (0.0518, 0.5099)      X9  
 X4      4          -0.1494        (-0.3527, 0.054)      X4  
 X1      1          -0.02519       (-0.2471, 0.1967)     X1  
 X2      2          -0.02714       (-0.2353, 0.1811)     X2  
 X3      3           0.2118       (-0.004738, 0.4283)    X3  
─────────────────────────────────────────────────────────────
```
Constant term is automatically dropped. To keep constant term while parsing, specify keyword arg `drop_cons=true`. To manually drop constant, use `drop_cons!()`
```
julia> coefplot = Coefplots.parse(ols; drop_cons=false)
                       ─── * Unnamed Coefplot * ───                        
───────────────────────────────────────────────────────────────────────────
        Key   Location   Point Estimate   Confidence Interval      Label   
───────────────────────────────────────────────────────────────────────────
         X5      6           0.1899       (-0.01501, 0.3947)        X5     
         X6      7          -0.1295        (-0.3633, 0.1044)        X6     
         X7      8          0.006694       (-0.1915, 0.2049)        X7     
         X8      9          -0.04351       (-0.2536, 0.1666)        X8     
         X9      10          0.2809        (0.0518, 0.5099)         X9     
         X4      5          -0.1494        (-0.3527, 0.054)         X4     
(Intercept)      1           0.3185       (-0.002415, 0.6393)   (Intercept)
         X1      2          -0.02519       (-0.2471, 0.1967)        X1     
         X2      3          -0.02714       (-0.2353, 0.1811)        X2     
         X3      4           0.2118       (-0.004738, 0.4283)       X3     
───────────────────────────────────────────────────────────────────────────
julia> Coefplots.drop_cons!(coefplot)
                ─── * Unnamed Coefplot * ───                 
─────────────────────────────────────────────────────────────
Key   Location   Point Estimate   Confidence Interval   Label
─────────────────────────────────────────────────────────────
 X5      6           0.1899       (-0.01501, 0.3947)     X5  
 X6      7          -0.1295        (-0.3633, 0.1044)     X6  
 X7      8          0.006694       (-0.1915, 0.2049)     X7  
 X8      9          -0.04351       (-0.2536, 0.1666)     X8  
 X9      10          0.2809        (0.0518, 0.5099)      X9  
 X4      5          -0.1494        (-0.3527, 0.054)      X4  
 X1      2          -0.02519       (-0.2471, 0.1967)     X1  
 X2      3          -0.02714       (-0.2353, 0.1811)     X2  
 X3      4           0.2118       (-0.004738, 0.4283)    X3  
─────────────────────────────────────────────────────────────
```
Call `delete!()` to drop an coefficient
```
julia> Coefplots.delete!(coefplot,:X5)
                ─── * Unnamed Coefplot * ───                 
─────────────────────────────────────────────────────────────
Key   Location   Point Estimate   Confidence Interval   Label
─────────────────────────────────────────────────────────────
 X6      7          -0.1295        (-0.3633, 0.1044)     X6  
 X7      8          0.006694       (-0.1915, 0.2049)     X7  
 X8      9          -0.04351       (-0.2536, 0.1666)     X8  
 X9      10          0.2809        (0.0518, 0.5099)      X9  
 X4      5          -0.1494        (-0.3527, 0.054)      X4  
 X1      2          -0.02519       (-0.2471, 0.1967)     X1  
 X2      3          -0.02714       (-0.2353, 0.1811)     X2  
 X3      4           0.2118       (-0.004738, 0.4283)    X3  
─────────────────────────────────────────────────────────────
```
Because of deleting and appending, the distance between coefficient locations have gaps. Call `equidist!()` to make them equidistant.
```
julia> Coefplots.equidist!(coefplot)
                ─── * Unnamed Coefplot * ───                 
─────────────────────────────────────────────────────────────
Key   Location   Point Estimate   Confidence Interval   Label
─────────────────────────────────────────────────────────────
 X6      5          -0.1295        (-0.3633, 0.1044)     X6  
 X7      6          0.006694       (-0.1915, 0.2049)     X7  
 X8      7          -0.04351       (-0.2536, 0.1666)     X8  
 X9      8           0.2809        (0.0518, 0.5099)      X9  
 X4      4          -0.1494        (-0.3527, 0.054)      X4  
 X1      1          -0.02519       (-0.2471, 0.1967)     X1  
 X2      2          -0.02714       (-0.2353, 0.1811)     X2  
 X3      3           0.2118       (-0.004738, 0.4283)    X3  
─────────────────────────────────────────────────────────────
```

## Installation
```
pkg> add https://github.com/caibengbu/Coefplots.jl.git
```
## To-do list
- [x] allow adding title and note
- [x] allow horizontal plots
- [ ] allow multiple regression plot together (figure side by side, align on label axis)
- [ ] allow multiple regression plot together (figure side by side, align on value axis)
- [ ] allow multiple regression plot together (same figure, singlecoefplot side by side)
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
