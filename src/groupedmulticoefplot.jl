mutable struct GroupedMultiCoefplot
    # axis args
    title::Label
    xlabel::Label
    ylabel::Label
    xticklabel::CaptionStyle
    yticklabel::CaptionStyle
    legend::Legend
    width::Real
    height::Real

    # addplot args
    interval::MaybeData{Real}
    
    # data
    data::Vector{Pair{T, MultiCoefplot}} where T

    # note
    note::Note

    # vertical
    vertical::Bool

    # TO-DO: allow other components in the struct, instead of plugging in to_picture

    function GroupedMultiCoefplot(data::Vector{Pair{T, MultiCoefplot}} where T = Pair{Any, MultiCoefplot}[]
                                ;title::Label = Label(), 
                                xlabel::Label = Label(), 
                                ylabel::Label = Label(), 
                                xticklabel::CaptionStyle = CaptionStyle(),
                                yticklabel::CaptionStyle = CaptionStyle(),
                                legend::Legend = Legend(),
                                width::Real = 240, # in line with the tikz default
                                height::Real = 204,
                                interval::MaybeData{Real} = missing,
                                note::MaybeData{Note} = Note(anchor=Symbol("north west"), at="(current bounding box.south west)", align=:left, captionstyle=CaptionStyle()),
                                vertical::Bool = true,
                                kwargs ...)
        """
        to construct a GroupedMultiCoefplot.
        """

        new(title, xlabel, ylabel, xticklabel, yticklabel, legend, width, height, interval, data, note, vertical)
    end
end

function GroupedMultiCoefplot(data::Vector{Pair{T, GroupedCoefplot}} where T; kwargs...) 
    df = vcat(map(data) do (multi_tag, gc)
        vcat(map(gc.data) do (group_tag, c)
            df = c.data
            df[!, :multi_tag] .= multi_tag
            df[!, :group_tag] .= group_tag
            return df
        end ...)
    end ...) # 

    ms = map([groupby(df, :group_tag)...]) do subdf
        group_tag = first(subdf[!, :group_tag])
        cs = map([groupby(subdf, :multi_tag)...]) do subsubdf
            multi_tag = first(subsubdf[!, :multi_tag])
            Coefplot(subsubdf; title=Label(content=multi_tag), kwargs...)
        end
        m = MultiCoefplot(cs...; kwargs...)
        group_tag => m
    end

    # resize each multicoefoplot
    ttl_ncoef = sum(map(ms) do x
        m = x.second
        length(m.sorter)
    end)

    for (group_tag, m) in ms
        if m.vertical
            m.width *= length(m.sorter)/ttl_ncoef
        else
            m.height *= length(m.sorter)/ttl_ncoef
        end
    end
    GroupedMultiCoefplot(ms; kwargs...)
end


function get_groupplot_options(g::GroupedMultiCoefplot)
    data = g.data
    ngroups = length(data)
    actualmin = minimum(map(data) do x
        m::MultiCoefplot = x.second
        minimum(m)
    end)
    actualmax = maximum(map(data) do x
        m::MultiCoefplot = x.second
        maximum(m)
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


function get_nextgroupplot_options(m::MultiCoefplot)
    nextgroupplot_options = get_axis_options(m)
    # for groupedmulticoefplot, title and labels are nodes, instead of options
    for x in [:title, :xlabel, :ylabel]
        delete!(nextgroupplot_options, x)
        delete!(nextgroupplot_options, Symbol("$x style"))
    end
    # for groupedmulticoefplot, avoid duplicated legends
    for x in [:title, :xlabel, :ylabel]
        delete!(nextgroupplot_options, x)
        delete!(nextgroupplot_options, Symbol("$x style"))
    end
    return nextgroupplot_options
end

function to_picture(g::GroupedMultiCoefplot, other::SupportedAddition ...)
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

function to_axis(g::GroupedMultiCoefplot, other::SupportedAddition ...) 
    groupplot_options = get_groupplot_options(g)
    gp = PGFPlotsX.GroupPlot(groupplot_options);
    for (groupname, m) in g.data
        if !isempty(m.csorter)
            sort!(m)
        end
        nextgroupplot_options = get_nextgroupplot_options(m)
        cplots = []
        for c in m.data
            push!(cplots, to_plot(c))
            if !ismissing(c.title.content)
                # push!(cplots, PGFPlotsX.LegendEntry(c.title.content));
            end
        end
        push!(gp, nextgroupplot_options, cplots);
    end
    return gp
end