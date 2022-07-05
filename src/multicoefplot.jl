mutable struct MultiCoefplot
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
    interval::Real
    
    # data
    data::Vector{Coefplot} # contains coefplots
    sorter::Vector{String} # sort xticks
    csorter::Vector{String} # is a sorter of coefplots' titles, 
    # should we use names as the identifier? it means that no coefplots should not have the same name.

    # note
    note::Note

    # vertical
    vertical::Bool

    function MultiCoefplot(data::Coefplot ...
                           ;title::Label = Label(), 
                           xlabel::Label = Label(), 
                           ylabel::Label = Label(), 
                           xticklabel::CaptionStyle = CaptionStyle(),
                           yticklabel::CaptionStyle = CaptionStyle(),
                           legend::Legend = Legend(),
                           width::Real = 240, # in line with the tikz default
                           height::Real = 204,
                           interval::MaybeData{Real} = missing,
                           sorter::Vector{String} = String[], # default sorter is empty
                           csorter::Vector{String} = String[], # default csorter is empty
                           note::Note = Note(textwidth=width, anchor=Symbol("north west"), at="(current axis.outer south west)", align=:left, captionstyle=CaptionStyle()), # default note is missing, but keep the box aligned
                           vertical::Bool = true)
        """
        to construct a MultiCoefplot, the minimal invocation is `MultiCoefplot(data)`
        """
        # create a copy
        data_ = collect(data)

        # check length
        @assert length(data_) > 1 "MultiCoefplot cannot be created out of a singleton"

        # default sorter
        if isempty(sorter)
            for c in data_
                append!(sorter, c.sorter)
            end
        end
        sorter = unique!(sorter)

        # override c.vertical with vertical
        for c in data_
            c.vertical = vertical
        end

        # automatic offset
        l = length(data_)
        if ismissing(interval)
            interval = 1/(l+1)
        end
        d = - interval * (l-1)/2
        for c in data_
            c.offset = d
            d = d + interval
        end

        # automatic coloring
        for _args in zip(data_, COLOR_LOOP)
            color!(_args...)
        end

        new(title, xlabel, ylabel, xticklabel, yticklabel, legend, width, height, interval, data_, sorter, csorter, note, vertical)
    end
end

function Base.sort!(m::MultiCoefplot)
    """
    sort the vector of coefplots according to csorter
    """
    sorter_function = c::Coefplot -> first(indexin(c.title, m.csorter))
    sort!(m.data, by=sorter_function)
end

function get_axis_options(m::MultiCoefplot)
    """
    extract all fields in a MultiCoefplot that are related to the options of the axis, and generate such PGFPlotsX.Options
    """
    axis_options = PGFPlotsX.Options()
    for x in [:title, :xlabel, :ylabel]
        if !ismissing(getfield(m,x))
            merge!(axis_options, to_options(getfield(m,x), x, Symbol("$x style")))
        end
    end
    for x in [:xticklabel, :yticklabel]
        if !ismissing(getfield(m,x))
            axis_options[Symbol("$x style")] = to_options(getfield(m,x))
        end
    end
    axis_options[:width] = "$(m.width)pt"
    axis_options[:height] = "$(m.height)pt"
    axis_options[Symbol("legend style")] = to_options(m.legend)
    if m.vertical
        axis_options["symbolic x coords"] = m.sorter
        axis_options["xtick"] = m.sorter # force show all symbolic x coords
        # xmin={[normalized]-0.5}, xmax={[normalized]19.5}
        axis_options["xmin"] = "{[normalized]-0.5}"
        axis_options["xmax"] = "{[normalized]$(length(m.sorter)-0.5)}"
    else
        axis_options["symbolic y coords"] = m.sorter
        axis_options["ytick"] = m.sorter
        axis_options["ymin"] = "{[normalized]-0.5}"
        axis_options["ymax"] = "{[normalized]$(length(m.sorter)-0.5)}"
    end
    return axis_options
end

function to_axis(m::MultiCoefplot, other::SupportedAddition ...)
    """
    convert the MultiCoefplot object to PGFPlotsX.AxisElement (s)
    """
    if !isempty(m.csorter)
        sort!(m)
    end
    axis_options = get_axis_options(m)
    a = PGFPlotsX.Axis(axis_options);
    for c in m.data
        cplot = to_plot(c)
        push!(a, cplot);
        if !ismissing(c.title.content)
            push!(a, PGFPlotsX.LegendEntry(c.title.content));
        end
    end
    for o in other
        push!(a, o);
    end
    return a
end

"""
convert the MultiCoefplot object to an PGFPlotsX.TikzPicture, note is added
"""
to_picture(m::MultiCoefplot, other::SupportedAddition ...) = PGFPlotsX.TikzPicture(to_axis(m, other...), m.note)

function width!(m::MultiCoefplot, w::MaybeData{Real})
    m.width = w
    m.note.textwidth = w
end