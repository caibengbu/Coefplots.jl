# scp1 = SinglecoefPlot(1,1,0.5,1.5,"coef1")
# scp2 = SinglecoefPlot(2,1.2,-1,2,"coef1")
# scp3 = SinglecoefPlot(3,-0.2,-1,0.5,"coef3")
# scps = [scp1,scp2,scp3]

mutable struct SinglecoefPlot
    thiscoef_loc::Real
    point_est::Real
    confint_lb::Real
    confint_ub::Real
    thiscoef_label::String

    function SinglecoefPlot(thiscoef_loc::Real, point_est::Real, confint_lb::Real, confint_ub::Real, thiscoef_label::String)
        @assert confint_lb <= point_est <= confint_ub "Point estimate not in the interval"
        @assert isfinite(point_est) & isfinite(confint_lb) & isfinite(confint_ub) "Estimation not finite"
        @assert isfinite(thiscoef_loc) "Coef location is note finite"
        new(thiscoef_loc, point_est, confint_lb, confint_ub, thiscoef_label)
    end
end

function PGFPlotsX.print_tex(io::IO, singlecoefplot::SinglecoefPlot)
    print(io, "\\singlecoefplot{")
    PGFPlotsX.print_tex(io, singlecoefplot.thiscoef_loc)
    print(io, "}{")
    PGFPlotsX.print_tex(io, singlecoefplot.point_est)
    print(io, "}{")
    PGFPlotsX.print_tex(io, singlecoefplot.confint_lb)
    print(io, "}{")
    PGFPlotsX.print_tex(io, singlecoefplot.confint_ub)
    println(io, "}")
end

function gen_option_from_coefplotvec(singlecoefplots::Vector{SinglecoefPlot})
    xtick = [singlecoefplot.thiscoef_loc for singlecoefplot in singlecoefplots]
    xticklabels = [singlecoefplot.thiscoef_label for singlecoefplot in singlecoefplots]
    xmin, xmax = extrema(xtick)
    ymin = minimum([singlecoefplot.confint_lb for singlecoefplot in singlecoefplots])
    ymax = maximum([singlecoefplot.confint_ub for singlecoefplot in singlecoefplots])
    xaxis_lb = xmin - (xmax - xmin)/(length(singlecoefplots)-1)
    xaxis_ub = xmax + (xmax - xmin)/(length(singlecoefplots)-1)
    yaxis_lb = ymin - (ymax - ymin)*0.1
    yaxis_ub = ymax + (ymax - ymin)*0.1
    PGFPlotsX.Options(
        :name => "tmp_fig",
        :xmin => xaxis_lb, :xmax => xaxis_ub, 
        :ymin => yaxis_lb, :ymax => yaxis_ub, 
        :xtick => xtick, :xticklabels => xticklabels)
end

function TikzDocument(elements)
    td = PGFPlotsX.TikzDocument(elements;use_default_preamble = false, preamble = gen_default_preamble());
    push_preamble!(td, newcommand_singlecoefplot())
end