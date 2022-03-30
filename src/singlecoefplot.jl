mutable struct SinglecoefPlot
    thiscoef_loc::Real
    point_est::Real
    confint_lb::Real
    confint_ub::Real
    thiscoef_label::String

    function SinglecoefPlot(point_est::Real, 
                            confint_lb::Real, confint_ub::Real, 
                            thiscoef_label::String,thiscoef_loc::Real)
        @assert confint_lb <= point_est <= confint_ub "Point estimate not in the interval"
        @assert isfinite(point_est) & isfinite(confint_lb) & isfinite(confint_ub) "Estimation not finite"
        @assert ismissing(thiscoef_loc) || isfinite(thiscoef_loc) "Coef location is note finite"
        new(thiscoef_loc, point_est, confint_lb, confint_ub, thiscoef_label)
    end
end

function get_dot(singlecoefplot::SinglecoefPlot, vertical::Bool=false)
    loc = (singlecoefplot.thiscoef_loc,singlecoefplot.point_est)
    if vertical
        Dot(loc)
    else
        Dot(reverse(loc))
    end
end

function get_line(singlecoefplot::SinglecoefPlot, vertical::Bool=false)
    end1 = (singlecoefplot.thiscoef_loc, singlecoefplot.confint_lb)
    end2 = (singlecoefplot.thiscoef_loc, singlecoefplot.confint_ub)
    if vertical
        LineWithEnds(end1, end2)
    else
        LineWithEnds(reverse(end1),reverse(end2))
    end
end

function PGFPlotsX.print_tex(io::IO, singlecoefplot::SinglecoefPlot, option::SinglecoefplotOption)
    # Draw line first
    line = get_line(singlecoefplot)
    lineoptions = get_line_options(option)
    PGFPlotsX.print_tex(io, line, lineoptions)

    # draw dot next
    dot = get_dot(singlecoefplot)
    # dotoptions = get_dot_options(option) # need to rework on this: getting dot options from SinglecoefplotOption.
    # PGFPlotsX.print_tex(io, dot, dotoptions)
    PGFPlotsX.print_tex(io, dot)
end

function PGFPlotsX.print_tex(io::IO, singlecoefplot::SinglecoefPlot)
    option = default_singlecoefplot_options()
    # Draw line first
    line = get_line(singlecoefplot)
    lineoptions = get_line_options(option)
    PGFPlotsX.print_tex(io, line, lineoptions)

    # draw dot next
    dot = get_dot(singlecoefplot)
    # dotoptions = get_dot_options(option) need to rework on this
    # PGFPlotsX.print_tex(io, dot, dotoptions)
    PGFPlotsX.print_tex(io, dot)
end