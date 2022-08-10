![header](https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/assets/logo.svg)

## Introduction

[Coefplots.jl](https://github.com/caibengbu/Coefplots.jl) is a Julia package that creates publication quality visualization for regressions. It aims to make available in Julia part of the functionalities of [the Stata command `coefplot`](http://repec.sowi.unibe.ch/stata/coefplot/getting-started.html). Coefplots.jl is built on [PGFPlotsX.jl](https://github.com/KristofferC/PGFPlotsX.jl/tree/ada03510396af592e05b2e382a0c12ce37ee3cc8), which bridges the backend, LaTeX library [PGFPlots](http://pgfplots.sourceforge.net/), and Julia interface. The figures produced with Coefplots can be previewed in notebooks and IDE's, like julia-vscode and Atom-Juno, with the help of PGFPlotsX.jl.

Coefplots.jl can plot results directly from an estimation object (e.g. of type `TableRegressionModel` in StatsModels.jl, of type `RegressionModel` in StatsBase.jl, `FixedEffectModel` in FixedEffectModels.jl and so on) or DataFrame objects that contain estimation results. Results from multiple models or matrices can be combined in a single graph. Coefplots.jl draws markers for point estimates and error bars for confidence intervals. 

## Installation
```julia-repl
import Pkg
Pkg.add("Coefplots")
```

!!! note "Prerequisite Installation"

    Similar to the requirments for PGFPlotsX installation, Coefplots.jl requires 
    - a LaTeX installation with the PGFPlots package installed,
    - `pdf2svg` to generate or preview figures in `svg`. 
    - `pdftoppm` for `png` figures. 
    For more information of prerequisite installations, please refer to [the installation section of PGFPlotsX.jl's documentation](https://kristofferc.github.io/PGFPlotsX.jl/stable/#Installation).

## Gallery
### In a event study scenario
![event_study](https://raw.githubusercontent.com/caibengbu/Coefplots.jl/main/assets/esplot.svg)

### Presenting multi-dimensional results
![gmc_result](https://github.com/caibengbu/Coefplots.jl/blob/main/assets/elasticity.svg)