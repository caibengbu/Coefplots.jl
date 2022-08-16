function sortcoef!(c::Coefplot; rev::Bool=false)
    sort!(c.data, [:b], rev=rev) ;
    c.sorter = c.data.varname ;
end