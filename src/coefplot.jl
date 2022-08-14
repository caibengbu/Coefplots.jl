mutable struct Coefplot
    # axis args
    title::Label
    xlabel::Label
    ylabel::Label
    xticklabel::CaptionStyle
    yticklabel::CaptionStyle
    width::Real
    height::Real

    # addplot args
    keepmark::Bool
    keepconnect::Bool
    mark::Mark
    errormark::Mark
    errorbar::Bar
    connect::Bar
    offset::Real # use only in Multicoefplot
    
    # data
    data::AbstractDataFrame # contains variables: varname, b, se, do
    sorter::Vector{String} # is a sorter of varnames
    level::Real # confidence level

    # note
    note::Note

    # vertical
    vertical::Bool

    # TO-DO: allow other components in the struct, instead of plugging in to_picture

    function Coefplot(data::AbstractDataFrame
                      ;title::Label = Label(), 
                      xlabel::Label = Label(), 
                      ylabel::Label = Label(), 
                      xticklabel::CaptionStyle = CaptionStyle(),
                      yticklabel::CaptionStyle = CaptionStyle(),
                      width::Real = 240, # in line with the tikz default
                      height::Real = 204,
                      keepmark::Bool = true,
                      keepconnect::Bool = false,
                      mark::Mark = Mark(mark=:"square*", marksize=1.75, linewidth=0, fill=first(COLOR_LOOP), draw=first(COLOR_LOOP)),
                      errormark::Mark = Mark(mark=:|, marksize=2.0, linewidth=0.6, linetype=:solid, fill=first(COLOR_LOOP), draw=first(COLOR_LOOP)),
                      errorbar::Bar = Bar(linewidth=1.5, linetype=Symbol("densely dotted"), draw=first(COLOR_LOOP)),
                      connect::Bar = Bar(linewidth=0.5, draw=first(COLOR_LOOP)),
                      offset::Real = 0,
                      sorter::Vector{String} = String[], # default sorter is data.varname, with the original order
                      level::Real = 0.95, # default confidence level is 95%
                      note::MaybeData{Note} = Note(anchor=Symbol("north west"), at="(current bounding box.south west)", align=:left, captionstyle=CaptionStyle()), # default note is missing, but keep the box aligned
                      vertical::Bool = true,
                      kwargs ...)
        """
        to construct a Coefplot, the minimal invocation is `Coefplot(data; sorter = sorter)`
        """
        if isempty(sorter)
            sorter = data.varname
        end
        new(title, xlabel, ylabel, xticklabel, yticklabel, width, height, keepmark, keepconnect, mark, errormark, errorbar, connect, offset, data, sorter, level, note, vertical)
    end
end

# TODO: be able to rename the varnames
"""
    get_axis_options(c::Coefplot)

Renders the properties of a Coefplot object as options of the \\begin{axis}
"""
function get_axis_options(c::Coefplot)
    """
    extract all fields in a coefplot that are related to the options of the axis, and generate such PGFPlotsX.Options
    """
    axis_options = PGFPlotsX.Options()
    for x in [:title, :xlabel, :ylabel]
        if !ismissing(getfield(c,x))
            merge!(axis_options, to_options(getfield(c,x), x, Symbol("$x style")))
        end
    end
    for x in [:xticklabel, :yticklabel]
        if !ismissing(getfield(c,x))
            axis_options[Symbol("$x style")] = to_options(getfield(c,x))
        end
    end
    axis_options[:width] = "$(c.width)pt"
    axis_options[:height] = "$(c.height)pt"
    if c.vertical
        axis_options["symbolic x coords"] = c.sorter
        axis_options["xtick"] = c.sorter # force show all xticklabel
        axis_options["xmin"] = "{[normalized]-0.5}"
        axis_options["xmax"] = "{[normalized]$(length(c.sorter)-0.5)}"
    else
        axis_options["symbolic y coords"] = c.sorter
        axis_options["ytick"] = c.sorter
        axis_options["ymin"] = "{[normalized]-0.5}"
        axis_options["ymax"] = "{[normalized]$(length(c.sorter)-0.5)}"
    end
    axis_options["scale only axis"] = nothing
    return axis_options
end

"""
    get_plot_options(c::Coefplot)

Renders the properties of a Coefplot object as options of the \\addplot
"""
function get_plot_options(c::Coefplot)
    """
    extract all fields in a coefplot that are related to the options of the plot, and generate such PGFPlotsX.Options
    """
    plot_options = PGFPlotsX.Options()
    if !c.keepmark & c.keepconnect
        plot_options[Symbol("no marks")] = nothing
    elseif c.keepmark & !c.keepconnect
        plot_options[Symbol("only marks")] = nothing
    elseif !c.keepmark & !c.keepconnect
        throw(ArgumentError("You have to keep at least one of the mark and connect"))
    end
        

    merge!(plot_options, to_options(c.mark, :mark, Symbol("mark options")))
    merge!(plot_options, to_options(c.errormark, Symbol("error bars/error mark"), Symbol("error bars/error mark options")))
    plot_options["error bars/error bar style"] = to_options(c.errorbar)
    merge!(plot_options, to_options(c.connect))

    if c.vertical
        plot_options["error bars/y dir"] = "both"
        plot_options["error bars/y explicit"] = nothing
        if c.offset != 0
            plot_options["x filter/.code"]="{\\pgfmathadd{\\pgfmathresult}{$(c.offset)}}"
        end
    else
        plot_options["error bars/x dir"] = "both"
        plot_options["error bars/x explicit"] = nothing
        if c.offset != 0
            plot_options["y filter/.code"]="{\\pgfmathadd{\\pgfmathresult}{$(c.offset)}}"
        end
    end
    return plot_options
end


# TO-DO: allow adding HBand HLine VBand VLine
const SupportedAddition = Union{PGFPlotsX.HLine, PGFPlotsX.VLine,
                                PGFPlotsX.HBand, PGFPlotsX.VBand,
                                rHLine, rVLine, rHBand, rVBand, Annotation}
"""
    to_picture(c::Coefplot, other::SupportedAddition ...)

Convert the Coefplot object to an PGFPlotsX.TikzPicture. Other supported components are allowed and appended after the Coefplot. 
The note field is drawn as a node beyond the axis.
"""
to_picture(c::Coefplot, other::SupportedAddition ...) = PGFPlotsX.TikzPicture(to_axis(c, other...), c.note)

"""
    to_axis(c::Coefplot, other::SupportedAddition ...)

Converts the Coefplot object to a PGFPlotsX.Axis object. Other supported components are allowed and appended after the Coefplot within the axis. 
"""
to_axis(c::Coefplot, other::SupportedAddition ...) = PGFPlotsX.Axis(get_axis_options(c), to_plot(c), other...)

"""
    to_plot(c::Coefplot)

Convert the Coefplot object to an PGFPlotsX.AxisElement. It is realized using the PGFPlotsX.Plot/PGFPlotsX.Coordinates combination.
"""
function to_plot(c::Coefplot)

    if !isempty(c.sorter) # sort
        data = c.data[indexin(c.sorter, c.data.varname),:]
    else
        data = c.data
    end

    plot_options = get_plot_options(c)
    if c.vertical
        return PGFPlotsX.Plot(plot_options,
                    PGFPlotsX.Coordinates(data.varname, data.b; yerror = errbar_length(data, c.level)))
    else
        return PGFPlotsX.Plot(plot_options,
                    PGFPlotsX.Coordinates(data.b, data.varname; xerror = errbar_length(data, c.level)))
    end
end

"""
    color!(c::Coefplot, clr::Color)

Reset the color of a Coefplot.
"""
function color!(c::Coefplot, clr::Color)
    """
    short cut to recolor all the elements in a coefplot, instead of re-assign colors one by one.
    """
    c.mark.draw = clr
    c.mark.fill = clr
    c.errormark.draw = clr
    c.errormark.fill = clr
    c.errorbar.draw = clr
    c.connect.draw = clr
end

"""
    errbar_length(data::AbstractDataFrame, level::Real=0.95)

Compute the length of the error bar for each coefficient.
"""
errbar_length(data::AbstractDataFrame, level::Real=0.95) = data.se .* abs(quantile(Distributions.TDist(first(data.dof)), (1. - level)/2.))

"""
    minimum(c::Coefplot)

Compute the minimal value that the Coefplot can reach with its error bar.
"""
Base.minimum(c::Coefplot) = minimum(c.data.b - Coefplots.errbar_length(c.data, c.level))

"""
    maximum(c::Coefplot)

Compute the maximal value that the Coefplot can reach with its error bar.
"""
Base.maximum(c::Coefplot) = maximum(c.data.b + Coefplots.errbar_length(c.data, c.level))