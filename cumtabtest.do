// Do file to demonstrate and test cumtab.ado
// Set workspace.
set more off
clear all
set obs 1000

// Define a shuffle function.
program shuffleit
    set seed 123456
    gen srtr = runiform(0,100)
    sort srtr
    drop srtr
end

// Create fictional planting year data.
gen plantyear = 2010
replace plantyear = 2011 if _n > 750
replace plantyear = 2012 if _n < 250
replace plantyear = 2013 if _n > 475 & _n < 650
replace plantyear = 2014 if _n > 300 & _n < 425

// Shuffle the data.
shuffleit

// Create fictional cultivation data.
gen result = 15
replace result = 18 if _n > 630
replace result = 99 if _n > 870
// label define col_heads 0 "Total Seeds" 1 "Not Grmntd" 2 "Grmntd" 3 "Fruited"
label values result col_heads

// Display a summary of the data with tabulate.
tab plantyear result

// Shuffle the data.
shuffleit

// Add some geographic data.
gen region = 0
replace region = 1 if _n > 600
label define ns 0 "South Fields" 1 "North Fields"
label values region ns

cumtab result region plantyear
cumtab result region
cumtab result
