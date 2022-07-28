mutable struct GroupedCoefplot
    # axis args
    title::Label
    xlabel::Label
    ylabel::Label
    xticklabel::CaptionStyle
    yticklabel::CaptionStyle
    width::Real
    height::Real

    # addplot args
    # keepmark::Bool
    # keepconnect::Bool
    # mark::Mark
    # errormark::Mark
    # errorbar::Bar
    # connect::Bar
    # offset::Real # use only in Multicoefplot
    
    # data
    data::Vector{Pair{Any, Coefplot}}
    # sorter::Vector{String} # is a sorter of varnames
    # level::Real # confidence level

    # note
    note::Note

    # vertical
    vertical::Bool

    # TO-DO: allow other components in the struct, instead of plugging in to_picture

    function GroupedCoefplot(data::Vector{Pair{Any, Coefplot}} = Pair{Any, Coefplot}[]
                            ;title::Label = Label(), 
                            xlabel::Label = Label(), 
                            ylabel::Label = Label(), 
                            xticklabel::CaptionStyle = CaptionStyle(),
                            yticklabel::CaptionStyle = CaptionStyle(),
                            width::Real = 240, # in line with the tikz default
                            height::Real = 204,
                            note::MaybeData{Note} = Note(anchor=Symbol("north west"), at="(current bounding box.south west)", align=:left, captionstyle=CaptionStyle()),
                            vertical::Bool = true,
                            kwargs ...)
        """
        to construct a GroupedCoefplot.
        """
        new(title, xlabel, ylabel, xticklabel, yticklabel, width, height, data, note, vertical)
    end
end

function GroupedCoefplot(gdata::GroupedDataFrame; kwargs...)
    g = GroupedCoefplot(; kwargs...)
    ncoef = length(gdata.groups)
    # build data for GroupedCoefplot
    data = map(pairs(gdata)) do ((groupname,), subdata)
        _c = Coefplot(subdata; kwargs...) # build the Coefplot first 
        nsubcoef = size(subdata,1)
        if _c.vertical
            _c.width *= nsubcoef/ncoef # compute the width for each sub plot
        else
            _c.height *= nsubcoef/ncoef
        end
        filter!(x->x in subdata.varname, _c.sorter) # filter sorter
        return groupname => deepcopy(_c)
    end
    if ~g.vertical
        # because groupplot draw from top to down and left to right
        reverse!(data)
    end
    g.data = data
    return g
end

function get_groupplot_options(g::GroupedCoefplot)
    data = g.data
    ngroups = length(data)
    actualmin = minimum(map(data) do x
        c = x.second
        minimum(c.data.b - Coefplots.errbar_length(c.data, c.level))
    end)
    actualmax = maximum(map(data) do x
        c = x.second
        maximum(c.data.b + Coefplots.errbar_length(c.data, c.level))
    end)
    actualrange = actualmax - actualmin
    coefmin = actualmin - actualrange * 0.15
    coefmax = actualmax + actualrange * 0.15

    groupplot_options = PGFPlotsX.Options()
    if g.vertical
        groupplot_options["group style"] = PGFPlotsX.Options(
            "group size" => "$(ngroups) by 1",
            "y descriptions at" => "edge left", 
            "ylabels at" => "edge left",
            "horizontal sep" => "10pt"
        )
        groupplot_options["ymin"] = coefmin
        groupplot_options["ymax"] = coefmax
        merge!(groupplot_options, to_options(getfield(g,:ylabel), :ylabel, Symbol("ylabel style")))
    else
        groupplot_options["group style"] = PGFPlotsX.Options(
            "group size" => "1 by $(ngroups)",
            "x descriptions at" => "edge bottom", 
            "xlabels at" => "edge bottom",
            "vertical sep" => "10pt"
        )
        groupplot_options["xmin"] = coefmin
        groupplot_options["xmax"] = coefmax
        merge!(groupplot_options, to_options(getfield(g,:xlabel), :xlabel, Symbol("xlabel style")))
    end
    return groupplot_options
end


function get_nextgroupplot_options(c::Coefplot)
    nextgroupplot_options = get_axis_options(c)
    # for groupedcoefplot, title and labels are nodes, instead of options
    for x in [:title, :xlabel, :ylabel]
        delete!(nextgroupplot_options, x)
        delete!(nextgroupplot_options, Symbol("$x style"))
    end
    return nextgroupplot_options
end

function to_picture(g::GroupedCoefplot, other::SupportedAddition ...)
    p = PGFPlotsX.TikzPicture(to_axis(g, other...))

    # mark important positions for later use
    if g.vertical
        push!(p, "\\coordinate (freeze) at (current bounding box.south);")
    else
        push!(p, "\\coordinate (freeze) at (current bounding box.west);")
    end
    push!(p, "\\coordinate (title) at (current bounding box.north);")

    data = g.data
    n = length(data)

    # draw groupplot separation rectangle
    for i in 1:(n-1)
        if g.vertical
            sep = "\\filldraw[fill=gray, draw=black,fill opacity=0.1] (group c$(i)r1.north east) rectangle (group c$(i+1)r1.south west);"
        else
            sep = "\\filldraw[fill=gray, draw=black,fill opacity=0.1] (group c1r$(i+1).north west) rectangle (group c1r$(i).south east);"
        end
        push!(p, sep)
    end

    # draw groupplot labels
    for i in 1:n
        if g.vertical
            grouptag = "\\node[yshift=-1em] at ({group c$(i)r1.center}|-{freeze}) {$(data[i].first)};"
        else
            grouptag = "\\node[xshift=-1em, rotate=90] at ({freeze}|-{group c1r$(i).center}) {$(data[i].first)};"
        end
        push!(p, grouptag)
    end

    push!(p, "\\node[yshift=1em] at (title) {$(g.title.content)};")
    push!(p, g.note)
end

function to_axis(g::GroupedCoefplot, other::SupportedAddition ...) 
    groupplot_options = get_groupplot_options(g)
    gp = PGFPlotsX.GroupPlot(groupplot_options);
    for (groupname, c) in g.data
        nextgroupplot_options = get_nextgroupplot_options(c)
        plot_options = get_plot_options(c)
        if g.vertical
            push!(gp, nextgroupplot_options, PGFPlotsX.Plot(plot_options,
                PGFPlotsX.Coordinates(c.data.varname, c.data.b; yerror = errbar_length(c.data, c.level))),
                other...)
        else
            push!(gp, nextgroupplot_options, PGFPlotsX.Plot(plot_options,
                PGFPlotsX.Coordinates(c.data.b, c.data.varname; xerror = errbar_length(c.data, c.level))),
                other...)
        end
    end
    return gp
end