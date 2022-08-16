```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdftocairo -svg -l  1 $(figname * ".pdf") $(figname * ".svg")`)
    pgfsave(figname * ".tex", obj);
    return nothing
end

saveicon = (figname, icon) -> begin
    obj = PGFPlotsX.TikzPicture("\\draw plot[mark=$(icon),mark size=4, mark options={fill=red}] (0,0) -- plot[mark=$(icon),mark size=4, mark options={fill=red}] (1,0.5) -- plot[mark=$(icon),mark size=4, mark options={fill=red}] (2,0) -- plot[mark=$(icon),mark size=4, mark options={fill=red}] (3,0.5);")
    pgfsave(figname * ".pdf", obj)
    run(`pdftocairo -svg -l  1 $(figname * ".pdf") $(figname * ".svg")`)
    return nothing
end

saveicon("filled_circle", "*")
saveicon("cross", "x")
saveicon("plus", "+")
saveicon("minus", "-")
saveicon("pipe", "|")
saveicon("asterisk", "asterisk")
saveicon("star", "star")
saveicon("10_pointed_star", "10-pointed star")
saveicon("oplus", "oplus")
saveicon("filled_oplus", "oplus*")
saveicon("otimes", "otimes")
saveicon("filled_otimes", "otimes*")
saveicon("square", "square")
saveicon("filled_square", "square*")
saveicon("triangle", "triangle")
saveicon("filled_triangle", "triangle*")
saveicon("diamond", "diamond")
saveicon("filled_diamond", "diamond*")
saveicon("halfcircle", "halfcircle")
saveicon("filled_halfcircle", "halfcircle*")
saveicon("filled_halfdiamond", "halfdiamond*")
saveicon("filled_halfsquare", "halfsquare*")
saveicon("filled_halfsquare_right", "halfsquare right*")
saveicon("filled_halfsquare_left", "halfsquare left*")
saveicon("pentagon", "pentagon")
saveicon("filled_pentagon", "pentagon*")
saveicon("Mercedes_star", "Mercedes star")
saveicon("Mercedes_star_flipped", "Mercedes star flipped")
saveicon("heart", "heart")
saveicon("ball", "ball")


using Coefplots
using RDatasets
using GLM
df = dataset("datasets", "iris");
regression_result = lm(@formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth), df)
```

# Appearence

## Colors and mark shapes

Coefplots.jl uses [Colors.jl](https://github.com/JuliaGraphics/Colors.jl) to manage the coloring of the plots. Colors.jl supports a variety of [colorspaces](http://juliagraphics.github.io/Colors.jl/stable/constructionandconversion/). Colors.jl also provides a wide variety of named colors to choose from, see [here](http://juliagraphics.github.io/Colors.jl/stable/namedcolors/) for more information. 

The default color for Coefplot is the Julia logo blue. For `MultiCoefplot` and `GroupedMultiCoefplot`, Coefplots.jl iterates over Julia blue, Julia green, Julia red, Julia purple and restart if reaches the end. 

Colorable components in Coefplots.jl are `Mark`, `Bar`. Color these objects simply by passing a Color to named arguments `fill` or `draw` (`fill` doesn't work for `Bar`). 

The `Mark` object that gets passed to `Coefplot.mark` defines the style in which Coefplots.jl draw the point estimate, while `Coefplot.errormark` defines the the style of the endpoints of the confidence interval. The `Bar` object that gets passed to `Coefplot.errorbar` defines the style of the confidence interval, while `Coefplot.connect` defines the style of the line that connects consecutive coefficients if `keepconnect` is `true`.

The user can choose from a variety of mark shapes.

| mark           |    preview | mark           |    preview |
|:--------------:|:----------:|:--------------:|:----------:|
|mark="*"        |![](filled_circle.svg) |mark="x"        |![](cross.svg) |
|mark="+"        |![](plus.svg) |mark="-"        |![](minus.svg) |
|mark="\|"       |![](pipe.svg) |mark="asterisk" |![](asterisk.svg) |
|mark="star"     |![](star.svg) |mark="10-pointed star"     |![](10_pointed_star.svg) |
|mark="oplus"     |![](oplus.svg) |mark="oplus*"     |![](filled_oplus.svg) |
|mark="otimes"     |![](otimes.svg) |mark="otimes*"     |![](filled_otimes.svg) |
|mark="square"     |![](square.svg) |mark="square*"     |![](filled_square.svg) |
|mark="triangle"     |![](triangle.svg) |mark="triangle*"     |![](filled_triangle.svg) |
|mark="diamond"     |![](diamond.svg) |mark="diamond*"     |![](filled_diamond.svg) |
|mark="pentagon"     |![](pentagon.svg) |mark="pentagon*"     |![](filled_pentagon.svg) |
|mark="halfcircle"     |![](halfcircle.svg) |mark="halfcircle*"     |![](filled_halfcircle.svg) |
|mark="halfdiamond*"     |![](filled_halfdiamond.svg) |mark="halfsquare*"     |![](filled_halfsquare.svg) |
|mark="halfsquare right*"     |![](filled_halfsquare_right.svg) |mark="halfsquare left*"     |![](filled_halfsquare_left.svg) |
|mark="Mercedes star"     |![](Mercedes_star.svg) |mark="Mercedes star flipped"     |![](Mercedes_star_flipped.svg) |
|mark="heart"     |![](heart.svg) |mark="ball"     |![](ball.svg) |

For example, 

```@example pgf
using Colors
coefplots_pool = parse(regression_result, mark=Mark(mark="heart", marksize=3, fill=colorant"salmon", draw=colorant"#FF0000"),
                                          errorbar=Bar(linewidth=2, linetype=Symbol("densely dotted"), draw=colorant"lightsalmon"),
                                          errormark=Mark(mark=:|, marksize=3.0, linewidth=0.8, linetype=:solid, draw=colorant"firebrick2"),
                                          connect=Bar(draw=colorant"lightsalmon"),
                                                    keepconnect=true)

p = plot(coefplots_pool)

savefigs("a1", p) # hide
```
[\[.pdf\]](a1.pdf), [\[generated .tex\]](a1.tex)

![](a1.svg)

## Caption Styles

There are three elements about a caption that can be customized: `font`, `size`, and `rotate`. `font` dictates the font in which the caption is written in, `size` determines the font size, and `rotate` specifies the angle to which the caption is tilted. This can be useful when the caption is long but the intervals between captions are short.

```@example pgf
coefplots_pool = parse(regression_result, xticklabel=CaptionStyle(font="phv", 
                                                                  size=10,
                                                                  rotate=45))

p = plot(coefplots_pool)

savefigs("a1", p) # hide
```

Fonts can be accessed with T1 encoding. To list all code installed, check out the documents that pops out after typing `texdoc fontname` in terminal. Its appendix provides a big list of available fonts.