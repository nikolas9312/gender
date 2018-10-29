
/*-------------------------------------------------------------------------------*
 Gender-Segmented Labor Markets and the Effects of Local Demand Shocks
 Juan Pablo Chauvin - Juan Nicolas Herrera

 Purpose: Script to create graphs of the gender composition of industries in brazil
 Created by: JN Herrera
 Created on: October 2017
 Last modified on: October 29 2018
 Last modified by: JN Herrera
 Edits history:
	- [10/19/2018] - JNH:	Created first version 

*-------------------------------------------------------------------------------*/


cd "\\hqpnas01\res_nas\Research\jpchauvin\projects\gender_demand_shocks\analysis"

use ".\inputs\indext_panel_wa_wdom_gender_skills.dta", replace

#delimit ;

// Exporting industry level composition of the workforce table

local table "indext sh_ind_tot_emp sh_mal sh_fem sh_h sh_l sh_mal_l sh_mal_h sh_fem_l sh_fem_h";
foreach var in `table' {;	format `var' %12.2f;};

foreach y in 1980 1991 2000 2010 {;
	export excel `table' using ".\outputs\tables\industry_level_composition_workforce.xlsx" 
	if year==`y' & indext!=. , sheet("`y'") firstrow(varl) sheetreplace; };

// Industry level composition of the workforce stacked bars

#delimit ;
levelsof ind, local(levels);
foreach ind in `levels' {; sum sh_ind_tot_emp if ind=="`ind'" & year==1980; local tot1=string(`r(sum)'*100,"%3.2f"); 
	sum sh_ind_tot_emp if ind=="`ind'" & year==1991; local tot2=string(`r(sum)'*100,"%3.2f"); 
	sum sh_ind_tot_emp if ind=="`ind'" & year==2000; local tot3=string(`r(sum)'*100,"%3.2f");
	sum sh_ind_tot_emp if ind=="`ind'" & year==2010; local tot4=string(`r(sum)'*100,"%3.2f"); 
	local nam=substr("`ind'",1,4); if "`ind'"=="Petroleum Refining and Petrochemical Manufacturing" {; local nam="Refi";};
	graph bar sh_fem_l sh_fem_h sh_mal_l sh_mal_h  if ind=="`ind'" , over(year) stack ytitle("Percentage")
		legend(order(1 "Female low" 2 "Female High" 3 "Male low" 4 "Male high"))  
		title("`ind' Industry" "Gender/Skill Workforce Composition", size(medlarge)) 
		graphregion(color(white)) note("Note: Share of industry in total employment: 1980=`tot1'%, 1991=`tot2'%, 2000=`tot3'%, 2010=`tot4'%, " 
		"High is related to a high skill worker defined as an individual with more than high school education.", size(vsmall));		
		graph export ".\outputs\graphs\workforce_composition_gender_skill_`nam'.png", replace;};

// Share of high skilled and share of female labor by year

local y sh_h ; ; local x sh_fem; local ly : variable label `y' ; local lx : variable label `x' ; levelsof year, local(levels);
foreach yr in `levels' {;		
	 cap {; reg `y' `x' if year==`yr', r; local r2: display %5.2f e(r2); 	
		    local r_cons: display %5.3f _b[_cons] ; local r_cons_se: display %5.3f _se[_cons] ;
		    local r_coeff: display %5.3f _b[`x'] ; local r_coeff_se: display %5.3f _se[`x'] ; predict hat;
		if `r_coeff'>=0 {;
			graph twoway (lfit `y' `x') (scatter `y' `x', mlabel(marker_ind)) if year==`yr' , title("Relation between `ly'" "and `lx' in `yr'", si(small)) 
			ytitle("`ly'", si(vsmall) height(6)) 	xtitle("`lx'", si(small) height(6))  graphregion(color(white)) legend(off)
			note("Regression: Y = `r_cons' (`r_cons_se') + `r_coeff' (`r_coeff_se') X . R2 =`r2'", position(6));
			drop hat; graph export ".\outputs\graphs\share_high_female_`yr'.png", replace; };
		if `r_coeff'<0 {;
			graph twoway (lfit `y' `x') (scatter `y' `x', mlabel(marker_ind)) if year==`yr' , title("Relation between `ly'" "and `lx' in `yr'", si(small)) 
			ytitle("`ly'", si(vsmall) height(6)) xtitle("`lx'", si(small) height(6))  graphregion(color(white))
			note("Regression: Y = `r_cons' (`r_cons_se')  `r_coeff' (`r_coeff_se') X . R2 =`r2'", position(6));
			drop hat; graph export ".\outputs\graphs\share_high_female_`yr'.png", replace; }; }; };	

// Change in the share of high skilled and change in the share of female labor by year			

#delimit ; 
foreach delta in "1991_1980" "2000_1991" "2010_2000" {;
	local y d_sh_h_`delta' ; local x d_sh_fem_`delta'; local ly : variable label `y';
	local lx : variable label `x' ; local yr=substr("`y'",-4,4); 
		 reg `y' `x' if year==`yr', r; local r2: display %5.2f e(r2); 	
		    local r_cons: display %5.3f _b[_cons] ; local r_cons_se: display %5.3f _se[_cons] ;
		    local r_coeff: display %5.3f _b[`x'] ; local r_coeff_se: display %5.3f _se[`x'] ; predict hat;
		if `r_coeff'>=0 {;
			graph twoway (lfit `y' `x') (scatter `y' `x' , mlabel(marker_ind)) if year==`yr' , title("Relation between the `ly'" "and the `lx' ", si(small)) 
			ytitle("`ly'", si(vsmall) height(6)) 	xtitle("`lx'", si(small) height(6))  graphregion(color(white)) legend(off) 
			note("Regression: Y = `r_cons' (`r_cons_se') + `r_coeff' (`r_coeff_se') X . R2 =`r2'", position(6));
			drop hat; graph export ".\outputs\graphs\delta_share_high_female_`delta'.png", replace; };
		if `r_coeff'<0 {;
			graph twoway (lfit `y' `x') (scatter `y' `x' , mlabel(marker_ind)) if year==`yr' , title("Relation between the `ly'" "and the`lx'", si(small)) 
			ytitle("`ly'", si(vsmall) height(6)) xtitle("`lx'", si(small) height(6))  graphregion(color(white)) legend(off)
			note("Regression: Y = `r_cons' (`r_cons_se')  `r_coeff' (`r_coeff_se') X . R2 =`r2'", position(6));
			drop hat; graph export ".\outputs\graphs\delta_share_high_female_`delta'.png", replace; }; }; 
	
// Change in the share of high skilled/female compared to the baseline year

#delimit ; 
foreach var in sh_h sh_fem{;
foreach delta in "1991_1980" "2000_1991" "2010_2000" {;
	local y d_`var'_`delta' ; local x `var'; local ly : variable label `y';
	local lx : variable label `x' ; local yr=substr("`y'",-4,4); 
		qui reg `y' `x' if year==`yr', r; local r2: display %5.2f e(r2); 	
		    local r_cons: display %5.3f _b[_cons] ; local r_cons_se: display %5.3f _se[_cons] ;
		    local r_coeff: display %5.3f _b[`x'] ; local r_coeff_se: display %5.3f _se[`x'] ; predict hat;
		if `r_coeff'>=0 {;
			graph twoway (lfit `y' `x') (scatter `y' `x' , mlabel(marker_ind)) if year==`yr' , title("Relation between the `ly'" "and the `lx' `yr' ", si(small)) 
			ytitle("`ly'", si(vsmall) height(6)) 	xtitle("`lx'", si(small) height(6))  graphregion(color(white)) legend(off) 
			note("Regression: Y = `r_cons' (`r_cons_se') + `r_coeff' (`r_coeff_se') X . R2 =`r2'", position(6));
			drop hat; graph export ".\outputs\graphs\delta_baseline_`var'_`delta'.png", replace; };
		if `r_coeff'<0 {;
			graph twoway (lfit `y' `x') (scatter `y' `x' , mlabel(marker_ind)) if year==`yr' , title("Relation between the `ly'" "and the `lx' in `yr'", si(small)) 
			ytitle("`ly'", si(vsmall) height(6)) xtitle("`lx'", si(small) height(6))  graphregion(color(white)) legend(off)
			note("Regression: Y = `r_cons' (`r_cons_se')  `r_coeff' (`r_coeff_se') X . R2 =`r2'", position(6));
			drop hat; graph export ".\outputs\graphs\delta_baseline_`var'_`delta'.png", replace; }; }; }; 

// Correlation graphs

*Crossection;

#delimit ; 
gen corr_m_l_f_l=. ; gen corr_m_l_f_h=. ; gen corr_m_l_m_h=. ;
gen corr_m_h_f_l=. ; gen corr_m_h_f_h=. ; gen corr_f_l_f_h=. ;

foreach yr in 1980 1991 2000 2010 {;
	corr sh_mal_l sh_mal_h sh_fem_l  sh_fem_h if year==`yr' ; matrix c=r(C);
	replace corr_m_l_m_h=c[2,1] if year==`yr'; replace corr_m_l_f_l=c[3,1] if year==`yr' ;
	replace corr_m_l_f_h=c[4,1] if year==`yr'; replace corr_m_h_f_l=c[3,2] if year==`yr'; 
	replace corr_m_h_f_h=c[4,2] if year==`yr'; replace corr_f_l_f_h=c[4,3] if year==`yr'; matrix drop c ;} ;
#delimit ; 
preserve;
	collapse (mean) corr_m_l_m_h corr_m_l_f_l corr_m_l_f_h corr_m_h_f_l corr_m_h_f_h corr_f_l_f_h ,by(year) ;
	merge 1:m year using ".\inputs\correlation.dta", nogen ;
	replace correlation=corr_m_l_m_h if gender_skill=="ML-MH" ; replace correlation=corr_m_l_f_l if gender_skill=="ML-FL" ;
	replace correlation=corr_m_l_f_h if gender_skill=="ML-FH"; replace correlation=corr_m_h_f_l if gender_skill=="MH-FL" ;
	replace correlation=corr_m_h_f_h if gender_skill=="MH-FH" ; replace correlation=corr_f_l_f_h if gender_skill=="FL-FH" ;
	drop corr_m_l_m_h corr_m_l_f_l corr_m_l_f_h corr_m_h_f_l corr_m_h_f_h corr_f_l_f_h ;
	reshape wide correlation, i(gender_skill) j(year) ; sort gender_skill ;
	#delimit ; 
	graph dot (mean) correlation1980 correlation1991 correlation2000 correlation2010 , over(gender_skill ) 
		marker(1 , msymbol(diamond))  marker(2 , msymbol(triangle)) marker(1 , msymbol(square))  
		legend(lab( 1 "1980") lab(2 "1991") lab(3 "2000") lab(4 "2010") ) title("Skill/gender industrial employment share correlations by year ", span)
		graphregion(color(white)) ; graph export ".\outputs\graphs\skill_gender_share_correlations.png", replace;
restore;					

* Changes;
#delimit ; 
foreach delta in "1991_1980" "2000_1991" "2010_2000" {; local yr=substr("`delta'",-4,4);
	corr d_sh_mal_l_`delta' d_sh_mal_h_`delta' d_sh_fem_l_`delta' d_sh_fem_h_`delta' if year==`yr' ; matrix c=r(C);
	replace corr_m_l_m_h=c[2,1] if year==`yr'; replace corr_m_l_f_l=c[3,1] if year==`yr' ;
	replace corr_m_l_f_h=c[4,1] if year==`yr'; replace corr_m_h_f_l=c[3,2] if year==`yr'; 
	replace corr_m_h_f_h=c[4,2] if year==`yr'; replace corr_f_l_f_h=c[4,3] if year==`yr'; matrix drop c ;} ;	
#delimit ;
preserve;
	collapse (mean) corr_m_l_m_h corr_m_l_f_l corr_m_l_f_h corr_m_h_f_l corr_m_h_f_h corr_f_l_f_h ,by(year) ;
	merge 1:m year using ".\inputs\correlation.dta", nogen ;
	replace correlation=corr_m_l_m_h if gender_skill=="ML-MH" ; replace correlation=corr_m_l_f_l if gender_skill=="ML-FL" ;
	replace correlation=corr_m_l_f_h if gender_skill=="ML-FH"; replace correlation=corr_m_h_f_l if gender_skill=="MH-FL" ;
	replace correlation=corr_m_h_f_h if gender_skill=="MH-FH" ; replace correlation=corr_f_l_f_h if gender_skill=="FL-FH" ;
	drop corr_m_l_m_h corr_m_l_f_l corr_m_l_f_h corr_m_h_f_l corr_m_h_f_h corr_f_l_f_h ;
	reshape wide correlation, i(gender_skill) j(year) ; sort gender_skill ;
	#delimit ; 
	graph dot (mean) correlation1980 correlation1991 correlation2000 , over(gender_skill ) 
		marker(1 , msymbol(diamond))  marker(2 , msymbol(triangle)) 
		legend(lab( 1 "1980-1991") lab(2 "1991-2000") lab(3 "2000-2010") ) title("Skill/gender decade change of industrial employment" "share correlations by decade ", span)
		graphregion(color(white)) ; graph export ".\outputs\graphs\skill_gender_share_decade_change_correlations.png", replace;
restore;					

// Industry level composition of the workforce stacked bars

#delimit ;
preserve;
local shares "sh_mal_l1 sh_mal_l2 sh_mal_l3 sh_mal_l4 sh_mal_l5 sh_mal_h1 sh_mal_h2 sh_mal_h3 sh_mal_h4 sh_mal_h5 sh_fem_l1 sh_fem_l2 sh_fem_l3 sh_fem_l4 sh_fem_l5 sh_fem_h1 sh_fem_h2 sh_fem_h3 sh_fem_h4 sh_fem_h5";	
keep indext year `shares'; display "`shares'";
reshape long sh_mal_l sh_mal_h sh_fem_l sh_fem_h, i( year indext ) j(macroreg);

decode indext, gen(ind); decode macroreg, gen(reg);	
#delimit ; 
levelsof ind, local(levels); levelsof year, local(year);
foreach ind in `levels' {;
	foreach yr in `year' {;
		local nam=substr("`ind'",1,4); if "`ind'"=="Petroleum Refining and Petrochemical Manufacturing" {; local nam="Refi";};
		graph bar sh_fem_l sh_fem_h sh_mal_l sh_mal_h if ind=="`ind'" & year==`yr' , 
		over(reg) stack ytitle("Percentage") legend(order(1 "Female low" 2 "Female High" 3 "Male low" 4 "Male high"))  
		title("`ind' Industry" "Gender/Skill Workforce Composition in `yr'", size(medlarge)) 
		graphregion(color(white)) note("Note: High is related to a high skill worker defined as an individual with more than high school education.", size(vsmall));
		graph export ".\outputs\graphs\macroregion_workforce_composition_gender_skill_`nam'_`yr'.png", replace; };	};	
restore;

	 
			
			
