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

The quickest way to plot a coefplot is to invoke `plot()`.

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

You can also customize your coefplot by passing named arguments. For example,

```@example pgf
p = plot(reg; keepcoef = ["SepalWidth", "PetalLength", "PetalWidth"],
              title = Label(content="My OLS regression"),
              xlabel = Label(content="Regressor Names"),
              ylabel = Label(content="Coefficients"),
              width = 250, 
              height = 180,
              keepconnect = true,
              mark = Mark(mark=:"triangle*", marksize=4, linewidth=0))

savefigs("quick_start2", p) # hide
```
[\[.pdf\]](quick_start2.pdf), [\[generated .tex\]](quick_start2.tex)

![](quick_start2.svg)