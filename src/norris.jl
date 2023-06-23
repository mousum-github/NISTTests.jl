
"""
```julia
norris_data
```
These data are from a NIST study involving calibration of ozone monitors.
The response variable (y) is the customer's measurement of ozone concentration and 
the predictor variable (x) is NIST's measurement of ozone concentration.
https://www.itl.nist.gov/div898/strd/lls/data/Norris.shtml
"""

function norris_data(sink = DataFrame)
    get_nist_data(:Norris, sink)
end

"""
```julia
norris_certified_values
```
NIST certified values for Norris dataset
"""
function norris_certified_values()
    NISTLREstimates(
        [-0.262323073774029, 1.00211681802045],
        [0.232818234301152, 0.429796848199937E-03],
        0.884796396144373, 0.999993745883712)
end

"""
```julia
norris_model_formula
```
Formula of the model for this dataset
"""
norris_model_formula() = @formula(y ~ 1 + x)


"""
```julia
norris_compare
```
Compare given estimates with certified estimates for Norris dataset
"""
function norris_compare(beta, stderr, rsd, rsq)
    ct = norris_model()
    compare(ct, float(beta), float(stderr), float(rsd), float(rsq))
end

norris_model() = NISTLRModel(norris_data(), norris_model_formula(),
                             norris_certified_values(), true, :Norris)
