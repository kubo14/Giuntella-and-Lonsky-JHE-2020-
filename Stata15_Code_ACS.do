***********************************************************************************************************************
* 		Paper: The effects of DACA on health insurance, access to care, and health outcomes 	  	 		  		  *
* 		Authors: Osea Giuntella, Jakub Lonsky 											  	      	 		  		  *
* 		Data: 2008-2016 American Community Survey (ACS) pooled yearly public-use samples				 		  	  *
* 		Data repository: Integrated Public Use Microdata Series (IPUMS) USA (https://usa.ipums.org/usa/) 	  		  *
*		Variables needed: STATEFIP, PUMA, YEAR, BIRTHYR, BIRTHQTR, YRSUSA1, YRSUSA2, BPL, SEX, MARST, RACE, HCOVPRIV  * 
*						  RACESING, SCHOOL, EDUC, CITIZEN, AGE, YRIMMIG, HCOVANY, HINSCAID, HINSEMP, HINSPUR   		  *					  
***********************************************************************************************************************

***************************************************
***			 GENERATING MAIN DATASET 			***
***************************************************
clear
global path "/Users/Lonskyj/Desktop/DACA Project" 
cd "$path"
use "$path/DACA_ACS_2008_2016.dta"

* Respondent's date of birth (year)
replace birthyr = . if birthyr >= 9996

* Respondent's date of birth (quarter)
replace birthqtr = . if birthqtr == 0 | birthqtr == 9

*** Clean Years in USA variables 
replace yrsusa1 = . if yrsusa1 == 0 & bpl < 140 
replace yrsusa2 = . if yrsusa2 == 0 & bpl < 140
replace yrsusa1 = . if bpl < 140
replace yrsusa2 = . if bpl < 140


******************************************************************************
* Covariates & Variables necessary for identifying DACA-eligible individuals *
******************************************************************************
* Male dummy 
gen male = . 
replace male = 0 if sex == 2
replace male = 1 if sex == 1
drop sex

*** Married dummy variable 
gen married = . 
replace married = 0 if marst >= 3
replace married = 1 if marst <= 2
drop marst

**** Race dummy variables 
gen racewhite = 0
replace racewhite = 1 if racesing == 1 & year <= 2014
replace racewhite = 1 if race == 1 & (year == 2015 | year == 2016)

gen raceblack = 0
replace raceblack = 1 if racesing == 2 & year <= 2014
replace raceblack = 1 if race == 2 & (year == 2015 | year == 2016)

gen racenatamer = 0
replace racenatamer = 1 if racesing == 3 & year <= 2014
replace racenatamer = 1 if race == 3 & (year == 2015 | year == 2016)

gen raceasian = 0
replace raceasian = 1 if racesing == 4 & year <= 2014
replace raceasian = 1 if (race == 4 | race == 5 | race == 6) & (year == 2015 | year == 2016)

gen raceother = 0
replace raceother = 1 if racesing == 5 & year <= 2014
replace raceother = 1 if (race == 7 | race == 8 | race == 9) & (year == 2015 | year == 2016)
drop racesing racesingd race raced

*** Dummy variable for if hipanic 
gen ethnichisp = 0
replace ethnichisp = . if hispan == 9
replace ethnichisp = 1 if hispan >= 1 & hispan <= 4
drop hispand

*** Are currently attending school 
replace school = . if school == 9
replace school = 0 if school == 1
replace school = 1 if school == 2

*** Have less than high school degree
gen lesshs = (educd <= 61) 

*** Have high school degree or equivalent 
gen hsdegree = (educd >= 62 & educd <= 64) 

*** Have some college  
gen somecol = (educd >= 65 & educd <= 100) 

*** Have college degree or more   
gen coldegree = (educd >= 101 & educd <= 900) 


*******************************************
*** CITIZENSHIP & IMMIGRATION VARIABLES ***
*******************************************
*** Dummy variable for born out of USA
gen bornoutusa = . 
replace bornoutusa = 0 if bpl < 140
replace bornoutusa = 1 if bpl > 140 & bpl < 999

*** Dummy variable for if a citizen
replace citizen = 1 if citizen >= 0 & citizen <= 2
replace citizen = 0 if citizen == 3

*** Age at time of entry into the USA 
gen ageenterusa = . 
replace ageenterusa = age - yrsusa1 
replace ageenterusa = . if ageenterusa <= -2 
replace ageenterusa = 0 if ageenterusa == -1 

*** Year of Immigration into U.S.
replace yrimmig = . if yrsusa1 == .
replace yrimmig = . if yrimmig == 0


************************
*** DACA Eligibility ***
************************
*** Under the age of 31 on June 15, 2012 ***
gen under31now = 0 
replace under31now = 1 if ((birthyr == year - 32 & birthqtr >= 3) | (birthyr >= year - 31)) & (birthyr !=. & birthqtr !=.) & year <= 2013 
replace under31now = 1 if ((birthyr == year - 33 & birthqtr >= 3) | (birthyr >= year - 32)) & (birthyr !=. & birthqtr !=.) & year == 2014 
replace under31now = 1 if ((birthyr == year - 34 & birthqtr >= 3) | (birthyr >= year - 33)) & (birthyr !=. & birthqtr !=.) & year == 2015
replace under31now = 1 if ((birthyr == year - 35 & birthqtr >= 3) | (birthyr >= year - 34)) & (birthyr !=. & birthqtr !=.) & year == 2016

replace under31now = 1 if age < 32 & (birthyr ==. | birthqtr ==.) & year <= 2013 
replace under31now = 1 if age < 33 & (birthyr ==. | birthqtr ==.) & year == 2014 
replace under31now = 1 if age < 34 & (birthyr ==. | birthqtr ==.) & year == 2015
replace under31now = 1 if age < 35 & (birthyr ==. | birthqtr ==.) & year == 2016

*** Enter USA before the age of 16 (i.e. age <= 15) ***
gen enterunder16 = . 
replace enterunder16 = 0 if ageenterusa != . 
replace enterunder16 = 1 if ageenterusa <= 15

*** Resided in US since June 15, 2007 ***
gen liveusa5now = . 
replace liveusa5now = 0 if yrsusa1 != . 
replace liveusa5now = 1 if yrsusa1 >= 6 & yrsusa1 <= 100 & year<=2013 
replace liveusa5now = 1 if yrsusa1 >= 7 & yrsusa1 <= 100 & year==2014 
replace liveusa5now = 1 if yrsusa1 >= 8 & yrsusa1 <= 100 & year==2015
replace liveusa5now = 1 if yrsusa1 >= 9 & yrsusa1 <= 100 & year==2016

*** Meets the education requirment: 1) currently in school, or 2) graduate from High School / Obtained GED ***
gen meetedreq = 0 
replace meetedreq = 1 if hsdegree == 1 | somecol == 1 | coldegree == 1 
replace meetedreq = 1 if school == 1 

*** Dummy variable for if individual was eligible for DACA if DACA came out june 15th, of that survey year ***
gen dacaelignow = 0 
replace dacaelignow = 1 if under31now == 1 & enterunder16 == 1 & liveusa5now == 1 ///
	 & meetedreq == 1 & citizen == 0 & bornoutusa == 1 & age >= 15
	 
*** Dummy variable for if the year is after the implementation of DACA (i.e. year >= 2013) ***
gen afterdaca = 0 
replace afterdaca = 1 if year >= 2013

*** Interaction term between After daca and Eligible
gen intafterelignow = afterdaca*dacaelignow


****************************
* 	OUTCOMES OF INTEREST   *
****************************

***********************************************************
* Health Insurance  (at the time of interview): 2008-2016 *
***********************************************************
* Currently insured
gen insured = .
replace insured = 0 if hcovany == 1 & year >= 2008 & year <= 2016
replace insured = 1 if hcovany == 2 & year >= 2008 & year <= 2016

* Enrolled on Medicaid
gen medical = .
replace medical = 0 if hinscaid == 1 & year >= 2008 & year <= 2016
replace medical = 1 if hinscaid == 2 & year >= 2008 & year <= 2016

* Insurance through employer/union
gen emp_ins = .
replace emp_ins = 0 if hinsemp == 1 & year >= 2008 & year <= 2016
replace emp_ins = 1 if hinsemp == 2 & year >= 2008 & year <= 2016

* Covered by privately purchased insurance 
gen private = .
replace private = 0 if hinspur == 1 & year >= 2008 & year <= 2016
replace private = 1 if hinspur == 2 & year >= 2008 & year <= 2016

* Any private coverage (via employer/union, privately purchased, TRICARE/other military health)
gen emp_private = . 
replace emp_private = 0 if hcovpriv == 1 & year >= 2008 & year <= 2016
replace emp_private = 1 if hcovpriv == 2 & year >= 2008 & year <= 2016

*** Create a variable for state by year to be able to cluster at the state-year level
egen stateyear = group(statefip year)

*** Create state time trends 
quietly tab statefip, gen(statedum)
quietly for num 1/51: replace statedumX = statedumX*year 

* Label values of YEAR
label define time 2008 "2008" 2009 "2009" 2010 "2010" 2011 "2011" 2012 "2012" 2013 "2013" 2014 "2014" 2015 "2015" 2016 "2016" 
label values year time

compress
save "DACA_ACS_Public_FINAL.dta", replace




***********************************************************
***********************************************************
***			ANALYSIS (ACS: MAIN TABLES & FIGURES)		***
***********************************************************
***********************************************************

**************************************
**			 Figures 1-3			**
**************************************

*************
* ENTIRE US *
*************
clear
cd "$path"
use "DACA_ACS_Public_FINAL.dta"
keep if age >= 18 & age <= 35
keep if citizen == 0 & bornoutusa == 1
keep if hsdegree == 1 | somecol == 1 | coldegree == 1

forvalues x = 2008/2016 {
	gen year`x' = (year == `x')
}

forvalues x = 2008/2016 {
	gen inter`x' = year`x'*dacaelignow
}

foreach var in insured medical emp_private private emp_ins {
	areg `var' inter2016 inter2015 inter2014 inter2013 inter2011 inter2010 inter2009 inter2008 ///
dacaelignow i.age i.ageenterusa somecol coldegree male ethnichisp racewhite raceblack racenatamer raceasian married i.year statedum* [pweight = perwt], a(statefip) cluster(stateyear)
	parmest, saving(`var'_US1835.dta, replace) format(parm estimate min95 max95)
}

use insured_US1835.dta, clear
drop stderr dof t p
rename estimate insured 
rename min95 insuredmin95 
rename max95 insuredmax95

foreach var in medical emp_private private emp_ins {
	merge 1:1 parm using `var'_US1835.dta, nogen 
	drop stderr dof t p 
	rename estimate `var'
	rename min95 `var'min95 
	rename max95 `var'max95
}
sort parm

keep if _n >= 72 & _n <= 79
gen year = _n + 2008
replace year = 2013 if parm == "inter2013"
replace year = 2014 if parm == "inter2014"
replace year = 2015 if parm == "inter2015"
replace year = 2016 if parm == "inter2016"
replace year = 2012 if parm == "male"
sort year
drop parm
foreach var of varlist insured-emp_insmax95 {
	replace `var' = . if year == 2012
}
foreach var of varlist insured medical emp_private private emp_ins {
	replace `var' = 0 if year == 2012 
}
label variable insured "Entire U.S.: Currently Insured"
label variable medical "Entire U.S.: On Medicaid"
label variable emp_private "Entire U.S.: Any Private Coverage"
label variable private "Entire U.S.: Ins. Purchased Directly"
label variable emp_ins "Entire U.S.: Ins. Via Employer/Union"

twoway (connected insured year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap insuredmin95 insuredmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.06(.02).1, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label insured', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export insured_US1835.pdf, replace

twoway (connected medical year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap medicalmin95 medicalmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.045(.015).06, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label medical', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export medical_US1835.pdf, replace

twoway (connected emp_private year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap emp_privatemin95 emp_privatemax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.06(.02).08, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label emp_private', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export emp_private_US1835.pdf, replace

twoway (connected private year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap privatemin95 privatemax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.04(.01).04, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label private', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export private_US1835.pdf, replace

twoway (connected emp_ins year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap emp_insmin95 emp_insmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.045(.015).075, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label emp_ins', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export emp_ins_US1835.pdf, replace


*************************
* CALIFORNIA + NEW YORK *
*************************
clear
cd "$path"
use "DACA_ACS_Public_FINAL.dta"
keep if age >= 18 & age <= 35
keep if citizen == 0 & bornoutusa == 1
keep if hsdegree == 1 | somecol == 1 | coldegree == 1 
keep if statefip == 6 | statefip == 36

forvalues x = 2008/2016 {
	gen year`x' = (year == `x')
}

forvalues x = 2008/2016 {
	gen inter`x' = year`x'*dacaelignow
}

foreach var in insured medical emp_private private emp_ins {
	areg `var' inter2016 inter2015 inter2014 inter2013 inter2011 inter2010 inter2009 inter2008 ///
dacaelignow i.age i.ageenterusa somecol coldegree male ethnichisp racewhite raceblack racenatamer raceasian married i.year statedum* [pweight = perwt], a(puma) vce(robust)
	parmest, saving(`var'_CANY1835.dta, replace) format(parm estimate min95 max95)
}

use insured_CANY1835.dta, clear
drop stderr dof t p
rename estimate insured 
rename min95 insuredmin95 
rename max95 insuredmax95

foreach var in medical emp_private private emp_ins {
	merge 1:1 parm using `var'_CANY1835.dta, nogen 
	drop stderr dof t p 
	rename estimate `var'
	rename min95 `var'min95 
	rename max95 `var'max95
}
sort parm

keep if _n >= 69 & _n <= 76
gen year = _n + 2008
replace year = 2013 if parm == "inter2013"
replace year = 2014 if parm == "inter2014"
replace year = 2015 if parm == "inter2015"
replace year = 2016 if parm == "inter2016"
replace year = 2012 if parm == "male"
sort year
drop parm
foreach var of varlist insured-emp_insmax95 {
	replace `var' = . if year == 2012
}
foreach var of varlist insured medical emp_private private emp_ins {
	replace `var' = 0 if year == 2012 
}
label variable insured "California & New York: Currently Insured"
label variable medical "California & New York: On Medicaid"
label variable emp_private "California & New York: Any Private Coverage"
label variable private "California & New York: Ins. Purchased Directly by Indiv."
label variable emp_ins "California & New York: Ins. Via Employer/Union"

twoway (connected insured year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap insuredmin95 insuredmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.06(.02).14, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) xline(2014, lcolor(black) lpattern(dot)) ///
	xtitle(Year) title(`: variable label insured', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016) text(0.13 2014 "Medi-Cal", place(w) box)
graph export insured_CANY1835.pdf, replace

twoway (connected medical year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap medicalmin95 medicalmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.06(.02).10, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) xline(2014, lcolor(black) lpattern(dot)) ///
	xtitle(Year) title(`: variable label medical', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016) text(0.09 2014 "Medi-Cal", place(w) box)
graph export medical_CANY1835.pdf, replace

twoway (connected emp_private year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap emp_privatemin95 emp_privatemax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.08(.02).10, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) xline(2014, lcolor(black) lpattern(dot)) ///
	xtitle(Year) title(`: variable label emp_private', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016) text(0.09 2014 "Medi-Cal", place(w) box)
graph export emp_private_CANY1835.pdf, replace

twoway (connected private year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap privatemin95 privatemax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.06(.015).06, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) xline(2014, lcolor(black) lpattern(dot)) ///
	xtitle(Year) title(`: variable label private', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016) text(0.05 2014 "Medi-Cal", place(w) box)
graph export private_CANY1835.pdf, replace

twoway (connected emp_ins year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap emp_insmin95 emp_insmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.08(.02).10, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) xline(2014, lcolor(black) lpattern(dot)) ///
	xtitle(Year) title(`: variable label emp_ins', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016) text(0.09 2014 "Medi-Cal", place(w) box)
graph export emp_ins_CANY1835.pdf, replace


*******************************
* ENTIRE U.S.(EXCEPT CA & NY) *
*******************************
clear
cd "$path"
use "DACA_ACS_Public_FINAL.dta"
keep if age >= 18 & age <= 35
keep if citizen == 0 & bornoutusa == 1
keep if hsdegree == 1 | somecol == 1 | coldegree == 1
drop if statefip == 6 | statefip == 36

forvalues x = 2008/2016 {
	gen year`x' = (year == `x')
}

forvalues x = 2008/2016 {
	gen inter`x' = year`x'*dacaelignow
}

foreach var in insured medical emp_private private emp_ins {
	areg `var' inter2016 inter2015 inter2014 inter2013 inter2011 inter2010 inter2009 inter2008 ///
dacaelignow i.age i.ageenterusa somecol coldegree male ethnichisp racewhite raceblack racenatamer raceasian married i.year statedum* [pweight = perwt], a(statefip) cluster(stateyear)
	parmest, saving(`var'_nonCANY1835.dta, replace) format(parm estimate min95 max95)
}
 
use insured_nonCANY1835.dta, clear
drop stderr dof t p
rename estimate insured 
rename min95 insuredmin95 
rename max95 insuredmax95

foreach var in medical emp_private private emp_ins {
	merge 1:1 parm using `var'_nonCANY1835.dta, nogen 
	drop stderr dof t p 
	rename estimate `var'
	rename min95 `var'min95 
	rename max95 `var'max95
}
sort parm

keep if _n >= 72 & _n <= 79
gen year = _n + 2008
replace year = 2013 if parm == "inter2013"
replace year = 2014 if parm == "inter2014"
replace year = 2015 if parm == "inter2015"
replace year = 2016 if parm == "inter2016"
replace year = 2012 if parm == "male"
sort year
drop parm
foreach var of varlist insured-emp_insmax95 {
	replace `var' = . if year == 2012
}
foreach var of varlist insured medical emp_private private emp_ins {
	replace `var' = 0 if year == 2012 
}
label variable insured "Entire U.S. (Except CA & NY): Currently Insured"
label variable medical "Entire U.S. (Except CA & NY): On Medicaid"
label variable emp_private "Entire U.S. (Except CA & NY): Any Private Coverage"
label variable private "Entire U.S. (Except CA & NY): Ins. Purchased Directly"
label variable emp_ins "Entire U.S. (Except CA & NY): Ins. Via Employer/Union"

twoway (connected insured year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap insuredmin95 insuredmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.06(.02).1, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label insured', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export insured_nonCANY1835.pdf, replace

twoway (connected medical year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap medicalmin95 medicalmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.045(.015).06, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label medical', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export medical_nonCANY1835.pdf, replace

twoway (connected emp_private year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap emp_privatemin95 emp_privatemax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.06(.02).08, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label emp_private', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export emp_private_nonCANY1835.pdf, replace

twoway (connected emp_ins year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap emp_insmin95 emp_insmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.045(.015).075, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label emp_ins', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export emp_ins_nonCANY1835.pdf, replace

twoway (connected private year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap privatemin95 privatemax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.04(.01).04, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label private', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export private_nonCANY1835.pdf, replace
 
 
 
 
**********************************
**			 Table 1			**
**********************************

global maincontrols intafterelignow dacaelignow afterdaca i.age i.ageenterusa somecol coldegree male /// 
ethnichisp racewhite raceblack racenatamer raceasian married i.year statedum*

************************
* ENTIRE UNITED STATES *
************************
clear
cd "$path"
use "DACA_ACS_Public_FINAL.dta"
keep if age >= 18 & age <= 35
keep if citizen == 0 & bornoutusa == 1
keep if hsdegree == 1 | somecol == 1 | coldegree == 1

areg insured $maincontrols [pweight = perwt], a(statefip) cluster(stateyear)
sum insured if e(sample)==1
outreg2 using ACS_US1835, excel replace se keep(intafterelignow dacaelignow afterdaca) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

foreach var in medical emp_private emp_ins private {
	areg `var' $maincontrols [pweight = perwt], a(statefip) cluster(stateyear)
	sum `var' if e(sample)==1
	outreg2 using ACS_US1835, excel append se keep(intafterelignow dacaelignow afterdaca) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')
}

*************************
* CALIFORNIA + NEW YORK * 
*************************
clear
cd "$path"
use "DACA_ACS_Public_FINAL.dta"
keep if age >= 18 & age <= 35
keep if citizen == 0 & bornoutusa == 1
keep if hsdegree == 1 | somecol == 1 | coldegree == 1
keep if statefip == 6 | statefip == 36

areg insured $maincontrols [pweight = perwt], a(puma) vce(robust)
sum insured if e(sample)==1
outreg2 using ACS_CANY1835, excel replace se keep(intafterelignow dacaelignow afterdaca) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

foreach var in medical emp_private emp_ins private {
	areg `var' $maincontrols [pweight = perwt], a(puma) vce(robust)
	sum `var' if e(sample)==1
	outreg2 using ACS_CANY1835, excel append se keep(intafterelignow dacaelignow afterdaca) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')
}

******************************
* ENTIRE US (EXCEPT CA & NY) * 
******************************
clear
cd "$path"
use "DACA_ACS_Public_FINAL.dta"
keep if age >= 18 & age <= 35
keep if citizen == 0 & bornoutusa == 1
keep if hsdegree == 1 | somecol == 1 | coldegree == 1
drop if statefip == 6 | statefip == 36

areg insured $maincontrols [pweight = perwt], a(statefip) cluster(stateyear)
sum insured if e(sample)==1
outreg2 using ACS_nonCANY1835, excel replace se keep(intafterelignow dacaelignow afterdaca) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

foreach var in medical emp_private emp_ins private {
	areg `var' $maincontrols [pweight = perwt], a(statefip) cluster(stateyear)
	sum `var' if e(sample)==1
	outreg2 using ACS_nonCANY1835, excel append se keep(intafterelignow dacaelignow afterdaca) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')
}
