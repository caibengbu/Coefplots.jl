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

    function Dot(singlecoefplot::SinglecoefPlot)
        new((singlecoefplot.thiscoef_loc,singlecoefplot.point_est))
    end
end

default_dot_options() = merge(PGFPlotsX.Options(:circle => nothing, :"inner sep" => "0pt",:"minimum size" => "3pt"),color_as_fill_option(:navy))

function PGFPlotsX.print_tex(io::IO, dot::Dot, options::PGFPlotsX.Options)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot dot of the coefplot %%%%%%%%%%")
    print(io, "\\filldraw")
    print(io,"(axis cs:$(join(dot.loc,",")))")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "{}")
end

function PGFPlotsX.print_tex(io::IO, dot::Dot)
    options = default_dot_options()
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot dot of the coefplot %%%%%%%%%%")
    print(io, "\\filldraw")
    print(io,"(axis cs:$(join(dot.loc,","))) node")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "{}; ")
end

