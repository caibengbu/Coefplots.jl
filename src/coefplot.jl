function coefplot(my_coefplot::Coefplot, filename::String)
    td = TikzDocument(TikzPicture(Axis(gen_option_from_coefplotvec(my_coefplot.vec_singlecoefplot), my_coefplot.vec_singlecoefplot)))
    pgfsave(filename,td)
end

function coefplot(regmodel::SupportedEstimation, filename::String)
    parsed_model = parse(regmodel)
    coefplot(parsed_model,filename)
end


