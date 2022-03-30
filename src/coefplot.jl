mutable struct Coefplot <: PGFPlotsX.TikzElement
    name::Union{Missing,AbstractCaption}
    note::Union{Missing,AbstractCaption}
    xtitle::Union{Missing,AbstractCaption}
    ytitle::Union{Missing,AbstractCaption}
    dict::Dict{Symbol,SinglecoefPlot}

    # create Coefplot from combining vec_singlecoefplot and name, note, xtitle, ytitle
    function Coefplot(dict::Dict{Symbol,SinglecoefPlot},
                      xtitle::Union{Missing,AbstractCaption}=missing,ytitle::Union{Missing,AbstractCaption}=missing,
                      name::Union{Missing,String}=missing, note::Union{Missing,AbstractCaption}=missing)
        new(name, note, xtitle, ytitle, dict)
    end
end

function setxtitle!(c::Coefplot, x::String)
    c.xtitle = AbstractCaption(x)
    return c
end

function setytitle!(c::Coefplot, y::String)
    c.ytitle = AbstractCaption(y)
    return c
end

function setname!(c::Coefplot, name::String)
    c.name = AbstractCaption(name)
    return c
end

function includenote!(c::Coefplot, note::String)
    c.note = AbstractCaption(note)
    return c
end

function gen_other_option_from_coefplot(coefplot::Coefplot;vertical::Bool=false)
    singlecoefplots = values(coefplot.dict)
    xtick = [singlecoefplot.thiscoef_loc for singlecoefplot in singlecoefplots]
    xticklabels = [singlecoefplot.thiscoef_label for singlecoefplot in singlecoefplots]
    xmin, xmax = extrema(xtick)
    ymin = minimum([singlecoefplot.confint_lb for singlecoefplot in singlecoefplots])
    ymax = maximum([singlecoefplot.confint_ub for singlecoefplot in singlecoefplots])
    xaxis_lb = xmin - (xmax - xmin)/(length(singlecoefplots)-1)
    xaxis_ub = xmax + (xmax - xmin)/(length(singlecoefplots)-1)
    yaxis_lb = ymin - (ymax - ymin)*0.1
    yaxis_ub = ymax + (ymax - ymin)*0.1
    if vertical
        PGFPlotsX.Options(
            :name => "tmp_fig",
            :xmin => xaxis_lb, :xmax => xaxis_ub, 
            :ymin => yaxis_lb, :ymax => yaxis_ub, 
            :xtick => xtick, :xticklabels => xticklabels,
            Symbol("xticklabel style") => "{font=\\fontsize{5}{5}\\selectfont}",
            Symbol("yticklabel style") => "{font=\\fontsize{5}{5}\\selectfont}")
    else
        PGFPlotsX.Options(
            :name => "tmp_fig",
            :ymin => xaxis_lb, :ymax => xaxis_ub, 
            :xmin => yaxis_lb, :xmax => yaxis_ub, 
            :ytick => xtick, :yticklabels => xticklabels,
            Symbol("xticklabel style") => "{font=\\fontsize{5}{5}\\selectfont}",
            Symbol("yticklabel style") => "{font=\\fontsize{5}{5}\\selectfont}")
    end
end

Base.getindex(coefplot::Coefplot, args...; kwargs...) = getindex(coefplot.dict, args...; kwargs...)
Base.setindex!(coefplot::Coefplot, args...; kwargs...) = (setindex!(coefplot.dict, args...; kwargs...); coefplot)
Base.delete!(coefplot::Coefplot, args...; kwargs...) = (delete!(coefplot.dict, args...; kwargs...); coefplot)
Base.haskey(coefplot::Coefplot, args...; kwargs...) = haskey(coefplot.dict, args...; kwargs...)
Base.copy(coefplot::Coefplot) = deepcopy(coefplot)

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
        println(io, cpad("─── * Coefplot Name: "*coefplot.name.caption*" * ───",width))
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
    

function Base.push!(coefplot::Coefplot, other::Pair{Symbol, SinglecoefPlot} ...)
    all_keys = vcat(keys(coefplot.dict),[other[1] for this_other in other])
    @assert length(unique(all_keys)) == length(all_keys) "there are repeated keys!"
    push!(coefplot.dict, other...) # add new singlecoefplot to coefplot, will overwrite if key coincides
    coefplot
end


function PGFPlotsX.print_tex(io::IO, coefplot::Coefplot)
    # allow change color of a singlecoefplot (use inherit_options_from_coefplot as default)
    # allow print title and note
    PGFPlotsX.print_tex(io, Axis(gen_other_option_from_coefplot(coefplot), collect(values(coefplot.dict))))
    if coefplot.xtitle !== missing
        xtitle_default_option = default_xtitle_options()
        PGFPlotsX.print_tex(io, coefplot.xtitle, xtitle_default_option)
    end
    if coefplot.ytitle !== missing
        ytitle_default_option = default_ytitle_options()
        PGFPlotsX.print_tex(io, coefplot.ytitle, ytitle_default_option)
    end
    if coefplot.note !== missing
        note_default_option = default_note_options()
        PGFPlotsX.print_tex(io, coefplot.note, note_default_option)
    end
    if coefplot.name !== missing
        title_default_option = default_title_options()
        PGFPlotsX.print_tex(io, coefplot.name, title_default_option)
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

function concat(coefplots::Coefplot ...)
    dict = Dict{Symbol, SinglecoefPlot}()
    last_max_loc = 0
    for coefplot in coefplots
        append!(dict, shift.(coefplot.dict,last_max_loc))
        last_max_loc = maximum([singlecoefplot.thiscoef_loc for singlecoefplot in values(coefplot.dict)])
    end
    concated = Coefplot(dict)
    copy_options!(concated, coefplots[1])
end

function shift(pair::Pair{Symbol,SinglecoefPlot}, shift::Real)
    return pair.first => pair.second.thiscoef_loc + shift
end

function shift!(coefplot::Coefplot, shift::Real)
    coefplot.dict = Dict([shift(kv,shift) for kv in coefplot.dict])
    return coefplot
end