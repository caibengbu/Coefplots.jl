mutable struct MultiCoefplot
    name::Union{Null,String}
    note::Union{Null,AbstractCaption}
    xtitle::Union{Null,String}
    ytitle::Union{Null,String}
    dict::OrderedDict{Symbol,Coefplot}
    legends::OrderedDict{Symbol,Union{Legend,Null}}
    legends_options::LegendsOption
    other_components::Vector{Any}
    width::Real
    height::Real
    vertical::Bool

    function MultiCoefplot(dict::OrderedDict{Symbol,Coefplot},
                      xtitle::Union{Null,String}=Null(), 
                      ytitle::Union{Null,String}=Null(),
                      name::Union{Null,String}=Null(), 
                      note::Union{Null,AbstractCaption}=Null(),
                      legends_options::LegendsOption=LegendsOption(), 
                      other_components::Vector{Any}=Any[],
                      width::Real=240, 
                      height::Real=207)
        @assert length(dict) > 1 "Can't make a MultiCoefplot out of a singleton"
        new_dict = deepcopy(dict)
        autolegends = OrderedDict()

        base_locs = Dict(label => i for (i,label) in enumerate(get_unique_syms(new_dict)))

        for (c_symbol, c, color) in zip(keys(new_dict),values(new_dict),COLOR_PALATTE)
            check_if_all_singlecoefplot_options_conform(c) 
            setcolor!(c, color)
            c.vertical = false # reset all coefplots to non vertical
            for (k,v) in c.dict
                @assert haskey(base_locs,k)
                v.thiscoef_loc = base_locs[k]
            end
            representitive_scoptions = first(values(c.dict)).options
            this_legend = Legend(string(c_symbol),representitive_scoptions)
            push!(autolegends, c_symbol => this_legend)
        end
        new(name, note, xtitle, ytitle, new_dict, autolegends, legends_options, other_components, width, height, false)
    end
end

function set_dot_shape!(m::MultiCoefplot, shape_name::Symbol)
    for c in values(m.dict)
        set_dot_shape!(c, shape_name)
    end
    return m
end

function get_unique_syms(m::MultiCoefplot)
    syms = Symbol[]
    for c in values(m.dict)
        append!(syms, keys(c.dict))
    end
    unique!(syms)
    return syms
end

function get_unique_syms(d::OrderedDict{Symbol,Coefplot})
    syms = Symbol[]
    for c in values(d)
        append!(syms, keys(c.dict))
    end
    unique!(syms)
    return syms
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
    m.note = AbstractCaption(note,  default_note_options(m))
    return m
end

function setlegends!(m::MultiCoefplot, ps::Pair{Symbol,T} ...) where T <: Union{String, Missing}
    for p in ps
        if ismissing(p.second)
            m.legends[p.first] = Null()
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

function transpose!(m::MultiCoefplot)
    m.vertical = ~m.vertical
    for c in values(m.dict)
        c.vertical = m.vertical
    end
    xtitle = deepcopy(m.xtitle)
    m.xtitle = deepcopy(m.ytitle)
    m.ytitle = xtitle
    return m
end

function MultiCoefplot(pair::Pair{Symbol,Coefplot}...)
    MultiCoefplot(OrderedDict(pair))
end

function to_plotable(m::MultiCoefplot, interval::Union{Missing,Real}=missing)
    options = gen_other_option_from_mcoefplot(m)
    legend_nonmissing = collect(values(filter(x -> ~isnull(x.second), m.legends)))
    legend_labels = PGFPlotsX.Options(Symbol("legend entries") => join([lgd.l for lgd in values(legend_nonmissing)],","))
    merge!(options,gen_legend_options(m.legends_options),legend_labels)
    scs = gen_scoefplots_from_mcoefplot(m, interval)
    Plotable(options, m.note, scs, m.other_components, values(legend_nonmissing))
end

function gen_other_option_from_mcoefplot(m::MultiCoefplot)
    specified_options_list = get_coefplot_options.(values(m.dict))
    merged_option_1 = merge(specified_options_list...)
    
    options_list = gen_other_option_from_coefplot.(values(m.dict);seperate_line=true)
    merged_option_2 = merge_merge([[:xtick, :xticklabels], [:ytick, :yticklabels]], options_list...)
    merged_option = merge(merged_option_1,merged_option_2)
    
    has_x_ticks = haskey(merged_option.dict,Symbol("extra x ticks"))
    has_y_ticks = haskey(merged_option.dict,Symbol("extra y ticks"))
    if has_x_ticks
        xtick = deepcopy(merged_option[:xtick])
        sorted_xtick = sort(xtick)
        merged_option[Symbol("extra x ticks")] = [(sorted_xtick[i]+sorted_xtick[i+1])/2 for i in 1:(length(sorted_xtick)-1)]
    end
    if has_y_ticks
        ytick = deepcopy(merged_option[:ytick])
        sorted_ytick = sort(ytick)
        merged_option[Symbol("extra x ticks")] = [(sorted_ytick[i]+sorted_ytick[i+1])/2 for i in 1:(length(sorted_ytick)-1)]
    end

    merged_option[:xmin] = minimum([option[:xmin] for option in options_list])
    merged_option[:ymin] = minimum([option[:ymin] for option in options_list])
    merged_option[:xmax] = maximum([option[:xmax] for option in options_list])
    merged_option[:ymax] = maximum([option[:ymax] for option in options_list])
    merged_option[:width] = "$(m.width)pt"
    merged_option[:height] = "$(m.height)pt"

    labels_and_titles = PGFPlotsX.Options()
    if ~isnull(m.xtitle)
        labels_and_titles[:xlabel] = m.xtitle
        labels_and_titles[Symbol("label style")] = "{font=\\footnotesize}"
    end 
    if ~isnull(m.ytitle)
        labels_and_titles[:ylabel] = m.ytitle
        labels_and_titles[Symbol("label style")] = "{font=\\footnotesize}"
    end
    if ~isnull(m.name)
        labels_and_titles[:title] = m.name
        labels_and_titles[Symbol("title style")] = "{font=\\large}"
    end

    return merge!(merged_option,labels_and_titles) # give labels_and_titles better priority
end

function gen_scoefplots_from_mcoefplot(m::MultiCoefplot,interval::Union{Missing,Real}=missing) # need to rework. identify which singlecoefplot should be together. This implementation is very fragile
    v = PGFPlotsX.TikzElement[]
    l = length(m.dict)
    if ismissing(interval)
        interval = 1/(l+1)
    end
    d = - interval * (l-1)/2
    for coefplot in values(m.dict)
        shifted_c = shift(coefplot,d)
        d = d + interval
        append!(v,collect(shifted_c))
    end
    return v
end

default_note_options(p::MultiCoefplot) = PGFPlotsX.Options( :name => "note", 
                                                            :anchor => "north west", 
                                                            :font => "{\\fontsize{4.5}{4.5}\\selectfont}",
                                                            Symbol("text width") => "$(p.width)pt", 
                                                            :at => "(current axis.outer south west)")
