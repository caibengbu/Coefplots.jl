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
    data::AbstractDataFrame # contains variables: varname, b, se, dof, (optional: groupname)
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
                      keepconnect::Bool = true,
                      mark::Mark = Mark(mark=:"square*", marksize=1.75, linewidth=0, fill=first(COLOR_LOOP), draw=first(COLOR_LOOP)),
                      errormark::Mark = Mark(mark=:|, marksize=2.0, linewidth=0.6, linetype=:solid, fill=first(COLOR_LOOP), draw=first(COLOR_LOOP)),
                      errorbar::Bar = Bar(linewidth=1.5, linetype=Symbol("densely dotted"), draw=first(COLOR_LOOP)),
                      connect::Bar = Bar(linewidth=0.5, draw=first(COLOR_LOOP)),
                      offset::Real = 0,
                      sorter::Vector{String} = String[], # default sorter is data.varname, with the original order
                      level::Real = 0.95, # default confidence level is 95%
                      note::MaybeData{Note} = Note(anchor=Symbol("north west"), at="(current bounding box.south west)", align=:left, captionstyle=CaptionStyle()), # default note is missing, but keep the box aligned
                      vertical::Bool = true)
        """
        to construct a Coefplot, the minimal invocation is `Coefplot(data; sorter = sorter)`
        """
        new(title, xlabel, ylabel, xticklabel, yticklabel, width, height, keepmark, keepconnect, mark, errormark, errorbar, connect, offset, data, sorter, level, note, vertical)
    end
end

# TODO: be able to rename the varnames

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
    return axis_options
end

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

function group(c::Coefplot)
    data = c.data
    ncoef = size(data,1)
    gdata = groupby(data, :groupname)
    groupedcoefplot = map(pairs(gdata)) do ((groupname,), subdata)
        _c = deepcopy(c)
        _c.data = subdata
        nsubcoef = size(subdata,1)
        if _c.vertical
            _c.width *= nsubcoef/ncoef
        else
            _c.height *= nsubcoef/ncoef
        end
        filter!(x->x in subdata.varname, _c.sorter)
        return groupname => deepcopy(_c)
    end
    if ~c.vertical
        # groupplot draw from top to down and left to right
        reverse!(groupedcoefplot)
    end
    return groupedcoefplot
end

function get_groupplot_options(gc::Vector{Pair{T, Coefplot}}) where T <: AbstractString
    ngroups = length(gc)
    actualmin = minimum(map(gc) do x
        c = x.second
        minimum(c.data.b - Coefplots.errbar_length(c.data, c.level))
    end)
    actualmax = maximum(map(gc) do x
        c = x.second
        maximum(c.data.b + Coefplots.errbar_length(c.data, c.level))
    end)
    actualrange = actualmax - actualmin
    coefmin = actualmin - actualrange * 0.15
    coefmax = actualmax + actualrange * 0.15

    groupplot_options = PGFPlotsX.Options()
    c = last(first(gc)) # representitive coefplot in a groupedcoefplot
    if c.vertical
        groupplot_options["group style"] = PGFPlotsX.Options(
            "group size" => "$(ngroups) by 1",
            "y descriptions at" => "edge left", 
            "ylabels at" => "edge left",
            "horizontal sep" => "10pt"
        )
        groupplot_options["ymin"] = coefmin
        groupplot_options["ymax"] = coefmax
        merge!(groupplot_options, to_options(getfield(c,:ylabel), :ylabel, Symbol("ylabel style")))
    else
        groupplot_options["group style"] = PGFPlotsX.Options(
            "group size" => "1 by $(ngroups)",
            "x descriptions at" => "edge bottom", 
            "xlabels at" => "edge bottom",
            "vertical sep" => "10pt"
        )
        groupplot_options["xmin"] = coefmin
        groupplot_options["xmax"] = coefmax
        merge!(groupplot_options, to_options(getfield(c,:xlabel), :xlabel, Symbol("xlabel style")))
    end
    return groupplot_options
end

function get_nextgroupplot_options(c::Coefplot)
    nextgroupplot_options = get_axis_options(c)
    nextgroupplot_options["scale only axis"] = nothing
    # for groupedcoefplot, title and labels are nodes, instead of options
    for x in [:title, :xlabel, :ylabel]
        delete!(nextgroupplot_options, x)
        delete!(nextgroupplot_options, Symbol("$x style"))
    end
    return nextgroupplot_options
end

# TO-DO: allow adding HBand HLine VBand VLine
const SupportedAddition = Union{PGFPlotsX.HLine, PGFPlotsX.VLine,
                                PGFPlotsX.HBand, PGFPlotsX.VBand,
                                rHLine, rVLine, rHBand, rVBand, Annotation}
"""
convert the Coefplot object to an PGFPlotsX.TikzPicture, note is added
"""
function to_picture(c::Coefplot, other::SupportedAddition ...) 
    if :groupname in propertynames(c.data)
        # it is a groupped coefplot
        # add title, groupname and note
        picture = PGFPlotsX.TikzPicture(to_axis(c, other...))
        if c.vertical
            push!(picture, "\\coordinate (freeze) at (current bounding box.south);")
        else
            push!(picture, "\\coordinate (freeze) at (current bounding box.west);")
        end
        push!(picture, "\\coordinate (title) at (current bounding box.north);")
        gc = group(c)


        for i in 1:(length(gc)-1)
            if c.vertical
                sep = "\\filldraw[fill=gray, draw=black,fill opacity=0.1] (group c$(i)r1.north east) rectangle (group c$(i+1)r1.south west);"
            else
                sep = "\\filldraw[fill=gray, draw=black,fill opacity=0.1] (group c1r$(i+1).north west) rectangle (group c1r$(i).south east);"
            end
            push!(picture, sep)
        end

        for i in 1:length(gc)
            if c.vertical
                grouptag = "\\node[yshift=-1em] at ({group c$(i)r1.center}|-{freeze}) {$(gc[i].first)};"
            else
                grouptag = "\\node[xshift=-1em, rotate=90] at ({freeze}|-{group c1r$(i).center}) {$(gc[i].first)};"
            end
            push!(picture, grouptag)
        end

        push!(picture, "\\node[yshift=1em] at (title) {$(gc[1].second.title.content)};")
        push!(picture, c.note)
    else
        PGFPlotsX.TikzPicture(to_axis(c, other...), c.note)
    end
end
    


"""
convert the Coefplot object to an PGFPlotsX.Axis
"""
function to_axis(c::Coefplot, other::SupportedAddition ...) 
    if :groupname in propertynames(c.data)
        # it is a groupped coefplot
        gc = group(c)
        groupplot_options = get_groupplot_options(gc)
        gp = PGFPlotsX.GroupPlot(groupplot_options);
        for (groupname, c) in gc
            nextgroupplot_options = get_nextgroupplot_options(c)
            plot_options = get_plot_options(c)
            if c.vertical
                push!(gp, nextgroupplot_options, PGFPlotsX.Plot(plot_options,
                    PGFPlotsX.Coordinates(c.data.varname, c.data.b; yerror = errbar_length(c.data, c.level))),
                    other...)
            else
                push!(gp, nextgroupplot_options, PGFPlotsX.Plot(plot_options,
                    PGFPlotsX.Coordinates(c.data.b, c.data.varname; xerror = errbar_length(c.data, c.level))),
                    other...)
            end
        end
        gp
    else
        PGFPlotsX.Axis(get_axis_options(c), to_plot(c), other...)
    end
end

function to_plot(c::Coefplot)
    """
    convert the Coefplot object to an PGFPlotsX.AxisElement
    """
    @assert :groupname ∉ propertynames(c.data)
    # it is regular coefplot
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

errbar_length(data::AbstractDataFrame, level::Real=0.95) = data.se .* abs(quantile(Distributions.TDist(first(data.dof)), (1. - level)/2.))

function rename!(c::Coefplot, ps::Pair{<:AbstractString, <:Any} ...; drop_unmentioned::Bool=true, key_escaped::Bool=true)
    data = c.data
    if key_escaped
        ps = map(ps) do x # convert pair.second to string
            return x.first => string(x.second)
        end
    else
        ps = map(ps) do x # convert pair.second to string
            return latex_escape(x.first) => string(x.second)
        end
    end
    if drop_unmentioned
        data.varname = get.(Ref(Dict(ps)), data.varname, missing)
        data = data[completecases(data),:] # filter out varnames that are not mentioned in pairs
        sorter = intersect(string.(last.(ps)), data.varname) # sorter order is kept the same with the ps, remove redundant naming
    else
        v = get.(Ref(Dict(ps)), data.varname, missing)
        v[ismissing.(v)] = data.varname[ismissing.(v)]
        data.varname = v
        sorter = data.varname
    end
    sorter = latex_escape.(sorter)
    data.varname = latex_escape.(data.varname)
    c.sorter = sorter
    c.data = data
end
