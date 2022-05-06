function esplot(regmodel::T where T<:SupportedEstimation; normalized_period::Any=missing, by=x->parse(Int64,x), verbose::Bool=false)
    # Event Study Specification can be formulated by @formula(outcome_it ~ treatment_i & eventtime_t + ...) with the keyward arg contrast
    # "contrasts = Dict(:eventtime_t => DummyCoding(base = event_time))"
    # this function is a shortcut to plot event studies that are formulated like this.
    coefplot = esparse(regmodel; normalized_period=normalized_period, by=by, verbose=verbose)
    plot(coefplot; verbose)
end

function get_time_from_coefname(coefnames; pre_print::Function=x->Int64(parse(Float64,x)))
    time_marks = Pair[]
    for coefname in coefnames
        timevar_name_treatment_name_and_time_mark = strip.(split(coefname)) # return a vector of "timevar_name:", treatment_name and time_mark, but might be of random order
        # find timevar_name by looking at which element ends with a colon
        istimevar = map(timevar_name_treatment_name_and_time_mark) do x
            endswith(x,":")
        end
        timevar_ind = findfirst(istimevar)
        if checkbounds(Bool, timevar_name_treatment_name_and_time_mark, timevar_ind + 1)
            time_mark = timevar_name_treatment_name_and_time_mark[timevar_ind + 1]
        else
            throw(AssertionError("Fail to extract time mark!"))
        end
        push!(time_marks, Symbol(coefname) => string(pre_print(time_mark)))
    end
    return time_marks
end

function esparse(regmodel::T where T<:SupportedEstimation; normalized_period::Any=missing, by=x->parse(Int64,x), pre_print::Function=x->Int64(parse(Float64,x)), verbose::Bool=false, extend::Bool=true)
    # Event Study Specification can be formulated by @formula(outcome_it ~ treatment_i & eventtime_t + ...) with the keyward arg contrast
    # "contrasts = Dict(:eventtime_t => DummyCoding(base = event_time))"
    # this function is a shortcut to plot event studies that are formulated like this.

    coef_names = coefnames(regmodel)
    keys_of_changes = get_time_from_coefname(coef_names; pre_print)
    parsed_model = parse(regmodel)
    coefrename!(parsed_model, keys_of_changes...)

    # re-insert normalized the event_time 
    if ~ismissing(normalized_period)
        Base.push!(parsed_model, :normalized_period => empty_sc(label = string(normalized_period)))
    end
    composite_by = x -> by(x.thiscoef_label)
    sort!(parsed_model.dict, by = composite_by, byvalue=true)
    equidist!(parsed_model)
    transpose!(parsed_model)
    if extend
        include_tails!(parsed_model)
    end

    return parsed_model
end

function include_tails!(parsed_model::Coefplot)
    first_sc_sym, first_sc = first(parsed_model.dict)
    first_sc.thiscoef_label = join(["\$\\leq\$",first_sc.thiscoef_label])
    parsed_model.dict[first_sc_sym] = first_sc

    last_sc_sym, last_sc = last(parsed_model.dict)
    last_sc.thiscoef_label = join(["\$\\geq\$",last_sc.thiscoef_label])
    parsed_model.dict[last_sc_sym] = last_sc
    return parsed_model
end

Base.last(itr::OrderedDict, n::Integer) = reverse!(collect(Iterators.take(Iterators.reverse(collect(itr)), n)))
Base.last(itr::OrderedDict) = first(Base.last(itr::OrderedDict, 1))