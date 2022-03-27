SupportedEstimation = Union{StatsModels.TableRegressionModel,FixedEffectModel,GLFixedEffectModel}

function rename!(coefplot::Coefplot,name_2_newname::Dict)
    for singlecoefplot in coefplot.vec_singlecoefplot
        if singlecoefplot.thiscoef_label ∈ keys(name_2_newname)
            # if the name is in the name_2_newname dictionary, change it
            singlecoefplot.thiscoef_label = name_2_newname[singlecoefplot.thiscoef_label]
        end
    end
    return coefplot
end


sort!(coefplot::Coefplot,key::Function = Base.string) = Base.sort!(coefplot.vec_singlecoefplot,by=x->key(x.thiscoef_label))
sort!(coefplot::Coefplot,key::Dict) = Base.sort!(coefplot.vec_singlecoefplot,by=x->get(key,x.thiscoef_label,0))
function sort!(coefplot::Coefplot,key::Vector{T} where T <: Union{Missing,String})
    vec_singlecoefplot = Vector{SinglecoefPlot}(undef,length(coefplot.vec_singlecoefplot))
    name_2_singelcoefplot = Dict([singlecoefplot.thiscoef_label => singlecoefplot for singlecoefplot in coefplot.vec_singlecoefplot])
    name_2_newindex = Dict([name => newindex for (newindex, name) in enumerate(key)])
    @assert issetequal(keys(name_2_newindex),keys(name_2_singelcoefplot)) "keys doesn't match"
    for name in key
        newindex = name_2_newindex[name]
        vec_singlecoefplot[newindex] = name_2_singelcoefplot[name]
    end
    coefplot = Coefplot(vec_singlecoefplot, coefplot.xtitle, coefplot.ytitle, coefplot.reglabel, coefplot.regnote)
end


function parse(est::SupportedEstimation, level::Real=0.95)
    if est isa FixedEffectModel
        Coefplot(StatsModels.coef(est),StatsModels.confint(est;level=level),StatsModels.coefnames(est))
    else
        Coefplot(StatsModels.coef(est),StatsModels.confint(est,level),StatsModels.coefnames(est))
    end
end


