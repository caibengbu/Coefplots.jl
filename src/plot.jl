TikzDocument(elements) = PGFPlotsX.TikzDocument("\\sffamily\\sansmath",elements;use_default_preamble = false, preamble = CUSTOM_PREAMBLE);


function plot(coefplot::Coefplot, filename::String; verbose::Bool=false)
    td = TikzDocument(TikzPicture(to_plotable(coefplot)))
    verbose ? print_tex(td) : nothing
    pgfsave(filename,td)
end

function plot(coefplot::Coefplot; verbose::Bool=false)
    td = TikzDocument(TikzPicture(to_plotable(coefplot)))
    if verbose
        @show td
        print_tex(td)
    else
        display_on_different_IDEs(td)
    end
end

function plot(mcoefplot::MultiCoefplot; offset::Union{Real,Missing}=missing, verbose::Bool=false)
    td = TikzDocument(TikzPicture(to_plotable(mcoefplot, offset)))
    if verbose
        @show td
        print_tex(td)
    else
        display_on_different_IDEs(td)
    end
end

function plot(mcoefplot::MultiCoefplot, filename::String; offset::Union{Real,Missing}=missing, verbose::Bool=false)
    td = TikzDocument(TikzPicture(to_plotable(mcoefplot, offset)))
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

function display_on_different_IDEs(td::PGFPlotsX.TikzDocument)
    if PGFPlotsX._is_ijulia()
        display("image/png",td)
    else
        display(td)
    end
end


