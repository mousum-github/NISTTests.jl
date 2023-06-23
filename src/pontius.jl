
"""
```julia
pontius_data
```
These data are from a NIST study involving calibration of load cells. 
The response variable (y) is the deflection and the predictor variable (x) is load.
https://www.itl.nist.gov/div898/strd/lls/data/Pontius.shtml
"""

function pontius_data(sink = DataFrame)
    get_nist_data(:Pontius, sink)
end

"""
```julia
pontius_certified_values
```
NIST certified values for Pontius dataset
"""
function pontius_certified_values()
    NISTLREstimates(
        [0.673565789473684E-03, 0.732059160401003E-06, -0.316081871345029E-14],
        [0.107938612033077E-03, 0.157817399981659E-09, 0.486652849992036E-16],
         0.205177424076185E-03, 0.999999900178537)
end

"""
```julia
pontius_model_formula
```
Formula of the model for this dataset
"""
pontius_model_formula() = @formula(y ~ 1 + x + x^2)


"""
```julia
pontius_compare
```
Compare given estimates with certified estimates for Pontius dataset
"""
function pontius_compare(beta, stderr, rsd, rsq)
    ct = pontius_model()
    compare(ct, float(beta), float(stderr), float(rsd), float(rsq))
end

pontius_model() = NISTLRModel(pontius_data(), pontius_model_formula(),
                             pontius_certified_values(), true, :Pontius)
