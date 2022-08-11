# Quick Start

## Plotting directly from regression

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
regression_result = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth), df)
p = plot(regression_result)

savefigs("quick_start1", p) # hide
```
[\[.pdf\]](quick_start1.pdf), [\[generated .tex\]](quick_start1.tex)

![](quick_start1.svg)

You can also customize your coefplot by passing named arguments. For example, 

```@example pgf
p = plot(regression_result; keepcoef = ["SepalWidth", "PetalLength", "PetalWidth"], # drop intercept
                            title = Label(content="My OLS regression"), # add title
                            xlabel = Label(content="Regressor Names"), # add xlabel
                            ylabel = Label(content="Coefficients"), # add ylabel
                            width = 250, # set width of the axis
                            height = 180, # set height
                            keepconnect = true, # connect consecutive coefficients
                            level = 0.9, # confidence level, the default is 0.95.
                            mark = Mark(mark=:"triangle*", marksize=4, linewidth=0)) # aesthetics

savefigs("quick_start2", p) # hide
```
[\[.pdf\]](quick_start2.pdf), [\[generated .tex\]](quick_start2.tex)

![](quick_start2.svg)

Apart from directly calling `plot()`, one can also invoke `parse()` to convert regression object to a Coefplot object. This allows users to deal with the plot with more flexibility, especially on combining plots.

```@example pgf
using FixedEffectModels
regression_withFE = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + fe(Species)))
coefplots_withfe = parse(regression_withFE; title=Label(content="OLS"))
coefplots_pool = parse(regression_result; keepcoef = ["SepalWidth", "PetalLength", "PetalWidth"], title=Label(content="with species FE"))
m = MultiCoefplot(coefplots_withfe, coefplots_pool; title = Label(content="My combined Coefplots"),
                                                    xlabel = Label(content="Regressor Names"),
                                                    ylabel = Label(content="Coefficients"),
                                                    note = Note(content="This is my note."))
p = plot(m)

savefigs("quick_start3", p) # hide
```
[\[.pdf\]](quick_start3.pdf), [\[generated .tex\]](quick_start3.tex)

![](quick_start3.svg)


## Plotting from DataFrame
In order for Coefplots.jl to learn what to plot from a DataFrame, the DataFrame needs to contain the following columns: `[:varname, :b, :se, :dof]` (`:dof` is constant across rows while others should vary). 

```@example pgf
using DataFrames
df = DataFrame(varname = ["x1", "x2", "x3"],
               b = [1, 2, 3],
               se = [0.1, 0.2, 0.3],
               dof = 10)
c = Coefplot(df)
p = plot(c)

savefigs("quick_start4", p) # hide
```
[\[.pdf\]](quick_start4.pdf), [\[generated .tex\]](quick_start4.tex)

![](quick_start4.svg)