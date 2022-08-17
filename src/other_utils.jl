"""
    sortcoef!(c::Coefplot; rev::Bool=false)

Sort the coefficient in ascending or descending order. Both `c.data` and `c.sorter` is modified.
"""
function sortcoef!(c::Coefplot; rev::Bool=false)
    sort!(c.data, [:b], rev=rev) ;
    c.sorter = c.data.varname ;
end