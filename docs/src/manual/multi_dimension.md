# Plot Combination
There are four types of plots in Coefplots.jl: `Coefplot`, `MultiCoefplot`, `GroupedCoefplot`, `GroupedMultiCoefplot`. 

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    try
        pgfsave(figname * ".pdf", obj)
        run(`pdftocairo -svg -l  1 $(figname * ".pdf") $(figname * ".svg")`)
        pgfsave(figname * ".tex", obj);
    catch e
        @error e
    end
    return nothing
end

using Coefplots
using RDatasets
using GLM
df = dataset("datasets", "iris");
regression_result = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth), df)

using FixedEffectModels
regression_withFE = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + fe(Species)));
coefplots_withfe = parse(regression_withFE; title=Label(content="OLS"))
coefplots_pool = parse(regression_result; keepcoef = ["SepalWidth", "PetalLength", "PetalWidth"], title=Label(content="with species FE"))
```

## MultiCoefplot

We continue the example in quick start. We have also ready seen `MultiCoefplot()` in the previous chapter.

```@example pgf
m = MultiCoefplot(coefplots_withfe, coefplots_pool; title = Label(content="My combined Coefplots"),
                                                    xlabel = Label(content="Regressor Names"),
                                                    ylabel = Label(content="Coefficients"),
                                                    note = Note(content="This is my note."))

m_plot = plot(m)

savefigs("md1", m_plot) # hide
```
[\[.pdf\]](md1.pdf), [\[generated .tex\]](md1.tex)

![](md1.svg)

## GroupedCoefplot

We also provide method `GroupedCoefplot()` to plot Coefplot objects side by side

```@example pgf
g = GroupedCoefplot("OLS" => coefplots_pool, "FE" => coefplots_withfe; 
    title = Label(content="My combined Coefplots"),
    ylabel = Label(content="Coefficients"),
    width = 350)

g_plot = plot(g)
savefigs("md2", g_plot) # hide
```
[\[.pdf\]](md2.pdf), [\[generated .tex\]](md2.tex)

![](md2.svg)

Not limited to plot multiple regressions, `GroupedCoefplot()` can also divide the coefficients in a single regression into multiple groups however the user wants. To make this happen, we first extract the regression results in DataFrame form,

```@example pgf
df = deepcopy(coefplots_pool.data) # extract the regression results from Coefplot object
df
```

we add our categorization (it doesn't have to be called `coefgroup`), use DataFrames.jl's `groupby()` to produce a `GroupedDataFrame`, and then plug it in our `GroupedCoefplot()` method.

```@example pgf
df.coefgroup = ["Width Related", "Length Related", "Width Related"]
grouped_df = groupby(df, [:coefgroup])
g2 = GroupedCoefplot(grouped_df; title = Label(content="My combined Coefplots"),
                                 ylabel = Label(content="Coefficients"),
                                 width = 200)

g2_plot = plot(g2)
savefigs("md3", g2_plot) # hide
```
[\[.pdf\]](md3.pdf), [\[generated .tex\]](md3.tex)

![](md3.svg)

## GroupedMultiCoefplot

This type is reserved for scenarios when the user wants to have side-by-side plots and also overlapping plots. One can achieve this by plug in `Pair{Any, MultiCoefplot} ...` or `Pair{Any, GroupedCoefplots} ...` when invoking `GroupedMultiCoefplot()`. For example,

```@example pgf
df = deepcopy(coefplots_withfe.data)
df.coefgroup = ["Width Related", "Length Related", "Width Related"]
grouped_df = groupby(df, [:coefgroup])
g3 = GroupedCoefplot(grouped_df)

gmc = GroupedMultiCoefplot("OLS" => g2, "FE" => g3; show_legend=[false, true], # which subplot should show their legend
                                                    legend = Coefplots.Legend(at=(0.98,0.02), 
                                                                              anchor = Symbol("south east")))

gmc_plot = plot(gmc)
savefigs("gmc", gmc_plot) # hide
```
[\[.pdf\]](gmc.pdf), [\[generated .tex\]](gmc.tex)

![](gmc.svg)