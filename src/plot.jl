TikzDocument(elements) = PGFPlotsX.TikzDocument(elements;use_default_preamble = false, preamble = gen_default_preamble());

function plot(my_coefplot::Coefplot, filename::String; verbose::Bool=false)
    td = TikzDocument(TikzPicture(my_coefplot))
    verbose ? print_tex(td) : nothing
    pgfsave(filename,td)
end

function plot(my_coefplot::Coefplot; verbose::Bool=false)
    td = TikzDocument(TikzPicture(my_coefplot))
    if verbose
        @show td
        print_tex(td)
    else
        display(td)
    end
end

function plot(regmodel::SupportedEstimation, filename::String)
    parsed_model = parse(regmodel)
    plot(parsed_model,filename)
end

function plot(regmodel::SupportedEstimation)
    parsed_model = parse(regmodel)
    plot(parsed_model)
end