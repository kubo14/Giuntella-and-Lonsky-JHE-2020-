*************************************************************************************************************************************
* 		Paper: The effects of DACA on health insurance, access to care, and health outcomes 	  	 				   		 		*
* 		Authors: Osea Giuntella, Jakub Lonsky 											  	      	 	 			   		 		*
* 		Data: 2000-2016 National Health Interview Survey (NHIS) pooled yearly public-use samples					  		 		*
*		Data repository: Integrated Public Use Microdata Series (IPUMS) NHIS (https://nhis.ipums.org/nhis/) 		   		 		*
*		Variables needed: REGION, YEAR, INTERVWMO, BIRTHMO, BIRTHYR, YRSINUS, HISPYN, USBORN, CITIZEN, RACEBR, MARST, EDUC,	     	*
*						  AGE, SEX, SCHOOLYR, HEALTH, AEFFORT, AHOPELESS, ANERVOUS, ARESTLESS, ASAD, AWORTHLESS, HOSPNGHT,			*
*						  CARE10X, ERYRNO, VISITYRNO, SAWMENT, HYPERTENS, USUALPL, SAWEYEDR, SAWSPEC, YBARSPECL, FAMDELAYCOST		*
*************************************************************************************************************************************

***************************************************
***			 GENERATING MAIN DATASET 			***
***************************************************
clear
global path "/Users/Lonskyj/Desktop/DACA Project" 
cd "$path"
use "$path/DACA_NHIS_2000_2016.dta"

***********************************
**  	 Cleaning variables 	 **
***********************************
* REGION 
replace region=. if region==09 

* INTERVWMO - month of NHIS interview 
replace intervwmo=. if intervwmo==98 

* MARST - current marital status 
replace marst=. if marst==00 
replace marst=. if marst==99 

* BIRTHMO - month of birth 
replace birthmo=. if birthmo==00 
replace birthmo=. if birthmo>=97 

* BIRTHYR - year of birth
replace birthyr=. if birthyr>=9997

* YRSINUS - number of years spent in US 
replace yrsinus=. if yrsinus==0 
replace yrsinus=. if yrsinus==9 

* HISPYN - hispanic ethnicity
replace hispyn=. if hispyn>=7 

* USBORN - born in US
replace usborn=. if usborn>=97

* CITIZEN - U.S. citizen
replace citizen=. if citizen>=7

* RACEBR - Race Bridge Variable
replace racebr=. if racebr>=97 

* EDUC - educational attainment
replace educ=. if educ==00 
replace educ=. if educ>=97

* SCHOOLYR - attended any kind of school (past 12 months)
replace schoolyr=. if schoolyr==0 
replace schoolyr=. if schoolyr>=7

* HEALTH - health status
replace health = . if health >= 7 

* AEFFORT - felt everything was an effort (past 30 days)
replace aeffort = . if aeffort == 6 
replace aeffort = . if aeffort >=7 

* AHOPELESS - how often felt hopeless (past 30 days)
replace ahopeless = . if ahopeless == 6
replace ahopeless = . if ahopeless >=7

* ANERVOUS - how often felt nervous (past 30 days)
replace anervous = . if anervous == 6 
replace anervous = . if anervous >=7 

* ARESTLESS - how often felt restless (past 30 days)
replace arestless = . if arestless == 6 
replace arestless = . if arestless >=7

* ASAD - how often felt sad (past 30 days)
replace asad = . if asad == 6
replace asad = . if asad >=7 

* AWORTHLESS - how often felt worthless (past 30 days)
replace aworthless = . if aworthless == 6 
replace aworthless = . if aworthless >=7 

* CARE10X - received care 10+ times in past 12 months
replace care10x = . if care10x >= 7

* ERYRNO - number of time in ER/ED in past 12 months
replace eryrno = . if eryrno == 0 
replace eryrno = . if eryrno >= 97 

* VISITYRNO - total office visits (in past 12 months)
replace visityrno = . if visityrno >= 96 

* SAWMENT - saw/talked to mental health profesional (past 12 months)
replace sawment = . if sawment == 0
replace sawment = . if sawment >= 7 


*******************************************
**	 Generating variables for analysis 	 **
*******************************************

****************
* Demographics *
****************
* Male dummy 
gen male = .
replace male = 0 if sex == 2
replace male = 1 if sex == 1
drop sex

*** Married dummy 
gen married = . 
replace married = 0 if marst>=10 & marst<=50
replace married = 1 if marst>=10 & marst<=13
drop marst

*** Hispanic ethnicity dummy 
gen ethnichisp = 0
replace ethnichisp = . if hispyn ==.
replace ethnichisp = 1 if hispyn ==2
drop hispyn

*** Dummy variable for born out of USA 
gen bornoutusa = . 
replace bornoutusa = 0 if usborn==11 | usborn==20 
replace bornoutusa = 1 if usborn==10 | usborn==12
drop usborn

*** Citizen dummy 
replace citizen = 0 if citizen==1
replace citizen = 1 if citizen==2

**** Race dummy variables 
gen racewhite = (racebr == 10)
gen raceblack = (racebr == 20)
gen racenatamer = (racebr == 30)
gen raceasian = (racebr == 40 | racebr == 50 | racebr == 60)
gen raceother = (racebr == 70 | racebr == 80) 
drop racebr

*** Currently attending school 
gen school=.
replace school = 0 if schoolyr == 1 
replace school = 1 if schoolyr == 2 
drop schoolyr

*** Have less than high school degree - dummy
gen lesshs = .
replace lesshs = 0 if educ != .
replace lesshs = 1 if educ <= 13 

*** Have high school degree or equivalent  - dummy
gen hsdegree = .
replace hsdegree = 0 if educ != .
replace hsdegree = 1 if (educ == 14 | educ == 15) 

*** Have some college - dummy
gen somecol = .
replace somecol = 0 if educ != .
replace somecol = 1 if (educ >= 16 & educ <= 18) 

*** Have college degree or more - dummy
gen coldegree = .
replace coldegree = 0 if educ != .
replace coldegree = 1 if (educ >= 19 & educ <= 22) 


************************************
* General/Physical Health Outomces *
************************************
* Good Health dummy (=1 if HEALTH = 1 (Excellent), 2 (Very Good), 3 (Good))
gen good_health = .
replace good_health = 0 if health == 4 | health ==5
replace good_health = 1 if health >= 1 & health <= 3

* Poor Health dummy (=1 if HEALTH = 5 (Poor))
gen poor_health = .
replace poor_health = 0 if health >=1 & health <= 4
replace poor_health = 1 if health == 5

* Ever told had hypertension; 2000-2016; use: SAMPWEIGHT
gen hypertens = .
replace hypertens = 0 if hypertenev == 1
replace hypertens = 1 if hypertenev == 2


**************************
* Mental Health Outcomes *
**************************
* Felt "everything was an effort" (=1 if some/most/all of the time; =0 if none/a little of the time)
gen effort = . 
replace effort = 0 if aeffort==0 | aeffort==1
replace effort = 1 if aeffort>=2 & aeffort<=4

* Felt hopeless (=1 if some/most/all of the time; =0 if none/a little of the time)
gen hopeless = . 
replace hopeless = 0 if ahopeless==0 | ahopeless==1
replace hopeless = 1 if ahopeless>=2 & ahopeless<=4

* Felt nervous (=1 if some/most/all of the time; =0 if none/a little of the time)
gen nervous = . 
replace nervous = 0 if anervous==0 | anervous==1
replace nervous = 1 if anervous>=2 & anervous<=4

* Felt restless (=1 if some/most/all of the time; =0 if none/a little of the time)
gen restless = . 
replace restless = 0 if arestless==0 | arestless==1
replace restless = 1 if arestless>=2 & arestless<=4

* Felt sad (=1 if some/most/all of the time; =0 if none/a little of the time)
gen sad = . 
replace sad = 0 if asad==0 | asad==1
replace sad = 1 if asad>=2 & asad<=4

* Felt worthless (=1 if some/most/all of the time; =0 if none/a little of the time)
gen worthless = . 
replace worthless = 0 if aworthless==0 | aworthless==1
replace worthless = 1 if aworthless>=2 & aworthless<=4


************************************
* Health Care Access & Utilization *
************************************
* Total office visits (past 12 mo.); use: SAMPWEIGHT
gen Total_visits = . 
replace Total_visits = 0 if visityrno == 0 /* None */
replace Total_visits = 1 if visityrno == 10 /* 1 visit */
replace Total_visits = 2 if visityrno == 20 /* 2-3 visits */
replace Total_visits = 3 if visityrno == 31 /* 4-5 visits */
replace Total_visits = 4 if visityrno == 32 /* 6-7 visits */
replace Total_visits = 5 if visityrno == 33 /* 8-9 visits */
replace Total_visits = 6 if visityrno == 40 /* 10-12 visits */
replace Total_visits = 7 if visityrno == 51 /* 13-15 visits */
replace Total_visits = 8 if visityrno == 52 /* 16 or more visits */
drop visityrno

* Seen (any) doctor in past 12 months (dummy); use SAMPWEIGHT
gen Doctor = .
replace Doctor = 0 if Total_visits == 0
replace Doctor = 1 if Total_visits >= 1 & Total_visits <= 8

* Number of ER/ED visits (past 12 mo.); use: SAMPWEIGHT
gen ER_visits = .
replace ER_visits = 0 if eryrno == 10 /* None */
replace ER_visits = 1 if eryrno == 20 /* 1 visit */
replace ER_visits = 2 if eryrno == 30 /* 2-3 visits */
replace ER_visits = 3 if eryrno == 41 /* 4-5 visits */
replace ER_visits = 4 if eryrno == 42 /* 6-7 visits */
replace ER_visits = 5 if eryrno == 43 /* 8-9 visits */
replace ER_visits = 6 if eryrno == 50 /* 10-12 visits */
replace ER_visits = 7 if eryrno == 61 /* 13-15 visits */
replace ER_visits = 8 if eryrno == 62 /* 16 or more visits */
drop eryrno

* Visited ER in past 12 months (dummy); use SAMPWEIGHT
gen ER_dummy = .
replace ER_dummy = 0 if ER_visits == 0
replace ER_dummy = 1 if ER_visits >= 1 & ER_visits <= 8

* Received care 10+ times (past 12 mo.) dummy; use: PERWEIGHT
replace care10x = 0 if care10x == 1 
replace care10x = 1 if care10x == 2 

* Has usual place for medical care 
gen usual = .
replace usual = 0 if usualpl == 1 
replace usual = 1 if (usualpl == 2 | usualpl == 3)
drop usualpl

* Saw/talked to eye doctor (i.e. optometrist, ophthalmologist, or eye doctor) (past 12 months)
gen saweyedoc = .
replace saweyedoc = 0 if saweyedr == 1 
replace saweyedoc = 1 if saweyedr == 2
drop saweyedr

* Saw/talked to medical specialist (past 12 months) 
gen sawspecial = .
replace sawspecial = 0 if sawspec == 1 
replace sawspecial = 1 if sawspec == 2
drop sawspec

* Needed but couldn't afford specialist (past 12 mo.); use: SAMPWEIGHT
gen specialnotaff = .
replace specialnotaff = 0 if ybarspecl == 1
replace specialnotaff = 1 if ybarspecl == 2
drop ybarspecl

* Any family member delayed seeking medical care due to cost (past 12 mo.); use: PERWEIGHT
gen famdelayduecost = .
replace famdelayduecost = 0 if famdelaycost == 1 
replace famdelayduecost = 1 if famdelaycost == 2 
drop famdelaycost

* Was in a hospital overnight (past 12 mo.); use: PERWEIGHT
gen hospnight = .
replace hospnight = 0 if hospnght == 1
replace hospnight = 1 if hospnght == 2
drop hospnght

* Saw mental health prof. (past 12 mo.) dummy; use: SAMPWEIGHT
replace sawment = 0 if sawment == 1 
replace sawment = 1 if sawment == 2 


**********************************************
** 	Generating DACA-Eligibibility variable  **
**********************************************

*******************
* UPPER AGE LIMIT * 
*******************
gen under31now = 0 
replace under31now = 1 if ((birthyr == year - 32 & birthmo >= 7) | (birthyr >= year - 31)) & year<=2013 & birthmo !=. & birthyr !=. 
replace under31now = 1 if ((birthyr == year - 33 & birthmo >= 7) | (birthyr >= year - 32)) & year==2014 & birthmo !=. & birthyr !=. 

replace under31now = 1 if ((age < 31 & intervwmo <= 6) | (age == 31 & intervwmo <= 6 & birthyr == year - 31) | (age < 32 & intervwmo >= 7)) & year<=2013 & birthmo ==. & birthyr !=. 
replace under31now = 1 if ((age < 32 & intervwmo <= 6) | (age == 32 & intervwmo <= 6 & birthyr == year - 32) | (age < 33 & intervwmo >= 7)) & year==2014 & birthmo ==. & birthyr !=.  
replace under31now = 1 if ((age < 33 & intervwmo <= 6) | (age == 33 & intervwmo <= 6 & birthyr == year - 33) | (age < 34 & intervwmo >= 7)) & year==2015 & birthmo ==. & birthyr !=.  
replace under31now = 1 if ((age < 34 & intervwmo <= 6) | (age == 34 & intervwmo <= 6 & birthyr == year - 34) | (age < 35 & intervwmo >= 7)) & year==2016 & birthmo ==. & birthyr !=. 

replace under31now = 1 if ((age < 32 & birthmo < intervwmo) | (age == 32 & birthmo < intervwmo & intervwmo >= 8 & birthmo >= 7) | ///
(age < 31 & birthmo > intervwmo) | (age == 31 & birthmo > intervwmo & birthmo >= 7) | (age < 31 & birthmo == intervwmo) | ///
(age == 31 & birthmo == intervwmo & birthmo >= 7)) & year<=2013 & birthmo !=. & birthyr ==.

replace under31now = 1 if ((age < 33 & birthmo < intervwmo) | (age == 33 & birthmo < intervwmo & intervwmo >= 8 & birthmo >= 7) | ///
(age < 32 & birthmo > intervwmo) | (age == 32 & birthmo > intervwmo & birthmo >= 7) | (age < 32 & birthmo == intervwmo) | ///
(age == 32 & birthmo == intervwmo & birthmo >= 7)) & year==2014 & birthmo !=. & birthyr ==.

replace under31now = 1 if ((age < 31 & intervwmo <= 6) | (age < 32 & intervwmo >= 7)) & year<=2013 & birthmo ==. & birthyr ==. 
replace under31now = 1 if ((age < 32 & intervwmo <= 6) | (age < 33 & intervwmo >= 7)) & year==2014 & birthmo ==. & birthyr ==. 
replace under31now = 1 if ((age < 33 & intervwmo <= 6) | (age < 34 & intervwmo >= 7)) & year==2015 & birthmo ==. & birthyr ==.
replace under31now = 1 if ((age < 34 & intervwmo <= 6) | (age < 35 & intervwmo >= 7)) & year==2016 & birthmo ==. & birthyr ==.

**************************
* ENTER US BEFORE AGE 16 *
**************************
gen enterunder16 = . 
replace enterunder16 = 0 if yrsinus != . 
replace enterunder16 = 1 if (age <=15 & yrsinus == 1) | (age ==16 & yrsinus == 1) 
replace enterunder16 = 1 if age <=16 & yrsinus == 2
replace enterunder16 = 1 if age <=20 & yrsinus == 3
replace enterunder16 = 1 if age <=25 & yrsinus == 4
replace enterunder16 = 1 if age <=30 & yrsinus == 5
replace enterunder16 = 1 if age <=35 & yrsinus == 5

*****************************
* LENGTH OF RESIDENCE IN US *
*****************************
gen liveusa5now = . 
replace liveusa5now = 0 if yrsinus != . 
replace liveusa5now = 1 if (yrsinus >= 3 & yrsinus <=5) & year <= 2013 
replace liveusa5now = 1 if (yrsinus >= 3 & yrsinus <=5) & year == 2014 
replace liveusa5now = 1 if (yrsinus >= 4 & yrsinus <=5) & year == 2015  
replace liveusa5now = 1 if (yrsinus >= 4 & yrsinus <=5) & year == 2016  

**********************************
* EDUCATION REQUIREMENT FOR DACA *
**********************************
gen meetedreq = 0 
replace meetedreq = 1 if hsdegree == 1 | somecol == 1 | coldegree == 1 
replace meetedreq = 1 if school == 1

********************
* DACA ELIGIBILITY *
********************
gen dacaelignow = 0 
replace dacaelignow = 1 if under31now == 1 & enterunder16 == 1 & liveusa5now == 1 ///
	 & meetedreq == 1 & citizen == 0 & bornoutusa == 1 & age >= 15
 
**************
* POST DUMMY *
**************
gen afterdaca = 0 
replace afterdaca = 1 if year >= 2013

****************
* INTERACTIONS *
****************
gen intafterelignow = afterdaca * dacaelignow

sort region year
egen regionyear = group(region year)
tab region, gen(regiondum)
for num 01/04: replace regiondumX = regiondumX*year 

* Month of interview 
gen month = intervwmo

* Year FE, Month FE, Year-Month FE
forvalues x = 2000/2016 {
	gen year`x' = (year == `x')
}

forvalues y = 1/12 {
	gen month`y' = (month == `y')
}

forvalues x = 2000/2016 {
forvalues y = 1/12 {
	gen yearmonth`x'_`y' = year`x' * month`y'
}
}
compress
save "DACA_NHIS_Public_FINAL.dta", replace





************************************************************
************************************************************
***			ANALYSIS (NHIS: MAIN TABLES & FIGURES)		 ***
************************************************************
************************************************************

***********************************************
***				 FIGURES 4,5,7 				***
***********************************************
clear
cd "$path"
use "DACA_NHIS_Public_FINAL.dta"
keep if age >= 18 & age <= 50
keep if hsdegree == 1 | somecol == 1 | coldegree == 1

forvalues x = 2000/2016 {
	gen inter`x' = year`x'*dacaelignow
}

foreach var in selfhealth good_health care10x {
	areg `var' inter2016 inter2015 inter2014 inter2013 inter2011 inter2010 inter2009 inter2008 inter2007 inter2006 inter2005 inter2004 inter2003 inter2002 inter2001 inter2000 ///
	dacaelignow i.age somecol coldegree male ethnichisp racewhite raceblack racenatamer raceasian married i.year regiondum* [pweight = perweight], a(region) robust
	parmest, saving(`var'.dta, replace) format(parm estimate min95 max95)
}

foreach var in sawment usual hopeless sad k6 k6_dummy {
	areg `var' inter2016 inter2015 inter2014 inter2013 inter2011 inter2010 inter2009 inter2008 inter2007 inter2006 inter2005 inter2004 inter2003 inter2002 inter2001 inter2000 ///
	dacaelignow i.age somecol coldegree male ethnichisp racewhite raceblack racenatamer raceasian married i.year regiondum* [pweight = sampweight], a(region) robust
	parmest, saving(`var'.dta, replace) format(parm estimate min95 max95)
}

foreach var in famdelayduecost hospnight {
	areg `var' inter2016 inter2015 inter2014 inter2013 inter2011 inter2010 inter2009 inter2008 inter2007 inter2006 inter2005 inter2004 inter2003 inter2002 inter2001 inter2000 ///
	dacaelignow i.age somecol coldegree male ethnichisp racewhite raceblack racenatamer raceasian married i.year regiondum* [pweight = perweight], a(region) robust
	parmest, saving(`var'.dta, replace) format(parm estimate min95 max95)
}

foreach var in Total_visits Doctor ER_dummy {
	areg `var' inter2016 inter2015 inter2014 inter2013 inter2011 inter2010 inter2009 inter2008 inter2007 inter2006 inter2005 inter2004 inter2003 inter2002 inter2001 inter2000 ///
	dacaelignow i.age somecol coldegree male ethnichisp racewhite raceblack racenatamer raceasian married i.year regiondum* [pweight = sampweight], a(region) robust
	parmest, saving(`var'.dta, replace) format(parm estimate min95 max95)
}

use usual.dta, clear
drop stderr dof t p
rename estimate usual 
rename min95 usualmin95 
rename max95 usualmax95

foreach var in Doctor Total_visits ER_dummy hospnight care10x sawment selfhealth hopeless sad k6 famdelayduecost good_health k6_dummy {
	merge 1:1 parm using `var'.dta, nogen 
	drop stderr dof t p 
	rename estimate `var'
	rename min95 `var'min95 
	rename max95 `var'max95
}
sort parm

keep if _n >= 64 & _n <= 71
gen year = _n + 2008
replace year = 2013 if parm == "inter2013"
replace year = 2014 if parm == "inter2014"
replace year = 2015 if parm == "inter2015"
replace year = 2016 if parm == "inter2016"
replace year = 2012 if parm == "male"
sort year
drop parm

foreach var of varlist usual-k6_dummymax95 {
	replace `var' = . if year == 2012
}
foreach var of varlist usual Doctor Total_visits ER_dummy hospnight care10x sawment selfhealth hopeless sad k6 famdelayduecost good_health k6_dummy {
	replace `var' = 0 if year == 2012 
}
label variable usual "NHIS: Has Usual Place for Medical Care"
label variable Doctor "NHIS: Saw Any Doctor (Past 12 Mo.)"
label variable Total_visits "NHIS: # Doctor Visits (Past 12 Mo.)"
label variable ER_dummy "NHIS: Visited ER (Past 12 Mo.)"
label variable hospnight "NHIS: Overnight in Hospital (Past 12 Mo.)"
label variable care10x "NHIS: Received Care 10+ Times (Past 12 Mo.)"
label variable sawment "NHIS: Saw Mental Health Prof. (Past 12 Mo.)"
label variable selfhealth "NHIS: Self-Reported Health Status"
label variable good_health "NHIS: Currently in Good Health"
label variable hopeless "NHIS: Felt Hopeless (Past 30 Days)"
label variable sad "NHIS: Felt Depressed (Past 30 Days)"
label variable k6 "NHIS: Kessler 6 Scale (K6)"
label variable k6_dummy "NHIS: Moderate/Serious Psych. Distress (K6>=5)"
label variable famdelayduecost "NHIS: Family Memb. Delayed Care B/C Cost (Past Yr.)"
 
************************************
* Health Care Access/Affordability *
************************************
twoway (connected usual year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap usualmin95 usualmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.40(.10).50, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label usual', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export usual_NHIS.pdf, replace

twoway (connected famdelayduecost year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap famdelayduecostmin95 famdelayduecostmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.20(.05).15, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label famdelayduecost', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export famdelayduecost_NHIS.pdf, replace

*******************
* Health Care Use *
*******************
twoway (connected Doctor year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap Doctormin95 Doctormax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.4(.1).5, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label Doctor', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export Doctor_NHIS.pdf, replace

twoway (connected Total_visits year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap Total_visitsmin95 Total_visitsmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-1.6(.4)1.6, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label Total_visits', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export Total_visits_NHIS.pdf, replace

twoway (connected care10x year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap care10xmin95 care10xmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.10(.025).125, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label care10x', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export care10x_NHIS.pdf, replace

twoway (connected hospnight year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap hospnightmin95 hospnightmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.12(.03).09, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label hospnight', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export hospnight_NHIS.pdf, replace

twoway (connected ER_dummy year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap ER_dummymin95 ER_dummymax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.3(.1).3, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label ER_dummy', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export ER_dummy_NHIS.pdf, replace

twoway (connected sawment year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap sawmentmin95 sawmentmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.09(.03).15, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label sawment', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export sawment_NHIS.pdf, replace

******************
* General Health *
******************
twoway (connected selfhealth year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap selfhealthmin95 selfhealthmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-0.32(0.08)0.40, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label selfhealth', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export selfhealth_NHIS.pdf, replace

twoway (connected good_health year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap good_healthmin95 good_healthmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-0.08(0.02)0.1, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label good_health', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export good_health_NHIS.pdf, replace

twoway (connected sad year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap sadmin95 sadmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.32(.08).32, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label sad', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export sad_NHIS.pdf, replace

twoway (connected hopeless year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap hopelessmin95 hopelessmax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-.24(.06).24, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label hopeless', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export hopeless_NHIS.pdf, replace

twoway (connected k6 year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap k6min95 k6max95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-3.2(0.8)3.2, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label k6', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export k6_NHIS.pdf, replace

twoway (connected k6_dummy year, mcolor(black) lcolor(black) msymbol(circle) lpattern(solid)) ///
	(rcap k6_dummymin95 k6_dummymax95 year, lcolor(black)), ///
	legend(off) ytitle(DACA-Eligible x Year Interaction)  ///
	ylabel(-0.32(0.08)0.32, angle(0) format(%9.0gc)) graphregion(color(white)) xline(2012, lcolor(black) lpattern(dash)) ///
	xtitle(Year) title(`: variable label k6_dummy', color(black)) xlab(2009 2010 2011 2012 2013 2014 2015 2016)
graph export k6_dummy_NHIS.pdf, replace




*******************************************
***			 TABLES 2,4,6				***
*******************************************
global maincontrols intafterelignow dacaelignow afterdaca i.age i.ageenterusa somecol coldegree male /// 
ethnichisp racewhite raceblack racenatamer raceasian married i.year statedum*


***********
* Table 2 *
***********
clear
cd "$path"
use "DACA_NHIS_Public_FINAL.dta"
keep if age >= 18 & age <= 50
keep if hsdegree == 1 | somecol == 1 | coldegree == 1

areg usual $maincontrols [pweight = sampweight], a(region) robust
sum usual if e(sample)==1
outreg2 using NHIS_Table2, excel replace se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

areg famdelayduecost $maincontrols [pweight = perweight], a(region) robust
sum famdelayduecost if e(sample)==1
outreg2 using NHIS_Table2, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg specialnotaff $maincontrols [pweight = sampweight], a(region) robust
sum specialnotaff if e(sample)==1
outreg2 using NHIS_Table2, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')


***********
* Table 4 *
***********
clear
cd "$path"
use "DACA_NHIS_Public_FINAL.dta"
keep if age >= 18 & age <= 50
keep if hsdegree == 1 | somecol == 1 | coldegree == 1

areg Doctor $maincontrols [pweight = sampweight], a(region) robust
sum Doctor if e(sample)==1
outreg2 using NHIS_Table4, excel replace se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg Total_visits $maincontrols [pweight = sampweight], a(region) robust
sum Total_visits if e(sample)==1
outreg2 using NHIS_Table4, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg care10x $maincontrols [pweight = perweight], a(region) robust
sum care10x if e(sample)==1
outreg2 using NHIS_Table4, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg hospnight $maincontrols [pweight = perweight], a(region) robust
sum hospnight if e(sample)==1
outreg2 using NHIS_Table4, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg ER_dummy $maincontrols [pweight = sampweight], a(region) robust
sum ER_dummy if e(sample)==1
outreg2 using NHIS_Table4, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg sawspecial $maincontrols [pweight = sampweight], a(region) robust
sum sawspecial if e(sample)==1
outreg2 using NHIS_Table4, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg saweyedoc $maincontrols [pweight = sampweight], a(region) robust
sum saweyedoc if e(sample)==1
outreg2 using NHIS_Table4, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg sawment $maincontrols [pweight = sampweight], a(region) robust
sum sawment if e(sample)==1
outreg2 using NHIS_Table4, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')


***********
* Table 6 *
***********
clear
cd "$path"
use "DACA_NHIS_Public_FINAL.dta"
keep if age >= 18 & age <= 50
keep if hsdegree == 1 | somecol == 1 | coldegree == 1

areg selfhealth $maincontrols [pweight = perweight], a(region) robust
sum selfhealth if e(sample)==1
outreg2 using NHIS_Table6, excel replace se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

areg poor_health $maincontrols [pweight = perweight], a(region) robust
sum poor_health if e(sample)==1
outreg2 using NHIS_Table6, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)')

areg good_health $maincontrols [pweight = perweight], a(region) robust
sum good_health if e(sample)==1
outreg2 using NHIS_Table6, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

areg sad $maincontrols [pweight = sampweight], a(region) robust
sum sad if e(sample)==1
outreg2 using NHIS_Table6, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

areg hopeless $maincontrols [pweight = sampweight], a(region) robust
sum hopeless if e(sample)==1
outreg2 using NHIS_Table6, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

areg effort $maincontrols [pweight = sampweight], a(region) robust
sum effort if e(sample)==1
outreg2 using NHIS_Table6, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

areg k6 $maincontrols [pweight = sampweight], a(region) robust
sum k6 if e(sample)==1
outreg2 using NHIS_Table6, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

areg k6_dummy $maincontrols [pweight = sampweight], a(region) robust
sum k6_dummy if e(sample)==1
outreg2 using NHIS_Table6, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

areg hypertens $maincontrols [pweight = sampweight], a(region) robust
sum hypertens if e(sample)==1
outreg2 using NHIS_Table6, excel append se keep(intafterelignow dacaelignow afterdaca somecol coldegree male racewhite raceblack raceasian racenatamer married ethnichisp) bdec(4) nocons adds(Mean of Dep. Var., `r(mean)', std. dev.,`r(sd)') 

