*! version 1.0.0 , 13aug2021
*! Author: Mustafa Coban, Institute for Employment Research (Germany)
*! Website: mustafacoban.de
*! Support: mustafa.coban@iab.de


*!***********************************************************!
*!     recursive bivariate probit regression     		 	*!
*!***********************************************************!


/* ESTIMATION */
	
program define rbiprobit, eclass
	version 15.1
	if replay(){
		if ("`e(cmd)'" != "rbiprobit") error 301
		Display `0'
	}
	else{
	
		gettoken key: 0, parse(" =,[")
		
		*!	postestimation commands
		if `"`key'"' == "margdec"{
			
			cap confirm variable `key'
			if !_rc{
				
				dis as err "Please rename the variable {bf:`key'} in the data."
				dis as err "This might lead to conflict with the postestimation command"  ///
							"{bf: rbiprobit margdec}"
				exit 119
			}

			gettoken pfx 0 : 0, parse(" =,[")
			rbiprobit_margdec `0'
		}
		else if `"`key'"' == "tmeffects"{
			
			cap confirm variable `key'
			if !_rc{
				
				dis as err 	"Please rename the variable {bf:`key'} in the data."
				dis as err 	"This might lead to conflict with the postestimation command"  ///
							"{bf: rbiprobit tmeffects}"
				exit 119
			}

			gettoken pfx 0 : 0, parse(" =,[")
			rbiprobit_tmeffects `0'
		}
		else{	
			*!	rbiprobit estimation
			Estimate `0'
			ereturn local cmdline "rbiprobit `0'"
		}
	}

end


program define Estimate, eclass sortpreserve

	*!	syntax based on biprobit and heckprobit

	gettoken dep1 0 : 0, parse(" =,[")
	_fv_check_depvar `dep1'				
	
	tsunab dep1: `dep1'		
	rmTS `dep1'
	confirm variable `r(rmTS)'
	local dep1n "`dep1'"
	
	*!	allow "=" after depvar
	gettoken equals rest : 0, parse(" =")
	if "`equals'" == "=" { 
		local 0 `"`rest'"' 
	}	

	
	*! parse indepvars	
	syntax [varlist(numeric default=none ts fv)] [if] [in] , /*
			*/	ENDOGenous(string) [	/*
			*/	Level(cilevel)			/*
			*/	noLOG					/*
			*/	* ]
	
	local fvops1 = "`s(fvops)'" == "true" | _caller() >= 11
	local tsops1 = "`s(tsops)'" == "true" | _caller() >= 11
			
	local indep1 `varlist'
	local option0 `options'
	
	
	
	*!	parse depvar_en, indepvars_en and enopts
	
	EndogEq dep2 indep2 option2 : `"`endogenous'"'
	
	marksample 	touse
	markout		`touse' `dep1' `dep2' `indep1' `indep2'	
	
	_get_diopts diopts option0, `option0'
	
	if _caller() < 15{
		local parm atanrho:_cons
	}
	else{
		local parm /:atanrho
	}

	local diparm "diparm(atanrho, tanh label(rho))"
		
	if "`log'" == ""{
		local log "noisily"
	}
	else{
		local log "quietly"
	}
	
	if "`level'" != ""{
		local level "level(`level')"
	}
	
	local indep1raw `indep1'
	local indep2raw `indep2'
	
	_rmcoll i.`dep2' `indep1'  if `touse'
	local indep1 "`r(varlist)'"
	
	_rmcoll `indep2' if `touse'
	local indep2 "`r(varlist)'"
	
	
	*!	Taken from "bicop" and modified a bit
	qui{
		tempvar y1 y2
		count	if `touse'
		egen `y1' = group(`dep1')
		egen `y2' = group(`dep2')
		
		count if `touse'
		local N = r(N)
		
		if `N' == 0{
			error 2000	// no obs.
		}
		
		tab `y1' if `touse'
		global Nthr1 = r(r) - 1	
		
		tab `y2' if `touse'
		global Nthr2 = r(r) - 1
		
		if $Nthr1 == 0{
			dis in red "There is no variation in `dep1'"
			exit 2000
		}
		if $Nthr2 == 0{
			dis in red "There is no variation in `dep2'"
			exit 2000
		}
		
		*!	0/1 values for depvar and depvar_en
		if $Nthr1 > 1{
			dis in red "There are more than two groups in `dep1'"
			exit 2000
		}
		if $Nthr2 > 1{
			dis in red "There are more than two groups in `dep2'"
			exit 2000
		}
	}
		
	qui: levelsof `dep1'
	if "`r(levels)'" != "0 1"{
		dis in green "{bf:`dep1'} does not vary; remember:"
        dis in green "0 = negative outcome, 1 = positive outcome"
		exit 2000
	}
	
	
	qui: levelsof `dep2'
	if "`r(levels)'" != "0 1"{
		dis in green "{bf:`dep2'} does not vary; remember:"
        dis in green "0 = negative outcome, 1 = positive outcome"
		exit 2000
	}
	
	
	`log' dis in green ""
	`log' dis in green "Univariate Probits for starting values"
	
	
	*!	eq.1: univariate probit (taken from biprobit)
	qui: probit `dep1' `indep1' 	if `touse' /*
				iter(`=min(1000,c(maxiter))') */
			
	if _rc == 0{
		tempname cb1
		mat `cb1' 	= e(b)
		local ll_1 = e(ll)
		mat coleq `cb1' = `dep1n'
	}
	

	*!	eq.2: univariate probit (taken from biprobit)
	qui: probit `dep2' `indep2' if `touse' /*
				iter(`=min(1000,c(maxiter))') */

	local ll_str = e(crittype)
										
	if _rc == 0{
		tempname cb2
		mat `cb2' 	= e(b)
		local ll_2 = e(ll)
		mat coleq `cb2' = `dep2n'
	}
	
	
	*!	stack coefficient estimates
	local ll_p = `ll_1' + `ll_2'
	
	tempname from
	
	if ("`indep1'" != "") & ("`indep2'" != ""){
		mat `from' = `cb1', `cb2'
		
		dis in green "Comparison:	`ll_str' = " in yellow %10.0g `ll_p'
	}
	else if ("`indep1'" != "") & ("`indep2'" == ""){
		mat `from' = `cb1'
	}
	else if ("`indep1'" == "") & ("`indep2'" != ""){
		mat `from' = `cb2'
	}
	else if ("`indep1'" == "") & ("`indep2'" == ""){
		// inplausible case
	}
	
		
	*!	initial value for atanrho (taken from biprobit)	
	tempname a0
	mat `a0' = (0)
	mat colnames `a0' = `parm'
	mat `from' = `from', `a0'
	
	local cont wald(2)
	
	
	
	*!	full model estimation
	local title "Recursive Bivariate Probit Regression"
	
	#d ;
	noisily ml model lf1 rbiprobit_lf1
			(`dep1n': `dep1' = `indep1')
			(`dep2n': `dep2' = `indep2')
			/atanrho
			if `touse', 
			maximize init(`from') search(off) `cont'
			missing	nopreserve collinear
			title(`title') `level' `diparm' `diopts'
			;
	#d cr
	
	*!	constraints matrix
	tempname junk
	capture matrix `junk' = e(Cns)
	if !_rc{
		local hascns hascns
	}
	
	*! wald test
	local r = _b[/atanrho]
	ereturn scalar rho = (exp(2*`r')-1) / (1+exp(2*`r'))
	
	if "`ll_p'" != "" & "`hascns'" == ""{
		ereturn scalar ll_c 	= `ll_p'
		ereturn scalar chi2_c	= abs(-2*(e(`ll_c') - e(ll)))	//	
		ereturn local chi2_ct "LR"
	}
	else{
		qui test _b[/atanrho] = 0
		ereturn scalar chi2_c = r(chi2)
		ereturn local chi2_ct "Wald"
	}
	
	
	*!	stored results
	ereturn scalar k_aux = 1
	ereturn scalar k_eq_model = 2	
	ereturn local marginsok		"default P11 P10 P01 P00 PMARG1 PMARG2 PCOND1 PCOND2 PCOND10 XB1 XB2 PMARGCOND1"
	ereturn local marginsnotok	"STDP1 STDP2"
	ereturn hidden local marginsderiv 	"default P11"	
	ereturn local predict	"rbiprobit_p"
	ereturn local cmd 		"rbiprobit"
	

	*! display results
	Display, `level' `diopts'
	exit `e(rc)'
end




/* DISPLAY */

program define Display

	syntax [, Level(cilevel) *]
	_get_diopts diopts, `options'
	
	version 15.1: ml display, level(`level') nofootnote `diopts'
	DispLr
	_prefix_footnote
end

*!	taken from biprobit
program define DispLr

	if "`e(ll_c)'`e(chi2_c)'" == "" {
		exit
	}
	
	local chi : di %8.0g e(chi2_c)
	local chi = trim("`chi'")
	
	if "`e(ll_c)'"=="" {
		di in green "Wald test of rho=0: " ///
			in green "chi2(" in ye "1" in gr ") = " ///
			in ye "`chi'" ///
			in green _col(59) "Prob > chi2 = " in ye %6.4f ///
			chiprob(1,e(chi2_c))
		exit
	}
	
	di in green "LR test of rho=0: " ///
		in green "chi2(" in ye "1" in gr ") = " in ye `chi' ///
		in green _col(59) "Prob > chi2 = " in ye %6.4f ///
	chiprob(1,e(chi2_c))
end



/* AUXILIARY SUB-PROGRAMS */	

*!	taken from biprobit
program define rmTS, rclass

	local tsnm = cond( match("`0'", "*.*"),  		/*
			*/ bsubstr("`0'", 			/*
			*/	  (index("`0'",".")+1),.),     	/*
			*/ "`0'")

	return local rmTS `tsnm'
end



*!	parse endog() option
program define EndogEq
	
	args dep2 indep2 option2 colon endog_eq

	gettoken dep rest: endog_eq, parse(" =")
	_fv_check_depvar `dep'
	
	tsunab dep: `dep'			
	rmTS `dep'
	confirm variable `r(rmTS)'
	
	c_local `dep2' `dep'
	c_local dep2n `dep'
	
	*!	allow "=" after depvar_en
	gettoken equals 0 : rest, parse(" =")
	if "`equals'" != "=" { 
		local 0 `"`rest'"'
	}	

	
	*!	parse indepvar_en (based on biprobit and heckprobit) 	
	syntax [varlist(numeric default=none ts fv)], [*]
	
	local fvops2 = "`s(fvops)'" == "true" | _caller() >= 11
	local tsops2 = "`s(tsops)'" == "true" | _caller() >= 11
	
	c_local `indep2' `varlist'
	c_local `option2' `options'	
end
