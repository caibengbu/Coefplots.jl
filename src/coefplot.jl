mutable struct Coefplot
    reglabel::Union{Missing,String}
    regnote::Union{Missing,String}
    xtitle::Union{Missing,String}
    ytitle::Union{Missing,String}
    vec_singlecoefplot::Vector{SinglecoefPlot}

    # create Coefplot from combining vec_singlecoefplot and reglabel, regnote, xtitle, ytitle
    function Coefplot(vec_singlecoefplot::Vector{SinglecoefPlot},xtitle::Union{Missing,String}=missing,ytitle::Union{Missing,String}=missing,reglabel::Union{Missing,String}=missing, regnote::Union{Missing,String}=missing)
        new(reglabel, regnote, xtitle, ytitle, vec_singlecoefplot)
    end

    # create Coefplot from combining regmodel output and reglabel, regnote, xtitle, ytitle
    function Coefplot(coefvec::Vector{T} where T<:Real, confint::Matrix{T} where T<:Real ,coefnames::Vector{T} where T<:Any,
                      name_2_newname=missing, newindex_2_loc=x->x, 
                      xtitle::Union{Missing,String}=missing, ytitle::Union{Missing,String}=missing,
                      reglabel::Union{Missing,String}=missing, regnote::Union{Missing,String}=missing)
        @assert size(coefvec,1) == size(confint,1) == size(coefnames,1) "Dimension doesn't match"

        if name_2_newname === missing
            vec_singlecoefplot = [SinglecoefPlot(newindex_2_loc(i), coefvec[i], confint[i,:]..., coefnames[i]) for i in 1:size(coefvec,1)]
        else
            vec_singlecoefplot = Vector{SinglecoefPlot}(undef,size(coefvec,1))
            name_2_newindex = Dict([name => newindex for (newindex, name) in enumerate(keys(name_2_newname))])
            for i in 1:size(coefvec,1)
                name = coefnames[i]
                newindex = name_2_newindex[name]
                vec_singlecoefplot[newindex] = SinglecoefPlot(newindex_2_loc(newindex), coefvec[i], confint[i,:]..., name)
            end
        end
        new(reglabel, regnote, xtitle, ytitle, vec_singlecoefplot)
    end
end

function gen_other_option_from_coefplot(coefplot::Coefplot)
    singlecoefplots = coefplot.vec_singlecoefplot
    xtick = [singlecoefplot.thiscoef_loc for singlecoefplot in singlecoefplots]
    xticklabels = [singlecoefplot.thiscoef_label for singlecoefplot in singlecoefplots]
    xmin, xmax = extrema(xtick)
    ymin = minimum([singlecoefplot.confint_lb for singlecoefplot in singlecoefplots])
    ymax = maximum([singlecoefplot.confint_ub for singlecoefplot in singlecoefplots])
    xaxis_lb = xmin - (xmax - xmin)/(length(singlecoefplots)-1)
    xaxis_ub = xmax + (xmax - xmin)/(length(singlecoefplots)-1)
    yaxis_lb = ymin - (ymax - ymin)*0.1
    yaxis_ub = ymax + (ymax - ymin)*0.1
    PGFPlotsX.Options(
        :name => "tmp_fig",
        :xmin => xaxis_lb, :xmax => xaxis_ub, 
        :ymin => yaxis_lb, :ymax => yaxis_ub, 
        :xtick => xtick, :xticklabels => xticklabels)
end

function PGFPlotsX.print_tex(coefplot::Coefplot)
    # allow change color of a singlecoefplot (use inherit_options_from_coefplot as default)
    # 
end