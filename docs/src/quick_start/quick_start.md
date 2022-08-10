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

test

```@example pgf
using Coefplots
using RDatasets
using GLM
df = dataset("datasets", "iris");
reg = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth), df)
p = plot(reg)

savefigs("quick_start1", p) # hide
```