# Utilities
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
```
## LaTeX escaping
Charaters like `%` and `&` are reserved for special functionalities in LaTeX. In addition, Coefplots.jl uses `symbolic coords` for regressor names, which further complicates the string escaping situation: parenthesis, commas and periods all need to be escaped. PGFPlotsX.jl uses `raw` string literal which left these situations unattended. The function `latex_escape()` will escape these characters so that in the tex output file `%` is written as `\%` (escaped, will not render as the symbol of the begining of comment in TeX), as an example. Coefplots.jl escapes parenthesis, commas and periods by adding a pair of brackets.

```@example pgf
Coefplots.print_tex(Coefplots.latex_escape("%"))
```
```@example pgf
Coefplots.print_tex(Coefplots.latex_escape("&"))
```
```@example pgf
Coefplots.print_tex(Coefplots.latex_escape("("))
```
```@example pgf
Coefplots.print_tex(Coefplots.latex_escape(","))
```

`latex_escape()` can be handy when assembling the Coefplot from a DataFrame. When `parse()` is invoked on a regression, `latex_escape()` is automatically called. 

## Coefficient Sorting

Sort the Coefplot by calling `sortcoef!()`

```@example pgf
c = parse(regression_result)
sortcoef!(c; rev=false)

p = plot(c)
savefigs("sort", p) # hide
```
[\[.pdf\]](sort.pdf), [\[generated .tex\]](sort.tex)

![](sort.svg)

## HLine and rHLine and their friends

Coefplots.jl provides its version of `HLine`, `VLine`, `HBand` and `VBand` which is analogous to those in PGFPlotsX.jl but is compatible with symbolic coords. They can be directly added to the plot by passing them to `plot()`. Coefplots.jl also allows relative specification of the location in `rHLine`, `rVLine`, `rHBand`, `rVBand`. 

```@example pgf
using PGFPlotsX
hline = @pgf Coefplots.HLine({dashed, red}, 0) # a horizontal line through point 0 on y axis, which is numerical.

rvband = @pgf rVBand({draw="none", fill="yellow", opacity = 0.4}, 0.25, 0.75) # a vertical band starting at the 1/4 of the total axis width, ending at the 3/4 of the total axis width.

p = plot(c, hline, rvband)
savefigs("addons", p) # hide
```
[\[.pdf\]](addons.pdf), [\[generated .tex\]](addons.tex)

![](addons.svg)

## Annotation

An `Annotation` is defined by its `content`, `angle`, `point_at`. `point_at` is a `Tuple{Real, Real}` that specifies the relative position of the annotation to the axis.

```@example pgf
anno = Annotation(content="This is my anotation", point_at=(0.5, 0.5), angle=45)
# this will add an annotation at the center of 

p = plot(c, hline, rvband, anno)
savefigs("addons2", p) # hide
```
[\[.pdf\]](addons2.pdf), [\[generated .tex\]](addons2.tex)

![](addons2.svg)
