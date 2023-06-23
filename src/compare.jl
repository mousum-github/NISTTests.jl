

"""
```julia
struct NISTLResults
```
The structure holds the results of comparison
"""
struct NISTLResults <: NISTResults
    model::NISTLRModel
    estimates::NISTLREstimates
    precision::Dict
end

function NISTLResults(mdl::NISTLRModel, est::NISTLREstimates)
    precision = Dict()
    precision["coef"] = precision_level(mdl.certified.coef, est.coef)
    precision["stderror"] = precision_level(mdl.certified.stderror, est.stderror)
    precision["dispersion"] = precision_level(mdl.certified.dispersion, est.dispersion)
    precision["r2"] = precision_level(mdl.certified.r2, est.r2)
    return NISTLResults(mdl, est, precision)
end

function NISTLResults(mdl::NISTLRModel, beta::FPVector, stderr::FPVector, rsd::Real, rsq::Real)
    est = NISTLREstimates(beta, stderr, rsd, rsq)

    precision = Dict()
    precision["coef"] = precision_level(mdl.certified.coef, est.coef)
    precision["stderror"] = precision_level(mdl.certified.stderror, est.stderror)
    precision["dispersion"] = precision_level(mdl.certified.dispersion, est.dispersion)
    precision["r2"] = precision_level(mdl.certified.r2, est.r2)

    return NISTLResults(mdl, est, precision)
end

"""
```julia
certified_coef
```
Certified estimates of slope parameters
"""

certified_coef(ct::NISTResults) = certified_coef(ct.model)  

"""
```julia
certified_stderror
```
Certified standard error of slope parameters
"""
certified_stderror(ct::NISTResults) = certified_stderror(ct.model)

"""
```julia
certified_dispersion
```
Certified residual standard deviation of the model
"""
certified_dispersion(ct::NISTResults) = certified_dispersion(ct.model)

"""
```julia
certified_r2
```
Certified r-sqaured of the model
"""
certified_r2(ct::NISTResults) = certified_r2(ct.model)

"""
```julia
certified_values
```
Certified estimates
"""
certified_values(ct::NISTResults) = certified_values(ct.model)

"""
```julia
estimated_values
```
Estimates for comparing
"""
estimated_values(ct::NISTResults) = ct.estimates

"""
```julia
nist_data
```
"""
nist_data(ct::NISTResults) = nist_data(ct.model)

"""
```julia
formula
```
"""
formula(ct::NISTResults) = formula(ct.model)

"""
```julia
modelcols
```
"""
modelcols(ct::NISTResults) = modelcols(ct.model)

"""
```julia
compare
```
"""
compare(ct::NISTLRModel, beta::FPVector, stderr::FPVector, rsd::Real, rsq::Real) = 
        NISTLResults(ct, beta, stderr, rsd, rsq)


function julia_compare(datasetname, args...; kwargs...)
    model = nist_model(datasetname)
    y, X = modelcols(model)
    mdl = lm(X, y, args...; kwargs...)
    compare(model, coef(mdl), stderror(mdl), dispersion(mdl), r2(mdl))
end

# function julia_compare(X, y, args...; kwargs...)
#    mdl = lm(X, y, args...; kwargs...)
#    compare(model, coef(mdl), stderror(mdl), dispersion(mdl), r2(mdl))
# end


function Base.show(io::IO, ct::NISTLResults)
    nr = length(ct.model.certified.coef)
    nr == length(ct.estimates.coef) && nr == length(ct.estimates.stderror) || throw(DimensionMismatch("Length of estimates are different from NIST"))
    
    iz = ct.model.hasintercept ? 0 : 1

    #println(io, "NIST Dataset: " * String(ct.datasetname))
    println(io, "Comparison with " * String(ct.model.datasetname) * " NIST Dataset")
    println(io)
    println(io, "Coefficient:")
    println(io, " "^8, rpad("NIST Certified", 20), rpad("Calculated", 20), "Precision")
    cert_coef = ct.model.certified.coef
    calc_coef = ct.estimates.coef
    coef_diff = ct.precision["coef"]
    for ix = 1:nr
        line = rpad("β$iz", 8) * 
            rpad(@sprintf("%.16f", cert_coef[ix]), 20) *
            rpad(@sprintf("%.16f", calc_coef[ix]), 20) * 
            rpad(@sprintf("%.0f",  coef_diff[ix]), 8)
        println(io, line)
        iz = iz + 1
    end

    iz = ct.model.hasintercept ? 0 : 1

    println(io)
    println(io, "Standard Deviation of Estimate:")
    println(io, " "^8, rpad("NIST Certified", 20), rpad("Calculated", 20), "Precision")
    cert_stderror = ct.model.certified.stderror
    calc_stderror = ct.estimates.stderror
    stderror_diff = ct.precision["stderror"]
    for ix = 1:nr
        line = rpad("β$iz", 8) * 
            rpad(@sprintf("%.16f", cert_stderror[ix]), 20) *
            rpad(@sprintf("%.16f", calc_stderror[ix]), 20) * 
            rpad(@sprintf("%.0f",  stderror_diff[ix]), 8)
        println(io, line)
        iz = iz + 1
    end
    println(io)
    println(io, "Residual Standard Deviation:")
    println(io, rpad("NIST Certified", 20), rpad("Calculated", 20), "Precision")
    line = rpad(@sprintf("%.16f", ct.model.certified.dispersion), 20) *
        rpad(@sprintf("%.16f", ct.estimates.dispersion), 20) * 
        rpad(@sprintf("%.0f", ct.precision["dispersion"]), 8)
    println(io, line)
    
    println(io)
    println(io, "R-Squared:")
    println(io, rpad("NIST Certified", 20), rpad("Calculated", 20), "Precision")
    line = rpad(@sprintf("%.16f", ct.model.certified.r2), 20) *
        rpad(@sprintf("%.16f", ct.estimates.r2), 20) * 
        rpad(@sprintf("%.0f", ct.precision["r2"]), 8)
    println(io, line)
end


function compare(datasetname::Symbol, fitfunction::Function, 
    coeffunction::Function, stderrorfunction::Function, 
    rsdfucntion::Function, rsqfunction::Function)

    mdl = nist_model(datasetname)
    nistdata = nist_data(datasetname)
    model = fitfunction(nistdata)

    beta = coeffunction(model)
    stderr = stderrorfunction(model)
    rsd = rsdfucntion(model)
    rsq = rsqfunction(model)

    return compare(mdl, beta, stderr, rsd, rsq)
end

function compare(datasetname::Symbol, fitfunction::Function, args...; 
    coeffunction::Function, stderrorfunction::Function, 
    rsdfucntion::Function, rsqfunction::Function)

    mdl = nist_model(datasetname)
    nistdata = nist_data(datasetname)
    model = fitfunction(nistdata)

    beta = coeffunction(model)
    stderr = stderrorfunction(model)
    rsd = rsdfucntion(model)
    rsq = rsqfunction(model)

    return compare(mdl, beta, stderr, rsd, rsq)
end
