"""
    GroupedMultiCoefplot

A `GroupedMultiCoefplot` object. It contains the all information for which a set of multiple `GroupedCoefplot`s should be plotted together. The keyword arguements of the constructor are all optional.

# Constructors
```julia
GroupedMultiCoefplot(data::Pair{<:Any, GroupedCoefplot} ...;  <keyword arguments>)
GroupedMultiCoefplot(data::Pair{<:Any, MultiCoefplot} ...;  <keyword arguments>)
```

# Arguments
- `title::Label`: the title to the plot.
- `xlabel::Label`: the xlabel to the plot.
- `ylabel::Label`: the ylabel to the plot.
- `xticklabel::CaptionStyle`: the style of the xtick.
- `yticklabel::CaptionStyle`: the style of the ytick.
- `show_legend::Union{Vector{Bool}, Missing} = missing`: a boolean vector specifying which legend of the subplot should be shown. The default is to show only the first legend.
- `width::Real = 240`: the width of the axis frame
- `height::Real = 204`: the height of the axis frame
- `interval::Union{Real,Missing} = missing`: determines the distance between each `Coefplot`. Each `Coefplot`'s `offset` is computed according to this.
- `note::Union{Note, Missing}`: a note that is attached to the south of the plot.
- `vertical::Bool = true`: if `true`, the errorbars are parallel to y axis; if `false`, the errorbars are parallel to x axis.
"""
mutable struct GroupedMultiCoefplot
    # axis args
    title::Label
    xlabel::Label
    ylabel::Label
    xticklabel::CaptionStyle
    yticklabel::CaptionStyle
    show_legend::Vector{Bool}
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
end

function GroupedMultiCoefplot(data::Pair{<:Any, MultiCoefplot} ...
    ;title::Label = Label(), 
    xlabel::Label = Label(), 
    ylabel::Label = Label(), 
    xticklabel::CaptionStyle = CaptionStyle(),
    yticklabel::CaptionStyle = CaptionStyle(),
    show_legend::MaybeData{Vector{Bool}} = missing,
    width::Real = 240, # in line with the tikz default
    height::Real = 204,
    interval::MaybeData{Real} = missing,
    note::MaybeData{Note} = Note(anchor=Symbol("north west"), at="(current bounding box.south west)", align=:left, captionstyle=CaptionStyle()),
    vertical::Bool = true,
    kwargs ...)

    data = collect(data)
    ngroups = length(data)
    if ismissing(show_legend)
        show_legend = falses(ngroups)
        show_legend[1] = true # default: show only the first legend
    end

    GroupedMultiCoefplot(title, xlabel, ylabel, xticklabel, yticklabel, show_legend, width, height, interval, data, note, vertical)
end

function GroupedMultiCoefplot(data::Pair{<:Any, GroupedCoefplot} ...; kwargs...) 
    data = collect(data)
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
    GroupedMultiCoefplot(ms...; kwargs...)
end

"""
    get_nextgroupplot_options(g::GroupedMultiCoefplot)

Renders the properties of a `GroupedMultiCoefplot` object as options of the `\\begin{groupplot}`
"""
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

"""
    get_nextgroupplot_options(m::MultiCoefplot)

Renders the properties of a `MultiCoefplot` object as options of the `\\begin{nextgroupplot}`
"""
function get_nextgroupplot_options(m::MultiCoefplot)
    nextgroupplot_options = get_axis_options(m)
    # for groupedmulticoefplot, title and labels are nodes, instead of options
    for x in [:title, :xlabel, :ylabel]
        delete!(nextgroupplot_options, x)
        delete!(nextgroupplot_options, Symbol("$x style"))
    end
    return nextgroupplot_options
end

"""
    to_picture(m::GroupedMultiCoefplot, other::SupportedAddition ...)

convert the `GroupedMultiCoefplot` object to an `PGFPlotsX.TikzPicture`. 
Other supported components are allowed and appended after the `GroupedMultiCoefplot` within the axis. 
Note is added.
"""
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
    if ~ismissing(g.title.content)
        push!(p, "\\node[yshift=1em] at (title) {$(g.title.content)};")
    end
    push!(p, g.note)
end

"""
    to_axis(g::GroupedMultiCoefplot, other::SupportedAddition ...)

Converts the GroupedMultiCoefplot object to a PGFPlotsX.Axis object. 
Other supported components are allowed and appended after the `GroupedMultiCoefplot` within the axis. 
"""
function to_axis(g::GroupedMultiCoefplot, other::SupportedAddition ...) 
    groupplot_options = get_groupplot_options(g)
    gp = PGFPlotsX.GroupPlot(groupplot_options);
    for ((groupname, m), is_show_legend) in zip(g.data, g.show_legend)
        if !isempty(m.csorter)
            sort!(m)
        end
        nextgroupplot_options = get_nextgroupplot_options(m)
        cplots = []
        for c in m.data
            push!(cplots, to_plot(c))
            if !ismissing(c.title.content)
                if is_show_legend
                    push!(cplots, PGFPlotsX.LegendEntry(c.title.content));
                end
            end
        end
        push!(gp, nextgroupplot_options, cplots);
    end
    return gp
end