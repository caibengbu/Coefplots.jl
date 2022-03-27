# Standard parsing with the direct output object. Can be dealt with with StatsModels

# df = DataFrame(Y=rand(10),X1=rand(10),X2=rand(10),X3=rand(10),X4=rand(10),cat1=repeat([1,2],inner=5))
# feols = FixedEffectModels.reg(df, @formula(Y~X1+X2+X3+X4+FixedEffectModels.fe(cat1)))
# nlfeols = GLFixedEffectModels.nlreg(df, @formula(Y~X1+X2+X3+X4+GLFixedEffectModels.fe(cat1)), Poisson(), LogLink())
# parse(feols)

SupportedEstimation = Union{StatsModels.TableRegressionModel,FixedEffectModel,GLFixedEffectModel}

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
