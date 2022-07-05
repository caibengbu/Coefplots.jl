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
stderror(r::RegressionModel) = StatsModels.coefnames(r)
stderror(r::FixedEffectModel) = FixedEffectModels.stderror(r)

df_residual(r::RegressionModel) = StatsBase.dof_residual(r)
df_residual(r::TableRegressionModel) = StatsModels.dof_residual(r)
df_residual(r::FixedEffectModel) = FixedEffectModels.dof_residual(r)

latex_escape(s) = escape_string(s,"&\$%")

function parse(r::SupportedEstimation, ps::Pair{<:AbstractString, <:Any} ...; drop_unmentioned::Bool=true, kwargs...)
    """
    This function takes the regression result and convert it into a Coefplot.
    `ps` is how you want to rename the coefficients. 
    If drop_unmentioned, parse will drop all the unmentioned coefficient in `ps` in the Coefplot.
    """
    data = DataFrame(varname = coefnames(r), b = coef(r), se = stderror(r), dof = df_residual(r))
    data.se = isfinite.(data.se) .* data.se # set value to 0 if is not finite (NaN, Inf, etc)
    data.b = isfinite.(data.b) .* data.b # set value to 0 if is not finite (NaN, Inf, etc)

    if isempty(ps) # if input no pairs, sorter is the varname itself
        sorter = data.varname
    else # if input some pairs, use the pair order as the sorter, also rename the varname according to the pair
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
    end
    sorter = latex_escape.(sorter)
    data.varname = latex_escape.(data.varname)
    Coefplot(data; sorter = sorter, kwargs...)
end

## TO-DO: something is wrong with the current escaping. for example "$\geq$", this won't event be able to inputted as a string.
## Users will have to input it as "\$\\geq\$". which is already escapped.
## in that case, latex_escape will need to skip "\\g"-like items, and "\$". If not, this will happen:

## julia> print_tex(latex_escape("\$"))
## \$                                      -- (instead of $)

## julia> print_tex(latex_escape("\\g"))
## \\g                                     -- (instead of \g)