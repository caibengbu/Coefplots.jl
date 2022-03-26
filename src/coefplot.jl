function coefplot(regmodel::SupportedEstimation,filename::String)
    parsed_model = parse(regmodel)
    td = TikzDocument(TikzPicture(Axis(gen_option_from_coefplotvec(parsed_model.vec_singlecoefplot),parsed_model.vec_singlecoefplot)))
    pgfsave(filename,td)
end