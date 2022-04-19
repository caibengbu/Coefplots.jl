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
        @assert (~ismissing(thiscoef_loc)) || isfinite(thiscoef_loc) "Coef location is not finite"
        new(thiscoef_loc, point_est, confint_lb, confint_ub, thiscoef_label, options)
    end
end

get_line_options(s::SinglecoefPlot) = get_line_options(s.options)
get_dot_options(s::SinglecoefPlot) = get_dot_options(s.options)

function get_dot(singlecoefplot::SinglecoefPlot, vertical::Bool=false)
    loc = (singlecoefplot.thiscoef_loc,singlecoefplot.point_est)
    options = get_dot_options(singlecoefplot)
    if vertical
        Dot(loc, options)
    else
        Dot(reverse(loc), options)
    end
end

function get_line(singlecoefplot::SinglecoefPlot, vertical::Bool=false)
    end1 = (singlecoefplot.thiscoef_loc, singlecoefplot.confint_lb)
    end2 = (singlecoefplot.thiscoef_loc, singlecoefplot.confint_ub)
    options = get_line_options(singlecoefplot)
    if vertical
        LineWithEnds(end1, end2, options)
    else
        LineWithEnds(reverse(end1), reverse(end2), options)
    end
end