# Standard parsing with the direct output object. Can be dealt with with StatsModels

# df = DataFrame(Y=rand(10),X1=rand(10),X2=rand(10),X3=rand(10),X4=rand(10),cat1=repeat([1,2],inner=5))
# feols = FixedEffectModels.reg(df, @formula(Y~X1+X2+X3+X4+FixedEffectModels.fe(cat1)))
# nlfeols = GLFixedEffectModels.nlreg(df, @formula(Y~X1+X2+X3+X4+GLFixedEffectModels.fe(cat1)), Poisson(), LogLink())
# parse(feols)

SupportedEstimation = Union{StatsModels.TableRegressionModel,FixedEffectModel,GLFixedEffectModel}

mutable struct Coefplot
    reglabel::Union{Missing,String}
    regnote::Union{Missing,String}
    xtitle::String
    ytitle::String
    vec_singlecoefplot::Vector{SinglecoefPlot}

    function Coefplot(vec_singlecoefplot::Vector{SinglecoefPlot},xtitle::String=missing,ytitle::String=missing,reglabel::Union{Missing,String}=missing, regnote::Union{Missing,String}=missing)
        new(reglabel, regnote, xtitle, ytitle, vec_singlecoefplot)
    end
    function Coefplot(coefvec::Vector{T} where T<:Real, confint::Matrix{T} where T<:Real ,coefnames::Vector{Any},xtitle::String=missing,ytitle::String=missing,reglabel::Union{Missing,String}=missing, regnote::Union{Missing,String}=missing)
        @assert size(coefvec,1) == size(confint,1) == size(coefnames,1) "Dimension doesn't match"
        # TO-DO: how to sort coefficients?
        vec_singlecoefplot = [SinglecoefPlot(i, coefvec[i], confint[i,:]..., coefnames[i]) for i in 1:size(coefvec,1)]
        new(reglabel, regnote, xtitle, ytitle, vec_singlecoefplot)
    end
end


function parse(est::SupportedEstimation, reglabel::Union{Missing,String}=missing, regnote::Union{Missing,String}=missing)
    return Coefplot(coef(est),confint(est),coefnames(est), reglabel, regnote)
end
