mutable struct MultiCoefplot <: PGFPlotsX.TikzElement
    name::Union{Missing,String}
    note::Union{Missing,AbstractCaption}
    xtitle::Union{Missing,String}
    ytitle::Union{Missing,String}
    dict::OrderedDict{Symbol,Coefplot}


    function MultiCoefplot(dict::OrderedDict{Symbol,Coefplot},
                      xtitle::Union{Missing,String}=missing,ytitle::Union{Missing,String}=missing,
                      name::Union{Missing,String}=missing, note::Union{Missing,AbstractCaption}=missing)
        @assert length(dict) > 1 "Can't make a MultiCoefplot out of a singleton"
        new_dict = deepcopy(dict)
        for (sc, color) in zip(values(new_dict),Iterators.cycle(color_palatte))
            setcolor!(sc,get_default_color(color))
        end
        new(name, note, xtitle, ytitle, new_dict)
    end
end

function MultiCoefplot(pair::Pair{Symbol,Coefplot}...)
    MultiCoefplot(OrderedDict(pair))
end

function PGFPlotsX.print_tex(io::IO, m::MultiCoefplot)
    options = gen_other_option_from_mcoefplot(m)
    scoefplots = gen_scoefplots_from_mcoefplot(m)
    PGFPlotsX.print_tex(io, Axis(options,scoefplots))
    if m.note !== missing
        note_default_option = default_note_options()
        PGFPlotsX.print_tex(io, m.note, note_default_option)
    end
end

function gen_other_option_from_mcoefplot(m::MultiCoefplot)
    options_list = gen_other_option_from_coefplot.(values(m.dict);seperate_line=true)
    specified_options_list = get_coefplot_options.(values(m.dict))
    merged_option = reduce(merge,reverse(vcat(options_list, specified_options_list)))
    merged_option[:xmin] = minimum([option[:xmin] for option in options_list])
    merged_option[:ymin] = minimum([option[:ymin] for option in options_list])
    merged_option[:xmax] = maximum([option[:xmax] for option in options_list])
    merged_option[:ymax] = maximum([option[:ymax] for option in options_list])

    labels_and_titles = PGFPlotsX.Options()
    if m.xtitle !== missing
        labels_and_titles[:xlabel] = m.xtitle
        labels_and_titles[Symbol("label style")] = "{font=\\footnotesize}"
    end 
    if m.ytitle !== missing
        labels_and_titles[:ylabel] = m.ytitle
        labels_and_titles[Symbol("label style")] = "{font=\\footnotesize}"
    end
    if m.name !== missing
        labels_and_titles[:title] = m.name
        labels_and_titles[Symbol("title style")] = "{font=\\large}"
    end

    return merge!(labels_and_titles,merged_option)
end

function gen_scoefplots_from_mcoefplot(m::MultiCoefplot,interval::Union{Missing,Real}=missing)
    v = Vector{SinglecoefPlot}()
    l = length(m.dict)
    if interval === missing
        interval = 1/(l+1)
    end
    d = - interval * (l-1)/2
    for coefplot in values(m.dict)
        shifted_c = shift(coefplot,d)
        d = d + interval
        append!(v,values(shifted_c.dict))
    end
    return v
end