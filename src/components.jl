mutable struct CaptionStyle
    font::MaybeData{Symbol} # fontcode
    size::MaybeData{Real}
    rotate::MaybeData{Real}

    function CaptionStyle(;font=missing, size=missing, rotate=missing)
        return new(font, size, rotate)
    end
end

function to_options(l::CaptionStyle)
    """
    generates PGF options related to caption style: [font={}, rotate={}].
    """
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

mutable struct Label
    content::MaybeData{String}
    captionstyle::MaybeData{CaptionStyle}

    function Label(;content=missing, captionstyle=CaptionStyle())
        return new(content, captionstyle)
    end
end

function to_options(l::Label, label::Symbol, label_style::Symbol)
    """
    generates PGF options related to label: [label={}, label_style={font={}, rotate={}}].
    """
    options = PGFPlotsX.Options()
    if !ismissing(l.content)
        options[label] = l.content
    end
    if !ismissing(l.captionstyle)
        options[label_style] = to_options(l.captionstyle)
    end
    return options
end

mutable struct Mark
    mark::Union{Symbol, String, Missing}
    marksize::MaybeData{Real}
    linetype::MaybeData{Symbol}
    linewidth::MaybeData{Real} # line width of the draw
    fill::MaybeData{Color}
    draw::MaybeData{Color}

    function Mark(;mark=missing, marksize=missing, linetype=missing, linewidth=missing, fill=missing, draw=missing)
        return new(mark, marksize, linetype ,linewidth, fill, draw)
    end
end

function to_options(l::Mark, mark::Symbol, mark_options::Symbol)
    """
    generates PGF options related to mark: [*mark*={}, *mark_options*={fill={}, fill opacity={},
                                                                       mark size={}, draw={}, draw opacity={}, solid, line width=0.6pt}].
    """
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
        what_mark_options["fill opacity"] = l.fill.opacity
    end
    if !ismissing(l.draw)
        what_mark_options["draw"] = color_as_xcolor(l.draw)
        what_mark_options["draw opacity"] = l.draw.opacity
    end
    options[mark_options] = what_mark_options
    return options
end

mutable struct Bar
    draw::MaybeData{Color}
    linewidth::MaybeData{Real}
    linetype::MaybeData{Symbol} # eg solid, dotted, dashed, densely dotted
    
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
        options["draw opacity"] = l.draw.opacity
    end
    if !ismissing(l.linetype)
        options[l.linetype] = nothing
    end
    if !ismissing(l.linewidth)
        options["line width"] = "$(l.linewidth)pt"
    end
    return options
end

mutable struct Legend
    anchor::MaybeData{Symbol}
    at::Any
    font::MaybeData{Symbol}
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

mutable struct Note <: PGFPlotsX.TikzElement
    content::MaybeData{String}
    anchor::MaybeData{Symbol}
    at::Any
    align::MaybeData{Symbol}
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
    end
    if !ismissing(n.at)
        options[:at] = "$(n.at)"
    end
    if !ismissing(n.align)
        options[:align] = "$(n.align)"
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

function PGFPlotsX.print_tex(io::IO, hband::rHBand)
    @unpack options, ymin, ymax = hband
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "({rel axis cs:1,0}|-{rel axis cs:0,$(ymin)}) rectangle ({rel axis cs:0,0}|-{rel axis cs:0,$(ymax)});")
end

struct Annotation
    angle::Real
    content::String
    point_at::Tuple{Real, Real}
end

function PGFPlotsX.print_tex(io::IO, a::Annotation)
    @unpack angle, content, point_at = a
    x, y = point_at
    print(io, "\\draw node[pin=$(angle):{$(content)}, inner sep=0, outer sep=0] at ({rel axis cs:$(x), $(y)}) {};")
end
