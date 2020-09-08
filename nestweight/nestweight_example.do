*******************
* General context *
*******************

* Dataset of the USA, with 50 observations (states), nested in 4 regions
sysuse census, clear

* Creates some variable with missing observations
gen myvar = marriage/divorce if _n > 15

* The difference of nestweight and tabstat when generating national estimate:
* - tabstat implicitly assumes missing completely at random
* - nestweight approximates states with missing values by the region average

* Note: regional values are the same, only the national estimate changes

* National unweighted average
tabstat    myvar, by(region)
nestweight myvar, by(region)
return list

* National population-weighted average
tabstat    myvar [fw = pop], by(region)
nestweight myvar [fw = pop], by(region)
return list

****************************
* Learning Poverty context *
****************************

whereis github
global clone "`r(github)'/LearningPoverty-Production/"

use "${clone}/01_data/013_outputs/preference1005.dta", clear

nestweight adj_nonprof_all if lendingtype != "LNX" [fw = population_2015_all], ///
           by(region) only(if year_assessment >= 2011)
return list
