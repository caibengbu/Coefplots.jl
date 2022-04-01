TikzDocument(elements) = PGFPlotsX.TikzDocument("\\sffamily\\sansmath",elements;use_default_preamble = false, preamble = gen_default_preamble());

function plot(coefplot::Coefplot, filename::String; verbose::Bool=false)
    td = TikzDocument(TikzPicture(coefplot))
    verbose ? print_tex(td) : nothing
    pgfsave(filename,td)
end

function plot(coefplot::Coefplot; verbose::Bool=false)
    td = TikzDocument(TikzPicture(coefplot))
    if verbose
        @show td
        print_tex(td)
    else
        display_on_different_IDE(td)
    end
end

function plot(mcoefplot::MultiCoefplot; verbose::Bool=false)
    td = TikzDocument(TikzPicture(mcoefplot))
    if verbose
        @show td
        print_tex(td)
    else
        display_on_different_IDE(td)
    end
end

function plot(mcoefplot::MultiCoefplot, filename::String; verbose::Bool=false)
    td = TikzDocument(TikzPicture(mcoefplot))
    verbose ? print_tex(td) : nothing
    pgfsave(filename,td)
end

function plot(regmodel::SupportedEstimation, filename::String; verbose::Bool=false)
    parsed_model = parse(regmodel)
    plot(parsed_model,filename; verbose)
end

function plot(regmodel::SupportedEstimation; verbose::Bool=false)
    parsed_model = parse(regmodel)
    plot(parsed_model; verbose)
end

function display_on_different_IDE(td::PGFPlotsX.TikzDocument)
    if PGFPlotsX._is_ijulia()
        display("image/svg+xml",td)
    else
        display(td)
    end
end


