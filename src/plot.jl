function plot(my_coefplot::Coefplot, filename::String; verbose::Bool=false)
    td = TikzDocument(TikzPicture(Axis(gen_other_option_from_coefplot(my_coefplot), my_coefplot.vec_singlecoefplot)))
    verbose ? print_tex(td) : nothing
    pgfsave(filename,td)
end

function plot(regmodel::SupportedEstimation, filename::String)
    parsed_model = parse(regmodel)
    plot(parsed_model,filename)
end


