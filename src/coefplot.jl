mutable struct Coefplot <: PGFPlotsX.TikzElement
    name::Union{Missing,String}
    note::Union{Missing,AbstractCaption}
    xtitle::Union{Missing,String}
    ytitle::Union{Missing,String}
    dict::OrderedDict{Symbol,SinglecoefPlot}
    options::CoefplotOption

    # create Coefplot from combining vec_singlecoefplot and name, note, xtitle, ytitle
    function Coefplot(dict::OrderedDict{Symbol,SinglecoefPlot},
                      xtitle::Union{Missing,String}=missing,ytitle::Union{Missing,String}=missing,
                      name::Union{Missing,String}=missing, note::Union{Missing,AbstractCaption}=missing,options=default_coefplot_options())
        new(name, note, xtitle, ytitle, dict, options)
    end
end

function setxtitle!(c::Coefplot, x::String)
    c.xtitle = x
    return c
end

function setytitle!(c::Coefplot, y::String)
    c.ytitle = y
    return c
end

function setname!(c::Coefplot, name::String)
    c.name = name
    return c
end

function includenote!(c::Coefplot, note::String)
    c.note = AbstractCaption(note)
    return c
end

function setcolor!(c::Coefplot, color::Color)
    for sc in values(c.dict)
        sc.options.dotcolor = color
        sc.options.linecolor = color
    end
    return c
end

function gen_other_option_from_coefplot(coefplot::Coefplot;vertical::Bool=false,seperate_line::Bool=false)
    singlecoefplots = values(coefplot.dict)
    xtick = [singlecoefplot.thiscoef_loc for singlecoefplot in singlecoefplots]
    xticklabels = [singlecoefplot.thiscoef_label for singlecoefplot in singlecoefplots]
    xmin, xmax = extrema(xtick)
    ymin = minimum([singlecoefplot.confint_lb for singlecoefplot in singlecoefplots])
    ymax = maximum([singlecoefplot.confint_ub for singlecoefplot in singlecoefplots])
    xaxis_lb = xmin - (xmax - xmin)/(length(singlecoefplots)-1) * 0.5
    xaxis_ub = xmax + (xmax - xmin)/(length(singlecoefplots)-1) * 0.5
    yaxis_lb = ymin - (ymax - ymin)*0.1
    yaxis_ub = ymax + (ymax - ymin)*0.1
    labels_and_titles = PGFPlotsX.Options()
    if coefplot.xtitle !== missing
        labels_and_titles[:xlabel] = coefplot.xtitle
        labels_and_titles[Symbol("label style")] = "{font=\\footnotesize}"
    end 
    if coefplot.ytitle !== missing
        labels_and_titles[:ylabel] = coefplot.ytitle
        labels_and_titles[Symbol("label style")] = "{font=\\footnotesize}"
    end
    if coefplot.name !== missing
        labels_and_titles[:title] = coefplot.name
        labels_and_titles[Symbol("title style")] = "{font=\\large}"
    end
    if seperate_line
        sorted_xtick = sort(xtick)
        if vertical
            other_options = PGFPlotsX.Options(
                :xmin => xaxis_lb, :xmax => xaxis_ub, 
                :ymin => yaxis_lb, :ymax => yaxis_ub, 
                :xtick => xtick, :xticklabels => xticklabels,
                Symbol("extra x ticks") => [(sorted_xtick[i]+sorted_xtick[i+1])/2 for i in 1:(length(sorted_xtick)-1)], 
                Symbol("extra x tick style") => "{grid=major,grid style={dashed,gray!25}}",
                Symbol("extra x tick labels") => "{}")
        else
            other_options = PGFPlotsX.Options(
                :ymin => xaxis_lb, :ymax => xaxis_ub, 
                :xmin => yaxis_lb, :xmax => yaxis_ub, 
                :ytick => xtick, :yticklabels => xticklabels,
                Symbol("extra y ticks") => [(sorted_xtick[i]+sorted_xtick[i+1])/2 for i in 1:(length(sorted_xtick)-1)],
                Symbol("extra y tick style") => "{grid=major,grid style={dashed,gray!25}}",
                Symbol("extra y tick labels") => "{}")
        end
    else
        if vertical
            other_options = PGFPlotsX.Options(
                :xmin => xaxis_lb, :xmax => xaxis_ub, 
                :ymin => yaxis_lb, :ymax => yaxis_ub, 
                :xtick => xtick, :xticklabels => xticklabels)
        else
            other_options = PGFPlotsX.Options(
                :ymin => xaxis_lb, :ymax => xaxis_ub, 
                :xmin => yaxis_lb, :xmax => yaxis_ub, 
                :ytick => xtick, :yticklabels => xticklabels)
        end
    end
    return merge!(labels_and_titles,other_options)
end

Base.getindex(coefplot::Coefplot, args...; kwargs...) = getindex(coefplot.dict, args...; kwargs...)
Base.setindex!(coefplot::Coefplot, args...; kwargs...) = (setindex!(coefplot.dict, args...; kwargs...); coefplot)
Base.delete!(coefplot::Coefplot, args...; kwargs...) = (delete!(coefplot.dict, args...; kwargs...); coefplot)
Base.haskey(coefplot::Coefplot, args...; kwargs...) = haskey(coefplot.dict, args...; kwargs...)
get_coefplot_options(c::Coefplot) = get_coefplot_options(c.options)
cpad(str::String,n::Int64,fill::String=" ") = rpad(lpad(str,(n+length(str))÷2, fill),n, fill)

function Base.show(io::IO, coefplot::Coefplot)
    # format a little
    ks = []
    locs = []
    pt_ests = []
    confints = []
    labels = []

    for (k,v) in coefplot.dict
        push!(ks,k)
        push!(locs, Printf.format(Printf.Format("%.4g"),v.thiscoef_loc))
        push!(pt_ests, Printf.format(Printf.Format("%.4g"),v.point_est))
        push!(confints, "("*Printf.format(Printf.Format("%.4g"),v.confint_lb)*", "*Printf.format(Printf.Format("%.4g"),v.confint_ub)*")")
        push!(labels, String.(v.thiscoef_label))
    end

    max_k_len = maximum(push!(length.(string.(ks)),3)) # length("Key") == 3
    max_loc_len = maximum(push!(length.(locs),8)) # length("Location") == 8
    max_pe_len = maximum(push!(length.(pt_ests),14)) # length("Point Estimate") == 14
    max_conf_len = maximum(push!(length.(confints),19)) # length("Confidence Interval") == 19
    max_label_len = maximum(push!(length.(labels),5)) # length("Label") == 5

    format_vec(key,loc,point_est,confint,label;fill=" ",sep="   ") = join([lpad(key, max_k_len, fill),
                                                        cpad(loc, max_loc_len, fill),
                                                        cpad(point_est, max_pe_len, fill),
                                                        cpad(confint, max_conf_len, fill),
                                                        cpad(label, max_label_len, fill)],sep)

    bottom_and_top_rule = format_vec("─", "─", "─", "─", "─"; fill="─", sep="───")
    width = length(bottom_and_top_rule)
    if coefplot.name !== missing
        println(io, cpad("─── * Coefplot Name: "*coefplot.name*" * ───",width))
    else
        println(io, cpad("─── * Unnamed Coefplot * ───",width))
    end  
    println(io, bottom_and_top_rule)                                           
    subtitles = format_vec("Key", "Location", "Point Estimate", "Confidence Interval", "Label")
    println(io, subtitles)
    midrule = format_vec("─", "─", "─", "─", "─"; fill="─", sep="───")
    println(io, midrule)
    for i in 1:length(ks)
        item = format_vec(ks[i], locs[i], pt_ests[i], confints[i], labels[i])
        println(io, item)
    end
    println(io, bottom_and_top_rule)
end
    

function Base.pushfirst!(d::OrderedDict{Symbol,SinglecoefPlot}, p::Pair{Symbol,SinglecoefPlot} ...; overwrite::Bool=true, suppress::Bool=false)
    for pp in p
        if haskey(d,pp.first)
            if overwrite
                if ~suppress
                    @warn "label $(pp.first) already exists in the coefplot, overwriting ..."
                end
                push!(d,pp)
            end
            throw(KeyError("label $(pp.first) already exists in the coefplot, please relabel your coefficients, or specify overwrite=true."))
        else
            push!(d,pp)
        end
    end
    return d
end

function Base.push!(coefplot::Coefplot, other::Pair{Symbol, SinglecoefPlot} ...)
    all_keys = vcat(keys(coefplot.dict),[other[1] for this_other in other])
    @assert length(unique(all_keys)) == length(all_keys) "there are repeated keys!"
    push!(coefplot.dict, other...) # add new singlecoefplot to coefplot, will overwrite if key coincides
    coefplot
end


function PGFPlotsX.print_tex(io::IO, coefplot::Coefplot)
    # allow change color of a singlecoefplot (use inherit_options_from_coefplot as default)
    # allow print title and note
    default_coefplot_options = gen_other_option_from_coefplot(coefplot)
    specified_options = get_coefplot_options(coefplot)
    options = merge(default_coefplot_options,specified_options) # give options in coefplot attributes a higher priority
    PGFPlotsX.print_tex(io, Axis(options, collect(values(coefplot.dict))))
    if coefplot.note !== missing
        note_default_option = default_note_options()
        PGFPlotsX.print_tex(io, coefplot.note, note_default_option)
    end
end

function copy_options!(coefplot::Coefplot, to_be_copyed::Coefplot, exceptions::Vector{Symbol})
    for fieldname in fieldnames(typeof(coefplot))
        if fieldname ∉ exceptions
            setfield!(coefplot,fieldname,getfield(to_be_copyed,fieldname))
        end
    end
    return coefplot
end

function copy_options!(coefplot::Coefplot, to_be_copyed::Coefplot, exception::Symbol=:dict)
    for fieldname in fieldnames(typeof(coefplot))
        if fieldname != exception
            setfield!(coefplot,fieldname,getfield(to_be_copyed,fieldname))
        end
    end
    return coefplot
end

function concat(coefplots::Vector{Coefplot})
    dict = OrderedDict{Symbol, SinglecoefPlot}()
    for coefplot in coefplots
        pushfirst!(dict,collect(coefplot.dict)...)
    end
    concated = Coefplot(dict)
    copy_options!(concated, coefplots[1])
    equidist!(concated;preserve_order=false)
end

function shift(pair::Pair{Symbol,SinglecoefPlot}, dist::Real)
    new_pair = deepcopy(pair)
    new_pair.second.thiscoef_loc = new_pair.second.thiscoef_loc + dist
    return new_pair
end

function shift(coefplot::Coefplot, dist::Real)
    new_coefplot = deepcopy(coefplot)
    new_coefplot.dict = OrderedDict([shift(kv,dist) for kv in coefplot.dict])
    return new_coefplot
end