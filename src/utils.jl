
const PKG_DIR = joinpath(pathof(NISTTests), "..", "..") |> normpath
data_path(args...) = joinpath(PKG_DIR, "data", args...)

"""
precision_level(x, y)
Return the maximum decimal place (<=16) two given numbers are equal.
If the arguments are vectors then it returns the precision for each element

# Examples
```julia
julia> precision_level(2.3456, 2.3457)
3
```
"""
function precision_level(x::Real, y::Real)
    ans = 0
    for prec in 16:-1:1
        tst = isapprox(x, y, atol=10.0^(-prec))
        if(tst)
            ans=prec
            break
        end
    end
    return ans
end

function precision_level(x, y)
    n1 = length(x)
    n2 = length(y)
    n1 == n2 || throw(DimensionMismatch("lengths of x and y ($n1, $n2) are not equal")) 
    ans = zeros(Int8, n1)
    @inbounds for i in eachindex(x, y)
        ans[i] = precision_level(float(x[i]), float(y[i]))
    end
    return ans
end

"""
```julia
get_nist_data
```
Function to load data from pecified NIST Dataset as a given sink object.
"""
function get_nist_data(filename::String, sink = DataFrame)
    @assert filename ∈ readdir(data_path())
    df=CSV.read(data_path(filename), sink, missingstring="NA")
    return df
end

function get_nist_data(datasetname, sink = DataFrame)
    check_datasetname(datasetname)
    filename = String(datasetname) * ".csv"
    filename = lowercase(filename)
    get_nist_data(filename, sink)
end

function check_datasetname(datasetname::Symbol)
    datasetname in _NIST_LR_DATASETS ||
        throw(ArgumentError("Unsupported dataset `$(datasetname)``; supported datasets are" *
                            "$(_NIST_LR_DATASETS)"))
    nothing
end
