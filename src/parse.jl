SupportedEstimation = Union{StatsModels.TableRegressionModel,FixedEffectModel,GLFixedEffectModel}

function parse(est::SupportedEstimation, level::Real=0.95; drop_cons::Bool=true)
    if est isa FixedEffectModel
        coefplot = parse(StatsModels.coef(est), StatsModels.confint(est;level=level), StatsModels.coefnames(est))
    else
        coefplot = parse(StatsModels.coef(est), StatsModels.confint(est,level), StatsModels.coefnames(est))
    end
    if drop_cons
        drop_cons!(coefplot::Coefplot)
        equidist!(coefplot)
    end
    return coefplot
end

function parse(coefvec::Vector{T} where T<:Real, confint::Matrix{T} where T<:Real ,coefnames::Vector{T} where T<:Any)
    # create Coefplot from combining regmodel output and reglabel, regnote, xtitle, ytitle
    @assert size(coefvec,1) == size(confint,1) == size(coefnames,1) "Dimension doesn't match"
    dict = OrderedDict([Symbol(coefnames[i])=>SinglecoefPlot(coefvec[i], confint[i,:]..., coefnames[i], i) for i in 1:size(coefvec,1)])
    Coefplot(dict)
end


"""
    drop_cons!(coefplot[, cons])

Drop constant term from the coefplot.

# Examples
```julia-repl
julia> coefplot = parse(ols; drop_cons=false);
julia> drop_cons!(coefplot);
julia> plot(coefplot)
```
"""
drop_cons!(coefplot::Coefplot,cons::Symbol=Symbol("(Intercept)")) = delete!(coefplot,cons)

"""
    equidist!(coefplot)

Rearrange the location of each coefficients according to their index in the subplot vector.


# Examples
```julia-repl
julia> coefplot = parse(coefplot; drop_cons=false);
julia> equidist!(coefplot);
julia> plot(coefplot)
```
"""
function equidist!(coefplot::Coefplot;interval::Real=1,preserve_locorder::Bool=false)
    if preserve_locorder
        loc = [singlecoefplot.thiscoef_loc for singlecoefplot in values(coefplot.dict)]
        @assert ~all(ismissing.(loc)) "there are missing singlecoefplot location"
        newloc = invperm(sortperm(loc))
        for (thiscoef_newloc, singlecoefplot) in zip(newloc,values(coefplot.dict))
            singlecoefplot.thiscoef_loc = thiscoef_newloc * interval
        end
    else
        for (index, singlecoefplot) in enumerate(values(coefplot.dict))
            singlecoefplot.thiscoef_loc = index * interval
        end
    end
    return coefplot
end