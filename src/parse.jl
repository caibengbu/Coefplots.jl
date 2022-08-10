const SupportedEstimation = Union{FixedEffectModel,TableRegressionModel,RegressionModel}

coefnames(r::RegressionModel) = StatsBase.coefnames(r)
coefnames(r::TableRegressionModel) = StatsModels.coefnames(r.mf)
coefnames(r::FixedEffectModel) = FixedEffectModels.coefnames(r)

coef(r::RegressionModel) = StatsBase.coef(r)
coef(r::TableRegressionModel) = StatsModels.coef(r)
coef(r::FixedEffectModel) = FixedEffectModels.coef(r)

yname(r::RegressionModel) = responsename(r) # returns a Symbol
yname(r::TableRegressionModel) = lhs(r.mf.f.lhs) # returns a Symbol
yname(r::FixedEffectModel) = r.yname

stderror(r::RegressionModel) = StatsBase.stderror(r)
stderror(r::TableRegressionModel) = StatsModels.stderror(r)
stderror(r::FixedEffectModel) = FixedEffectModels.stderror(r)

df_residual(r::RegressionModel) = StatsBase.dof_residual(r)
df_residual(r::TableRegressionModel) = StatsModels.dof_residual(r)
df_residual(r::FixedEffectModel) = FixedEffectModels.dof_residual(r)

"""
    parse(r::SupportedEstimation, ps::Pair{<:AbstractString, <:Any} ...; drop_unmentioned::Bool=true, kwargs...)

This function takes the regression result and convert it into a Coefplot.
`ps` is how you want to rename the coefficients. 
If drop_unmentioned, parse will drop all the unmentioned coefficient in `ps` in the Coefplot.
"""
function _parse(r::SupportedEstimation, ps::Vector{Pair{T,R}} where T<:AbstractString where R; drop_unmentioned::Bool=true, kwargs...)
    data = DataFrame(varname = coefnames(r), b = coef(r), se = stderror(r), dof = df_residual(r))
    data.se = isfinite.(data.se) .* data.se # set value to 0 if is not finite (NaN, Inf, etc)
    data.b = isfinite.(data.b) .* data.b # set value to 0 if is not finite (NaN, Inf, etc)

    # use the pair order as the sorter, also rename the varname according to the pair
    ps = map(ps) do x # convert pair.second to string
        return x.first => string(x.second)
    end
    if drop_unmentioned
        data.varname = get.(Ref(Dict(ps)), data.varname, missing) 
        data = data[completecases(data),:] # filter out varnames that are not mentioned in pairs
        sorter = intersect(string.(last.(ps)), data.varname) # sorter order is kept the same with the ps, remove redundant naming
    else
        v = get.(Ref(Dict(ps)), data.varname, missing)
        v[ismissing.(v)] = data.varname[ismissing.(v)]
        data.varname = v
        sorter = data.varname
    end
    sorter = latex_escape.(sorter)
    data.varname = latex_escape.(data.varname)
    Coefplot(data; sorter = sorter, kwargs...)
end

function _parse(r::SupportedEstimation, ps::Vector{T} where T<:AbstractString; kwargs...)
    data = DataFrame(varname = coefnames(r), b = coef(r), se = stderror(r), dof = df_residual(r))
    data.se = isfinite.(data.se) .* data.se # set value to 0 if is not finite (NaN, Inf, etc)
    data.b = isfinite.(data.b) .* data.b # set value to 0 if is not finite (NaN, Inf, etc)

    # use vector ps order as order for Coefplots
    data.varname = map(data.varname) do x
        if x ∈ ps
            return x
        else
            return missing
        end
    end
    data = data[completecases(data),:] # filter out varnames that are not mentioned in pairs
    sorter = intersect(string.(ps), data.varname) # sorter order is kept the same with the ps, remove redundant naming
    sorter = latex_escape.(sorter)
    data.varname = latex_escape.(data.varname)
    Coefplot(data; sorter = sorter, kwargs...)
end

function _parse(r::SupportedEstimation; kwargs...)
    data = DataFrame(varname = coefnames(r), b = coef(r), se = stderror(r), dof = df_residual(r))
    data.se = isfinite.(data.se) .* data.se # set value to 0 if is not finite (NaN, Inf, etc)
    data.b = isfinite.(data.b) .* data.b # set value to 0 if is not finite (NaN, Inf, etc)

    sorter = data.varname
    sorter = latex_escape.(sorter)
    data.varname = latex_escape.(data.varname)
    Coefplot(data; sorter = sorter, kwargs...)
end

function Base.parse(r::SupportedEstimation; rename=missing, keepcoef=missing, kwargs...)
    if ismissing(rename) & ismissing(keepcoef)
        _parse(r; kwargs...)
    elseif ismissing(rename) & ~ismissing(keepcoef)
        _parse(r, keepcoef; kwargs...)
    elseif ~ismissing(rename) & ismissing(keepcoef)
        _parse(r, rename; kwargs...)
    else
        throw(ArgumentError("rename and keepcoef can't have values in the same time"))
    end
end
