mutable struct MultiCoefplot <: PGFPlotsX.TikzElement
    name::Union{Missing,String}
    note::Union{Missing,AbstractCaption}
    xtitle::Union{Missing,String}
    ytitle::Union{Missing,String}
    dict::OrderedDict{Symbol,Coefplot}
    legends::OrderedDict{Symbol,Union{Legend,Missing}}
    legends_options::LegendsOption
    other_components::Vector{Any}

    function MultiCoefplot(dict::OrderedDict{Symbol,Coefplot},
                      xtitle::Union{Missing,String}=missing,ytitle::Union{Missing,String}=missing,
                      name::Union{Missing,String}=missing, note::Union{Missing,AbstractCaption}=missing,
                      legends_options::LegendsOption=LegendsOption(),other_components::Vector{Any}=Vector{Any}())
        @assert length(dict) > 1 "Can't make a MultiCoefplot out of a singleton"
        new_dict = deepcopy(dict)
        autolegends = OrderedDict()
        for (c_symbol, c, color) in zip(keys(new_dict),values(new_dict),Iterators.cycle(color_palatte))
            check_if_all_singlecoefplot_options_conform(c)
            setcolor!(c,get_default_color(color))
            representitive_scoptions = first(values(c.dict)).options
            this_legend = Legend(string(c_symbol),representitive_scoptions)
            push!(autolegends, c_symbol => this_legend)
        end
        new(name, note, xtitle, ytitle, new_dict, autolegends, legends_options, other_components)
    end
end

function setxtitle!(m::MultiCoefplot, x::String)
    m.xtitle = x
    return m
end

function setytitle!(m::MultiCoefplot, y::String)
    m.ytitle = y
    return m
end

function setname!(m::MultiCoefplot, name::String)
    m.name = name
    return m
end

function includenote!(m::MultiCoefplot, note::String)
    m.note = AbstractCaption(note)
    return m
end

function setlegends!(m::MultiCoefplot, ps::Pair{Symbol,T} ...) where T <: Union{String, Missing}
    for p in ps
        if ismissing(p.second)
            m.legends[p.first] = missing
        else
            c = m.dict[p.first]
            check_if_all_singlecoefplot_options_conform(c)
            representitive_scoptions = first(values(c.dict)).options
            m.legends[p.first] = Legend(p.second, representitive_scoptions)
        end
    end
end

function addcomponent!(m::MultiCoefplot, v::T) where T <: Union{VLine,VBand,HLine,HBand}
    push!(m.other_components,v)
    return m
end

function clearcomponents!(m::MultiCoefplot)
    m.other_components = Vector{Any}()
    return m
end


function MultiCoefplot(pair::Pair{Symbol,Coefplot}...)
    MultiCoefplot(OrderedDict(pair))
end

function PGFPlotsX.print_tex(io::IO, m::MultiCoefplot)
    options = gen_other_option_from_mcoefplot(m)
    legend_nonmissing = collect(values(filter(x -> ~ismissing(x.second), m.legends)))
    legend_labels = PGFPlotsX.Options(Symbol("legend entries") => join([lgd.l for lgd in values(legend_nonmissing)],","))
    merge!(options,gen_legend_options(m.legends_options),legend_labels)

    scoefplots = gen_scoefplots_from_mcoefplot(m)
    PGFPlotsX.print_tex(io, Axis(options,m.other_components,scoefplots,values(legend_nonmissing)))
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

    return merge!(merged_option,labels_and_titles) # give labels_and_titles better priority
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