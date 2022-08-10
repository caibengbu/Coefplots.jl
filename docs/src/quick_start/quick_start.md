# Quick Start

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdftocairo -svg -l  1 $(figname * ".pdf") $(figname * ".svg")`)
    pgfsave(figname * ".tex", obj);
    return nothing
end
```

We use the Iris dataset from RDatasets.jl to demonstrate the basic usage of Coefplots.jl

```@example pgf
using Coefplots
using RDatasets
using GLM
df = dataset("datasets", "iris");
reg = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth), df)
p = plot(reg)

savefigs("quick_start1", p) # hide
```
[\[.pdf\]](quick_start1.pdf), [\[generated .tex\]](quick_start1.tex)

![](quick_start1.svg)