mutable struct SinglecoefPlot
    thiscoef_loc::Real
    point_est::Real
    confint_lb::Real
    confint_ub::Real
    thiscoef_label::String
    options::SinglecoefplotOption

    function SinglecoefPlot(thiscoef_loc::Real, point_est::Real, 
                            confint_lb::Real, confint_ub::Real, 
                            thiscoef_label::String, options::SinglecoefplotOption=SinglecoefplotOption())
        @assert confint_lb <= point_est <= confint_ub "Point estimate not in the interval"
        @assert isfinite(point_est) & isfinite(confint_lb) & isfinite(confint_ub) "Estimation not finite"
        @assert isfinite(thiscoef_loc) "Coef location is note finite"
        new(thiscoef_loc, point_est, confint_lb, confint_ub, thiscoef_label, options)
    end
end

function PGFPlotsX.print_tex(io::IO, singlecoefplot::SinglecoefPlot, option::SinglecoefplotOption)
    # Draw line first
    line = LineWithEnds(singlecoefplot)
    lineoptions = get_line_options(option)
    PGFPlotsX.print_tex(io, line, lineoptions)

    # draw dot next
    dot = Dot(singlecoefplot, option)
    dotoptions = get_dot_options(option)
    PGFPlotsX.print_tex(io, dot, dotoptions)
end

function PGFPlotsX.print_tex(io::IO, singlecoefplot::SinglecoefPlot)
    option = SinglecoefplotOption()
    # Draw line first
    line = LineWithEnds(singlecoefplot)
    lineoptions = get_line_options(option)
    PGFPlotsX.print_tex(io, line, lineoptions)

    # draw dot next
    dot = Dot(singlecoefplot, option)
    dotoptions = get_dot_options(option)
    PGFPlotsX.print_tex(io, dot, dotoptions)
end