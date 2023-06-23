"""
```julia
noint2_data
```
This dataset is constructed to test the ability of the software to recognize a statistically
significant slope for a line fit through the origin (large positive value of the F statistic).
https://www.itl.nist.gov/div898/strd/lls/data/NoInt2.shtml
"""

function noint2_data(sink = DataFrame)
    get_nist_data(:Noint1, sink)
end

"""
```julia
noint2_certified_values
```
NIST certified values for Noint2 dataset
"""
function noint2_certified_values()
    NISTLREstimates(
        [0.673565789473684E-03, 0.732059160401003E-06, -0.316081871345029E-14],
        [0.107938612033077E-03, 0.157817399981659E-09, 0.486652849992036E-16],
         0.205177424076185E-03, 0.999999900178537)
end

"""
```julia
noint2_model_formula
```
Formula of the model for this dataset
"""
noint2_model_formula() = @formula(y ~ 0 + x)


"""
```julia
noint2_compare
```
Compare given estimates with certified estimates for Noint2 dataset
"""
function noint2_compare(beta, stderr, rsd, rsq)
    ct = noint2_model()
    compare(ct, float(beta), float(stderr), float(rsd), float(rsq))
end

noint2_model() = NISTLRModel(noint2_data(), noint2_model_formula(),
                              noint2_certified_values(), false, :Noint2)
