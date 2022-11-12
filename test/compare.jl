@test how_same(0.123,0.1234) == 3
@test how_same(0.1234,0.12345) == 4
@test compare_nist_beta("noint2",1,0.727) == 3
@test compare_nist_beta("pontius",1,0.0006) == 4
@test compare_nist_rsd("wampler3",2360.146) == 3
@test compare_nist_rsd("pontius",0.00021) == 5
@test compare_nist_rsquare("filip",0.997) == 3
@test compare_nist_rsquare("wampler4",0.95) == 2
@test compare_nist_standarderror("filip",1,298.085) == 3
@test compare_nist_standarderror("noint1",1,0.0166) == 4