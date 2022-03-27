struct LineWithEnds
    end1::Tuple
    end2::Tuple

    function LineWithEnds(singlecoefplot::SinglecoefPlot)
        new((singlecoefplot.thiscoef_loc, singlecoefplot.confint_lb),
            (singlecoefplot.thiscoef_loc, singlecoefplot.confint_ub))
    end
end

function PGFPlotsX.print_tex(io::IO, line::LineWithEnds, options::PGFPlotsX.Options)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot line of the coefplot %%%%%%%%%%")
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "(axis cs:$(join(line.end1,","))) -- (axis cs:$(join(line.end2,",")));")
end

struct Dot
    loc::Tuple
    size::Real

    function Dot(singlecoefplot::SinglecoefPlot, options::SinglecoefplotOption)
        new((singlecoefplot.thiscoef_loc,singlecoefplot.point_est),options.dotsize)
    end
end

function PGFPlotsX.print_tex(io::IO, dot::Dot, options::PGFPlotsX.Options)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot dot of the coefplot %%%%%%%%%%")
    print(io, "\\filldraw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "(axis cs:$(join(dot.loc,","))) circle ($(dot.size)pt);")
end

function TikzDocument(elements)
    td = PGFPlotsX.TikzDocument(elements;use_default_preamble = false, preamble = gen_default_preamble());
end