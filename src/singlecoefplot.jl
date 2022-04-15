mutable struct SinglecoefPlot
    thiscoef_loc::Real
    point_est::Real
    confint_lb::Real
    confint_ub::Real
    thiscoef_label::String
    options::SinglecoefplotOption

    function SinglecoefPlot(point_est::Real, 
                            confint_lb::Real, confint_ub::Real, 
                            thiscoef_label::String,thiscoef_loc::Real, 
                            options::SinglecoefplotOption=default_singlecoefplot_options())
        @assert confint_lb <= point_est <= confint_ub "Point estimate not in the interval"
        @assert isfinite(point_est) & isfinite(confint_lb) & isfinite(confint_ub) "Estimation not finite"
        @assert ismissing(thiscoef_loc) || isfinite(thiscoef_loc) "Coef location is note finite"
        new(thiscoef_loc, point_est, confint_lb, confint_ub, thiscoef_label, options)
    end
end

get_line_options(s::SinglecoefPlot) = get_line_options(s.options)
get_dot_options(s::SinglecoefPlot) = get_dot_options(s.options)

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

function print_singelcoefplot(io::IO, singlecoefplot::SinglecoefPlot)
    # Draw line first
    line = get_line(singlecoefplot)
    lineoptions = get_line_options(singlecoefplot)
    PGFPlotsX.print_tex(io, line, lineoptions)

    # draw dot next
    dot = get_dot(singlecoefplot)
    dotoptions = get_dot_options(singlecoefplot)
    PGFPlotsX.print_tex(io, dot, dotoptions)
end

function print_singelcoefplot_vertical(io::IO, singlecoefplot::SinglecoefPlot)
    # Draw line first
    line = get_line(singlecoefplot, true)
    lineoptions = get_line_options(singlecoefplot)
    PGFPlotsX.print_tex(io, line, lineoptions)

    # draw dot next
    dot = get_dot(singlecoefplot, true)
    dotoptions = get_dot_options(singlecoefplot)
    PGFPlotsX.print_tex(io, dot, dotoptions)
end