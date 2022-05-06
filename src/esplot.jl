function esplot(regmodel::T where T<:SupportedEstimation; normalized_period::Any, by=x->parse(Int64,x), verbose::Bool=false)
    # Event Study Specification can be formulated by @formula(outcome_it ~ treatment_i & eventtime_t + ...) with the keyward arg contrast
    # "contrasts = Dict(:eventtime_t => DummyCoding(base = event_time))"
    # this function is a shortcut to plot event studies that are formulated like this.
    coefplot = esparse(regmodel; normalized_period=normalized_period, by=by, verbose=verbose)
    plot(coefplot; verbose)
end

function get_time_from_coefname(coefnames; pre_print::Function=x->parse(Int64,x))
    time_marks = Pair[]
    for coefname in coefnames
        timevar_name_treatment_name_and_time_mark = strip.(split(coefname)) # return a vector of "timevar_name:", treatment_name and time_mark, but might be of random order
        # find timevar_name by looking at which element ends with a colon
        istimevar = map(timevar_name_treatment_name_and_time_mark) do x
            endswith(x,":")
        end
        timevar_ind = findfirst(istimevar)
        if checkbounds(Bool, timevar_name_treatment_name_and_time_mark, timevar_ind + 1)
            time_mark = string(timevar_name_treatment_name_and_time_mark[timevar_ind + 1])
        else
            throw(AssertionError("Fail to extract time mark!"))
        end
        push!(time_marks, Symbol(coefname) => string(pre_print(time_mark)))
    end
    return time_marks
end

function esparse(regmodel::T where T<:SupportedEstimation; normalized_period::Any, by=x->parse(Int64,x), pre_print::Function=x->parse(Int64,x), verbose::Bool=false)
    # Event Study Specification can be formulated by @formula(outcome_it ~ treatment_i & eventtime_t + ...) with the keyward arg contrast
    # "contrasts = Dict(:eventtime_t => DummyCoding(base = event_time))"
    # this function is a shortcut to plot event studies that are formulated like this.

    coef_names = coefnames(regmodel)
    keys_of_changes = get_time_from_coefname(coef_names; pre_print)
    parsed_model = parse(regmodel)
    coefrename!(parsed_model, keys_of_changes...)

    # re-insert normalized the event_time 
    Base.push!(parsed_model, :normalized_period => empty_sc(label = string(normalized_period)))
    composite_by = x -> by(x.thiscoef_label)
    sort!(parsed_model.dict, by = composite_by, byvalue=true)
    equidist!(parsed_model)
    transpose!(parsed_model)

    return parsed_model
end