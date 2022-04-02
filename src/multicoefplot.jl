mutable struct MultiCoefplot <: PGFPlotsX.TikzElement
    name::Union{Missing,String}
    note::Union{Missing,AbstractCaption}
    xtitle::Union{Missing,String}
    ytitle::Union{Missing,String}
    dict::OrderedDict{Symbol,Coefplot}
    legends::OrderedDict{Symbol,Union{Legend,Missing}}

    function MultiCoefplot(dict::OrderedDict{Symbol,Coefplot},
                      xtitle::Union{Missing,String}=missing,ytitle::Union{Missing,String}=missing,
                      name::Union{Missing,String}=missing, note::Union{Missing,AbstractCaption}=missing)
        @assert length(dict) > 1 "Can't make a MultiCoefplot out of a singleton"
        new_dict = deepcopy(dict)
        autolegends = OrderedDict()
        for (c_symbol, c, color) in zip(keys(new_dict),values(new_dict),Iterators.cycle(color_palatte))
            if ~all_equal([sc.options for sc in values(c.dict)]) 
                # might allow this in later releases
                throw(AssertionError("nonconforming subplot options within the coefplot labelled" * string(c_symbol)))
            end
            setcolor!(c,get_default_color(color))
            representitive_scoptions = first(values(c.dict)).options
            this_legend = Legend(string(c_symbol),
                                 get_line_options(representitive_scoptions),
                                 merge(get_dot_options(representitive_scoptions), color_as_draw_option(changeopacity(get_default_color(color),0)))) # need to set draw opacity = 0
            push!(autolegends, c_symbol => this_legend)
        end
        new(name, note, xtitle, ytitle, new_dict, autolegends)
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

function setlegends!(m::MultiCoefplot,p::Pair{Symbol,Union{String,Missing}} ...)
end

function MultiCoefplot(pair::Pair{Symbol,Coefplot}...)
    MultiCoefplot(OrderedDict(pair))
end

function PGFPlotsX.print_tex(io::IO, m::MultiCoefplot)
    options = gen_other_option_from_mcoefplot(m)
    merge!(options,gen_legend_options(m))
    scoefplots = gen_scoefplots_from_mcoefplot(m)
    legend_nonmissing = collect(values(filter(x -> ~ismissing(x.second), m.legends)))
    PGFPlotsX.print_tex(io, Axis(options,scoefplots,values(legend_nonmissing)))
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

function gen_legend_options(m::MultiCoefplot)
    legend_nonmissing = filter(x -> ~ismissing(x.second), m.legends)
    PGFPlotsX.Options(Symbol("legend style") => "font=\\fontsize{5.0}{5.0}\\selectfont",
                      Symbol("legend entries") => join([lgd.l for lgd in values(legend_nonmissing)],","))
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