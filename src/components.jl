"""
    CaptionStyle

This enters `Coefplot.xticklabel`, `Coefplot.yticklabel`, 
`Coefplot.xlabel.captionstyle`, `Coefplot.ylabel.captionstyle`, 
`Coefplot.title.captionstyle`, `Coefplot.note.captionstyle`.
# Constructors
```julia
CaptionStyle(;font=missing, size=missing, rotate=missing)
```
# Keyword arguments
- `font::Union{Symbol, String, Missing}` contains the font's T1 code
- `size::Union{Real, Missing}` is the font's size in pt.
- `rotate::Union{Real, Missing}` is the rotation angle counterclockwise for the caption.
"""
mutable struct CaptionStyle
    font::Union{Symbol, String, Missing} # fontcode
    size::MaybeData{Real}
    rotate::MaybeData{Real}

    function CaptionStyle(;font=missing, size=missing, rotate=missing)
        return new(font, size, rotate)
    end
end

"""
    to_options(l::CaptionStyle)

generates PGF options related to caption style: [font={}, rotate={}].
"""
function to_options(l::CaptionStyle)
    style_options = PGFPlotsX.Options()
    if !ismissing(l.font) & !ismissing(l.size)
        style_options[:font] = "\\fontsize{$(l.size)}{$(l.size)}\\fontfamily{$(l.font)}\\selectfont"
    elseif ismissing(l.font) & !ismissing(l.size)
        style_options[:font] = "\\fontsize{$(l.size)}{$(l.size)}\\selectfont"
    elseif !ismissing(l.font) & ismissing(l.size)
        style_options[:font] = "\\fontfamily{$(l.font)}\\selectfont"
    end
    if !ismissing(l.rotate)
        style_options[:rotate] = l.rotate
    end
    return style_options
end

"""
    Label

This enters `Coefplot.xlabel`, `Coefplot.ylabel`, and that of `Multi-,` `Grouoped-`, `GroupedMultiCoefplot`.
# Constructors
```julia
Label(;content=missing, captionstyle=CaptionStyle())
```
# Keyword arguments
- `content::Union{String, Missing}` is the content of the label.
- `captionstyle::Union{CaptionStyle, Missing}` is the font's style in which the label is printed.
"""
mutable struct Label
    content::MaybeData{String}
    captionstyle::MaybeData{CaptionStyle}

    function Label(;content=missing, captionstyle=CaptionStyle())
        return new(content, captionstyle)
    end
end

"""
    to_options(l::Label, label::Symbol, label_style::Symbol)

generates PGF options related to label: [label={}, label_style={font={}, rotate={}}].
"""
function to_options(l::Label, label::Symbol, label_style::Symbol)
    options = PGFPlotsX.Options()
    if !ismissing(l.content)
        options[label] = l.content
    end
    if !ismissing(l.captionstyle)
        options[label_style] = to_options(l.captionstyle)
    end
    return options
end

"""
    Mark

This enters `Coefplot.mark`, `Coefplot.errormark`, and that of `Multi-,` `Grouoped-`, `GroupedMultiCoefplot`.
# Constructors
```julia
Mark(;mark=missing, marksize=missing, linetype=missing, linewidth=missing, fill=missing, draw=missing)
```
# Keyword arguments
- `mark::Union{Symbol, String, Missing}` is the shape of the mark.
- `marksize::Union{Real, Missing}` is the size of the mark in pt.
- `linetype::Union{Real, Missing}` is the type of line of the outline of the mark. Available choices are: `"solid"`, `"dotted"`, `"densely dotted"`, `"loosely dotted"`, `"dashed"`, `"densely dashed"`, `"loosely dashed"`, `"dash dot"`, `"densely dash dot"`, `"loosely dash dot"`, `"dash dot dot"`, `"densely dash dot dot"`, `"loosely dash dot dot"`.
- `linewidth::Union{Real, Missing}` is the width of line of the outline of the mark.
- `fill::Union{Color, Missing}` is the color used to fill the mark
- `draw::Union{Color, Missing}` is the color used to draw the outline of the mark.
"""
mutable struct Mark
    mark::Union{Symbol, String, Missing}
    marksize::MaybeData{Real}
    linetype::Union{Symbol, String, Missing}
    linewidth::MaybeData{Real} # line width of the draw
    fill::MaybeData{Color}
    draw::MaybeData{Color}

    function Mark(;mark=missing, marksize=missing, linetype=missing, linewidth=missing, fill=missing, draw=missing)
        return new(mark, marksize, linetype ,linewidth, fill, draw)
    end
end

"""
    to_options(l::Mark, mark::Union{Symbol, String}, mark_options::Union{Symbol, String})

generates PGF options related to mark: [mark={}, mark_options={fill={}, fill opacity={}, mark size={}, draw={}, draw opacity={}, solid, line width=...}].
"""
function to_options(l::Mark, mark::Union{Symbol, String}, mark_options::Union{Symbol, String})
    options = PGFPlotsX.Options()
    what_mark_options = PGFPlotsX.Options()
    if !ismissing(l.mark)
        options[mark] = "$(l.mark)"
    end
    if !ismissing(l.marksize)
        what_mark_options["mark size"] = "$(l.marksize)pt"
    end
    if !ismissing(l.linetype)
        what_mark_options[l.linetype] = nothing
    end
    if !ismissing(l.linewidth)
        what_mark_options["line width"] = "$(l.linewidth)pt"
    end
    if !ismissing(l.fill)
        what_mark_options["fill"] = color_as_xcolor(l.fill)
        what_mark_options["fill opacity"] = Int64(alpha(l.fill))
    end
    if !ismissing(l.draw)
        what_mark_options["draw"] = color_as_xcolor(l.draw)
        what_mark_options["draw opacity"] = Int64(alpha(l.draw))
    end
    options[mark_options] = what_mark_options
    return options
end

"""
    Bar

This enters `Coefplot.errbar`, `Coefplot.connect`, and that of `Multi-,` `Grouoped-`, `GroupedMultiCoefplot`.
# Constructors
```julia
Bar(;draw=missing, linewidth=missing, linetype=missing)
```
# Keyword arguments
- `draw::Union{Color, Missing}` is the color of the bar.
- `linetype::Union{Real, Missing}` is the type of line used to draw the bar. Available choices are: `"solid"`, `"dotted"`, `"densely dotted"`, `"loosely dotted"`, `"dashed"`, `"densely dashed"`, `"loosely dashed"`, `"dash dot"`, `"densely dash dot"`, `"loosely dash dot"`, `"dash dot dot"`, `"densely dash dot dot"`, `"loosely dash dot dot"`.
- `linewidth::Union{Real, Missing}` is the width of line used to draw the bar.
"""
mutable struct Bar
    draw::MaybeData{Color}
    linewidth::MaybeData{Real}
    linetype::Union{Symbol, String, Missing} # eg solid, dotted, dashed, densely dotted
    
    function Bar(;draw=missing, linewidth=missing, linetype=missing)
        return new(draw, linewidth, linetype)
    end
end

"""
    to_options(l::Bar)

generates tikz options related to bars: [draw={}, draw opacity={}, line width=0.6pt}, densely dotted].
"""
function to_options(l::Bar)
    options = PGFPlotsX.Options()
    if !ismissing(l.draw)
        options["draw"] = color_as_xcolor(l.draw)
        options["draw opacity"] = Int64(alpha(l.draw))
    end
    if !ismissing(l.linetype)
        options[l.linetype] = nothing
    end
    if !ismissing(l.linewidth)
        options["line width"] = "$(l.linewidth)pt"
    end
    return options
end

"""
    Legend

This enters `MultiCoefplot.legend`. It determines the style of the legend. The content of the legend is defined by the title of the `Coefplot`.
# Constructors
```julia
Legend(;anchor=missing, at=missing, font=missing, size=missing)
```
# Keyword arguments
- `anchor::Union{Symbol, String, Missing}` specifies the anchor of the legend box that is used for alignment. A typical one would be `"north west"`.
- `at::Any` specifies the location in the axis frame that the anchor should adhere to. A typical one would be `(1, 0)`, which means that the anchor is fixed to the south-east corner of the axis frame.
- `font::Union{Symbol, String, Missing}` is the font in which the legend should be printed in.
- `size::Union{Real, Missing}` is the font size.
"""
mutable struct Legend
    anchor::Union{Symbol, String, Missing} 
    at::Any
    font::Union{Symbol, String, Missing} 
    size::MaybeData{Real}
    
    function Legend(;anchor=missing, at=missing, font=missing, size=missing)
        return new(anchor, at, font, size)
    end
end

"""
    to_options(l::Legend)

generates tikz options related to the legend style: [font={}, rotate={}].
"""
function to_options(l::Legend)
    options = PGFPlotsX.Options()
    if !ismissing(l.font) & !ismissing(l.size)
        options[:font] = "\\fontsize{$(l.size)}{$(l.size)}\\fontfamily{$(l.font)}\\selectfont"
    elseif !ismissing(l.font) & ismissing(l.size)
        options[:font] = "\\fontfamily{$(l.font)}\\selectfont"
    elseif ismissing(l.font) & !ismissing(l.size)
        options[:font] = "\\fontsize{$(l.size)}{$(l.size)}\\selectfont"
    end
    if !ismissing(l.at)
        options[:at] = repr(l.at)
    end
    if !ismissing(l.anchor)
        options[:anchor] = "$(l.anchor)"
    end
    return options
end

"""
    Note <: PGFPlotsX.TikzElement

# Constructors
```julia
Note(;content=missing, anchor=missing ,at=missing, align=missing, captionstyle=missing)
```
# Keyword arguments
- `content::Union{String, Missing}` is the content of the note.
- `anchor::Union{Symbol, String, Missing}` specifies the anchor of the note box that is used for alignment. A typical one would be `"north west"`.
- `at::Any` specifies the location in the axis frame that the anchor should adhere to. A typical one would be `(1, 0)`, which means that the anchor is fixed to the south-east corner of the axis frame.
- `align::Union{Symbol, String, Missing}` specifies how the note should be aligned. It could be `"left"`, `"right"` or `"center"`.
- `captionstyle::Union{captionstyle, Missing}` is the caption style of the note.
"""
mutable struct Note <: PGFPlotsX.TikzElement
    content::MaybeData{String}
    anchor::Union{Symbol, String, Missing}
    at::Any
    align::Union{Symbol, String, Missing}
    captionstyle::MaybeData{CaptionStyle}

    function Note(;content=missing, anchor=missing ,at=missing, align=missing, captionstyle=missing)
        return new(content, anchor, at, align, captionstyle)
    end
end

"""
    to_options(l::Legend)

generates tikz options related to note: [font={}, rotate={}].
"""
function to_options(n::Note)
    options = PGFPlotsX.Options()
    options["text width"] = "\\the\\notewidth"
    if !ismissing(n.anchor)
        options[:anchor] = "$(n.anchor)"
    else
        options[:anchor] = "north west"
    end
    if !ismissing(n.at)
        options[:at] = "$(n.at)"
    else
        options[:at] = "(current axis.outer south west)"
    end
    if !ismissing(n.align)
        options[:align] = "$(n.align)"
    else
        options[:align] = "left"
    end
    merge!(options, to_options(n.captionstyle))
    return options
end

to_options(::Missing) = PGFPlotsX.Options()

function PGFPlotsX.print_tex(io::IO, n::Note)
    if ismissing(n.content)
        return nothing
    else
        print(io, "\\newdimen\\notewidth
                    \\pgfextractx{\\notewidth}{\\pgfpointdiff{\\pgfpointanchor{current bounding box}{west}}
                    {\\pgfpointanchor{current bounding box}{east}}}")
        print(io, "\\draw node")
        options = to_options(n)
        PGFPlotsX.print_options(io, options; newline = false)
        println(io, "{$(n.content)};")
    end
end

###################
# rVLine and rHLine #
###################

struct rVLine
    options::PGFPlotsX.Options
    x::Real
end

"""
    rVLine([options], x)

A vertical line at `x`, where `x` takes a real value between 0 and 1 and denotes the relative position of the vertical line.
"""
rVLine(x::Real) = rVLine(PGFPlotsX.Options(), x)

function PGFPlotsX.print_tex(io::IO, vline::rVLine)
    @unpack options, x = vline
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({rel axis cs:$(x),0}|-{rel axis cs:0,1}) -- ({rel axis cs:$(x),0}|-{rel axis cs:0,0});")
end

struct rHLine
    options::PGFPlotsX.Options
    y::Real
end

"""
    rHLine([options], y)

A horizontal line at `y`, where `y` takes a real value between 0 and 1 and denotes the relative position of the horizontal line.
"""
rHLine(y::Real) = rHLine(PGFPlotsX.Options(), y)

function PGFPlotsX.print_tex(io::IO, hline::rHLine)
    @unpack options, y = hline
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({rel axis cs:1,0}|-{rel axis cs:0,$(y)}) -- ({rel axis cs:0,0}|-{rel axis cs:0,$(y)});")
end

###################
# rVBand and rHBand #
###################

struct rVBand
    options::PGFPlotsX.Options
    xmin::Real
    xmax::Real
end

"""
    rVBand([options], xmin, xmax)

A vertical band from `xmin` to `xmax`, which are relative and range between 0 and 1.
"""
rVBand(xmin::Real, xmax::Real) = rVBand(PGFPlotsX.Options(), xmin, xmax)

function PGFPlotsX.print_tex(io::IO, vband::rVBand)
    @unpack options, xmin, xmax = vband
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({rel axis cs:$(xmin),0}|-{rel axis cs:0,1}) rectangle ({rel axis cs:$(xmax),0}|-{rel axis cs:0,0});")
end

struct rHBand
    options::PGFPlotsX.Options
    ymin::Real
    ymax::Real
end

"""
    rHBand([options], ymin, ymax)
A horizontal band from `ymin` to `ymax`, which are relative and range between 0 and 1.
"""
rHBand(ymin::Real, ymax::Real) = rHBand(PGFPlotsX.Options(), ymin, ymax)

function PGFPlotsX.print_tex(io::IO, hband::rHBand)
    @unpack options, ymin, ymax = hband
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({rel axis cs:1,0}|-{rel axis cs:0,$(ymin)}) rectangle ({rel axis cs:0,0}|-{rel axis cs:0,$(ymax)});")
end

###################
# VLine and HLine #
###################

struct VLine
    options::PGFPlotsX.Options
    x::Real
end

"""
    VLine([options], x)

A vertical line at `x`
"""
VLine(x::Real) = VLine(PGFPlotsX.Options(), x)

function PGFPlotsX.print_tex(io::IO, vline::VLine)
    @unpack options, x = vline
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({axis cs:$(x),{[normalized]0}}|-{rel axis cs:0,1}) -- ({axis cs:$(x),{[normalized]0}}|-{rel axis cs:0,0});")
end

struct HLine
    options::PGFPlotsX.Options
    y::Real
end

"""
    HLine([options], y)

A horizontal line at `y`
"""
HLine(y::Real) = HLine(PGFPlotsX.Options(), y)

function PGFPlotsX.print_tex(io::IO, hline::HLine)
    @unpack options, y = hline
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({rel axis cs:1,0}|-{axis cs:{[normalized]0},$(y)}) -- ({rel axis cs:0,0}|-{axis cs:{[normalized]0},$(y)});")
end

###################
# rVBand and rHBand #
###################

struct VBand
    options::PGFPlotsX.Options
    xmin::Real
    xmax::Real
end

"""
    VBand([options], xmin, xmax)

A vertical band from `xmin` to `xmax`
"""
VBand(xmin::Real, xmax::Real) = VBand(PGFPlotsX.Options(), xmin, xmax)

function PGFPlotsX.print_tex(io::IO, vband::VBand)
    @unpack options, xmin, xmax = vband
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({axis cs:$(xmin),{[normalized]0}}|-{rel axis cs:0,1}) rectangle ({axis cs:$(xmax),{[normalized]0}}|-{rel axis cs:0,0});")
end

struct HBand
    options::PGFPlotsX.Options
    ymin::Real
    ymax::Real
end

"""
    HBand([options], ymin, ymax)
A horizontal band from `ymin` to `ymax`
"""
HBand(ymin::Real, ymax::Real) = HBand(PGFPlotsX.Options(), ymin, ymax)

function PGFPlotsX.print_tex(io::IO, hband::HBand)
    @unpack options, ymin, ymax = hband
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({rel axis cs:1,0}|-{axis cs:{[normalized]0},$(ymin)}) rectangle ({rel axis cs:0,0}|-{axis cs:{[normalized]0},$(ymax)});")
end

"""
    Annotation

# Constructors
```julia
Annotation(;angle, content, point_at)
```
# Keyword arguments
- `angle::Real` is the angle of the pointer of the annotation.
- `content::String` is the textual content of the annotation.
- `point_at::Tuple{Real, Real}` specifies the location in the axis frame that the annotation should point at. A typical one would be `(1, 0)`, which means that the annotation points at the south-east corner of the axis frame.
"""
struct Annotation
    angle::Real
    content::String
    point_at::Tuple{Real, Real}
    function Annotation(;angle, content, point_at)
        new(angle, content, point_at)
    end
end

function PGFPlotsX.print_tex(io::IO, a::Annotation)
    @unpack angle, content, point_at = a
    x, y = point_at
    print(io, "\\draw node[pin=$(angle):{$(content)}, inner sep=0, outer sep=0] at ({rel axis cs:$(x), $(y)}) {};")
end