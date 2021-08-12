*! version 1.0.0 , 13aug2021
*! Author: Mustafa Coban, Institute for Employment Research (Germany)
*! Website: mustafacoban.de
*! Support: mustafa.coban@iab.de


/****************************************************************/
/*    			 rbiprobit prediction							*/
/****************************************************************/

program define rbiprobit_p, eclass
	
	version 15.1
	syntax [anything] [if] [in] [, SCores *]
		
	if ("`e(cmd)'" != "rbiprobit"){
		error 301
		dis in red "rbiprobit was not the last command"
	}
	
	if `"`scores'"' != ""{
		ml score `0'	
		exit
	}
	
	local myopts P11 P10 P01 P00 PMARG1 PMARG2 XB1 XB2
	local myopts `myopts' PCOND1 PCOND2 PCOND10 PMARGCOND1 STDP1 STDP2
	local myopts `myopts' d1(string) d2(string)
	
	_pred_se "`myopts'" `0'
	
	if (`s(done)') exit
	local vtyp 	`s(typ)'
	local varn 	`s(varn)'
	local 0	`"`s(rest)'"'
	
	
	*!	parse predict	
	syntax [if] [in] [, `myopts']
	
	local type `p11'`p10'`p01'`p00'`pmarg1'`pmarg2'`xb1'`xb2'
	local type `type' `pcond1'`pcond2'`pcond10'`pmargcond1'`stdp1'`stdp2'
		
	tokenize `e(depvar)'
	local dep1 `1'
	local dep2 `2'
		
	tempname arho rho	
	if `:colnfreeparms e(b)' {
		scalar `arho' = _b[/atanrho]
	}
	else {
		scalar `arho' = [atanrho]_b[_cons]
	}	
	
	scalar `rho' = (exp(2*`arho')-1) / (1+exp(2*`arho'))
	
	*!	dr and d2dr	
	if `"`d1'`d2'"' != ""{
		tempname dr d2dr
		scalar `dr' 	= 4*exp(2*`arho') / ( (1+exp(2*`arho'))*(1+exp(2*`arho')) )
		scalar `d2dr'	= 8*exp(2*`arho') * (1-exp(2*`arho')) ///
							/ ( (1+exp(2*`arho'))*(1+exp(2*`arho'))*(1+exp(2*`arho')) )
	}
	

	*!	joint probabilities: p11,p10,p01,p00
	tempvar xb zg	
	if inlist("`type'","","p11"){
		if "`type'" == "" {
			di in gr "(option p11 assumed; Pr(`dep1'=1,`dep2'=1))"
		}	
		
		local pred "Pr(`dep1'=1,`dep2'=1)"
		
		qui{
			tempvar dep2orig
			
			clonevar `dep2orig' = `dep2'
			replace	`dep2' = 1
		
			_predict double `xb' `if' `in', eq(#1)
			_predict double `zg' `if' `in', eq(#2)
		}
				
		tempname q1 q2 rhost etast
		
		scalar `q1' = 1
		scalar `q2' = 1
		scalar `rhost' = `q1'*`q2'*`rho'
		scalar `etast' = 1/sqrt(1-`rhost'*`rhost')
		
		local w1 	`q1'*`xb'
		local w2 	`q2'*`zg'
		local v1 	(`w2' - `rhost'*`w1')*`etast'
		local v2 	(`w1' - `rhost'*`w2')*`etast'
		local s1 	normalden(`w1') * normal(`v1')
		local s2 	normalden(`w2') * normal(`v2')
		local Phi2	binormal(`w1',`w2',`rhost')
		local phi2	`etast'*normalden(`w1')*normalden(`v1')
		
		*!	d1 and d2 (first derivatives)
		if inlist(`"`d1'"',"#1","#2","#3") & `"`d2'"' == ""{
			if `"`d1'"' == "#1"{
				gen `vtyp' `varn' = `s1' * `q1' `if' `in'
				label var `varn' "d `pred' / d xb(`d1')"
			}
			if `"`d1'"' == "#2"{
				gen `vtyp' `varn' = `s2' * `q2' `if' `in'
				label var `varn' "d `pred' / d xb(`d1')"
			}
			if `"`d1'"' == "#3"{
				gen `vtyp' `varn' = `q1'*`q2'*`phi2'*`dr' `if' `in'
				label var `varn' "d `pred' / d xb(`d1')"
			}
		}
		
		*!	d1 and d2 (second derivatives)
		if inlist(`"`d1'"',"#1","#2","#3") & inlist(`"`d2'"',"#1","#2","#3"){
			if `"`d1'`d2'"' == "#1#1"{
				gen `vtyp' `varn' = -`w1'*`s1' - `phi2'*`rhost' 	`if' `in'
				label var `varn' "d `pred' / d xb(`d1') d xb(`d2')"
			}
			if inlist(`"`d1'`d2'"', "#1#2", "#2#1"){
				gen `vtyp' `varn' = `q1'*`q2'*`phi2' 	`if' `in'
				*gen `vtyp' `varn' = 0 `if' `in'
				label var `varn' "d `pred' / d xb(`d1') d xb(`d2')"
			}
			if inlist(`"`d1'`d2'"', "#1#3", "#3#1"){
				gen `vtyp' `varn' = -`v2'*`q2'*`etast'*`dr'*`phi2'	`if' `in'
				label var `varn' "d `pred' / d xb(`d1') d xb(`d2')"
			}
			if `"`d1'`d2'"' == "#2#2"{
				gen `vtyp' `varn' = -`w2'*`s2' - `phi2'*`rhost'	`if' `in'
				*gen `vtyp' `varn' = 0 `if' `in'
				label var `varn' "d `pred' / d xb(`d1') d xb(`d2')"
			}
			if inlist(`"`d1'`d2'"', "#2#3", "#3#2"){
				gen `vtyp' `varn' = -`v1'*`q1'*`etast'*`dr'*`phi2'	`if' `in'
				*gen `vtyp' `varn' = 0 `if' `in'
				label var `varn' "d `pred' / d xb(`d1') d xb(`d2')"
			}
			if `"`d1'`d2'"' == "#3#3"{
				// there are no predictors in this equation, so
				// -margins- will never need anything other than 0
				
				*gen `vtyp' `varn' = 0 	`if' `in'
				gen `vtyp' `varn' = `q1'*`q2'*`phi2' * ///
									(`q1'*`q2'*`dr'*(`etast'*`etast'*`rhost' + `etast'*`etast'*`v1'*`v2') ///
									+ `d2dr') 	`if' `in'
				label var `varn' "d `pred' / d xb(`d1') d xb(`d2')"
			}
		}
		
		*! prediction p11
		if `"`d1'`d2'"' == ""{
			gen `vtyp' `varn' = binormal(`w1',`w2',`rhost')	`if' `in'
			label var `varn' "`pred'"
			
		}
		qui: replace `dep2' = `dep2orig'
		exit
	}

	*! prediction p10
	if "`type'" == "p10"{
	
		local pred "Pr(`dep1'=1,`dep2'=0)"
		
		qui{
			tempvar dep2orig
			
			clonevar	`dep2orig' = `dep2'
			replace		`dep2' = 0
		
			_predict double `xb' `if' `in', eq(#1)
			_predict double `zg' `if' `in', eq(#2)
			
			replace `dep2' = `dep2orig'
		}
				
		tempname q1 q2 rhost etast
		
		scalar `q1' = 1
		scalar `q2' = -1
		scalar `rhost' = `q1'*`q2'*`rho'
		scalar `etast' = 1/sqrt(1-`rhost'*`rhost')
		
		local w1 	`q1'*`xb'
		local w2 	`q2'*`zg'
		local v1 	(`w2' - `rhost'*`w1')*`etast'
		local v2 	(`w1' - `rhost'*`w2')*`etast'
		local s1 	normalden(`w1') * normal(`v1')
		local s2 	normalden(`w2') * normal(`v2')
		local Phi2	binormal(`w1',`w2',`rhost')
		local phi2	`etast'*normalden(`w1')*normalden(`v1')		
		
		gen `vtyp' `varn' = binormal(`w1',`w2',`rhost')	`if' `in'
		label var `varn' "`pred'"		
		exit
	}	
	
	*! prediction p01	
	if "`type'" == "p01"{

		local pred "Pr(`dep1'=0,`dep2'=1)"
		
		qui{
			tempvar dep2orig
			
			clonevar 	`dep2orig' = `dep2'
			replace		`dep2' = 1
		
			_predict double `xb' `if' `in', eq(#1)
			_predict double `zg' `if' `in', eq(#2)
			
			replace `dep2' = `dep2orig'
		}
		
		tempname q1 q2 rhost etast
		
		scalar `q1' = -1
		scalar `q2' = 1
		scalar `rhost' = `q1'*`q2'*`rho'
		scalar `etast' = 1/sqrt(1-`rhost'*`rhost')
		
		local w1 	`q1'*`xb'
		local w2 	`q2'*`zg'
		local v1 	(`w2' - `rhost'*`w1')*`etast'
		local v2 	(`w1' - `rhost'*`w2')*`etast'
		local s1 	normalden(`w1') * normal(`v1')
		local s2 	normalden(`w2') * normal(`v2')
		local Phi2	binormal(`w1',`w2',`rhost')
		local phi2	`etast'*normalden(`w1')*normalden(`v1')		
		
		gen `vtyp' `varn' = binormal(`w1',`w2',`rhost')	`if' `in'
		label var `varn' "`pred'"		
		exit
	}	
	
	*! prediction p00
	if "`type'" == "p00"{
	
		local pred "Pr(`dep1'=0,`dep2'=0)"
		
		qui{
			tempvar dep2orig
			
			clonevar 	`dep2orig' = `dep2'
			replace		`dep2' = 0
		
			_predict double `xb' `if' `in', eq(#1)
			_predict double `zg' `if' `in', eq(#2)
			
			replace `dep2' = `dep2orig'
		}
		
		tempname q1 q2 rhost etast
		
		scalar `q1' = -1
		scalar `q2' = -1
		scalar `rhost' = `q1'*`q2'*`rho'
		scalar `etast' = 1/sqrt(1-`rhost'*`rhost')
		
		local w1 	`q1'*`xb'
		local w2 	`q2'*`zg'
		local v1 	(`w2' - `rhost'*`w1')*`etast'
		local v2 	(`w1' - `rhost'*`w2')*`etast'
		local s1 	normalden(`w1') * normal(`v1')
		local s2 	normalden(`w2') * normal(`v2')
		local Phi2	binormal(`w1',`w2',`rhost')
		local phi2	`etast'*normalden(`w1')*normalden(`v1')		
		
		gen `vtyp' `varn' = binormal(`w1',`w2',`rhost')	`if' `in'
		label var `varn' "`pred'"		
		exit
	}	
	
	
	*!	marginal probabilities: pmarg1, pmarg2
	*!	prediction pmarg1
	if "`type'" == "pmarg1"{
			
		local pred "Pr(`dep1'=1)"
		
		qui _predict double `xb' `if' `in', eq(#1)
		
		gen `vtyp' `varn' = normal(`xb')	`if' `in'
		label var `varn' "Pr(`dep1'=1)"	
		exit
	}	

	*!	prediction pmarg2
	if "`type'" == "pmarg2"{
			
			//	Prediction
		local pred "Pr(`dep2'=1)"
		
		qui _predict double `zg' `if' `in', eq(#2)
		
		gen `vtyp' `varn' = normal(`zg')	`if' `in'
		label var `varn' "Pr(`dep2'=1)"
		
		exit
	}	
	
	
	*!	conditional probabilities: pcond1, pcond2, pcond10 (undocumented)
	*!	prediction pcond1
	if "`type'" == "pcond1"{

		local pred "Pr(`dep1'=1|`dep2'=1)"
		
		qui{
			tempvar dep2orig
			
			clonevar 	`dep2orig' = `dep2'
			replace		`dep2' = 1
		
			_predict double `xb' `if' `in', eq(#1)
			_predict double `zg' `if' `in', eq(#2)
			
			replace `dep2' = `dep2orig'
		}
		
		tempname q1 q2 rhost etast
		
		scalar `q1' = 1
		scalar `q2' = 1
		scalar `rhost' = `q1'*`q2'*`rho'
		scalar `etast' = 1/sqrt(1-`rhost'*`rhost')
		
		local w1 	`q1'*`xb'
		local w2 	`q2'*`zg'
		local v1 	(`w2' - `rhost'*`w1')*`etast'
		local v2 	(`w1' - `rhost'*`w2')*`etast'
		local s1 	normalden(`w1') * normal(`v1')
		local s2 	normalden(`w2') * normal(`v2')
		local Phi2	binormal(`w1',`w2',`rhost')
		local phi2	`etast'*normalden(`w1')*normalden(`v1')		
		
		gen `vtyp' `varn' = binormal(`w1',`w2',`rhost') / normal(`w2')	`if' `in'
		label var `varn' "`pred'"		
		exit
	}	

	*!	prediction pcond2
	if "`type'" == "pcond2"{
				
		local pred "Pr(`dep2'=1|`dep1'=1)"
		
		qui{
			tempvar dep2orig
			
			clonevar 	`dep2orig' = `dep2'
			replace		`dep2' = 1
		
			_predict double `xb' `if' `in', eq(#1)
			_predict double `zg' `if' `in', eq(#2)
			
			replace `dep2' = `dep2orig'
		}
		
		tempname q1 q2 rhost etast
		
		scalar `q1' = 1
		scalar `q2' = 1
		scalar `rhost' = `q1'*`q2'*`rho'
		scalar `etast' = 1/sqrt(1-`rhost'*`rhost')
		
		local w1 	`q1'*`xb'
		local w2 	`q2'*`zg'
		local v1 	(`w2' - `rhost'*`w1')*`etast'
		local v2 	(`w1' - `rhost'*`w2')*`etast'
		local s1 	normalden(`w1') * normal(`v1')
		local s2 	normalden(`w2') * normal(`v2')
		local Phi2	binormal(`w1',`w2',`rhost')
		local phi2	`etast'*normalden(`w1')*normalden(`v1')		
		
		gen `vtyp' `varn' = binormal(`w1',`w2',`rhost') / normal(`w1')	`if' `in'
		label var `varn' "`pred'"	
		exit
	}	
	
	*!	prediction pcond10 (undocumented)
	if "`type'" == "pcond10"{
	
		local pred "Pr(`dep1'=1|`dep2'=0)"
		
		qui{
			tempvar dep2orig
			
			clonevar 	`dep2orig' = `dep2'
			replace		`dep2' = 0
		
			_predict double `xb' `if' `in', eq(#1)
			_predict double `zg' `if' `in', eq(#2)
			
			replace `dep2' = `dep2orig'
		}
		
		tempname q1 q2 rhost etast
		
		scalar `q1' = 1
		scalar `q2' = -1
		scalar `rhost' = `q1'*`q2'*`rho'
		scalar `etast' = 1/sqrt(1-`rhost'*`rhost')
		
		local w1 	`q1'*`xb'
		local w2 	`q2'*`zg'
		local v1 	(`w2' - `rhost'*`w1')*`etast'
		local v2 	(`w1' - `rhost'*`w2')*`etast'
		local s1 	normalden(`w1') * normal(`v1')
		local s2 	normalden(`w2') * normal(`v2')
		local Phi2	binormal(`w1',`w2',`rhost')
		local phi2	`etast'*normalden(`w1')*normalden(`v1')		
		
		gen `vtyp' `varn' = binormal(`w1',`w2',`rhost') / normal(`w2')	`if' `in'
		label var `varn' "`pred'"
		exit
	}	
	
	*!	linear prediction and se: xb1, xb2, stdp1, stdp2
	*!	prediction xb1
	if "`type'" == "xb1"{
			
			//	Prediction
		local pred "Linear Prediction of `dep1'"
		
		_predict `vtyp' `varn' `if' `in', eq(#1)
		label var `varn' "`pred'"	
		exit
	}	
	
	*!	prediction xb2
	if "`type'" == "xb2"{
			
			//	Prediction
		local pred "Linear Prediction of `dep2'"
		
		_predict `vtyp' `varn' `if' `in', eq(#2)
		label var `varn' "`pred'"
		exit
	}	
	
	*!	prediction xb1
	if "`type'" == "stdp1"{
			
			//	Prediction
		local pred "S.E. of Linear Prediction of `dep1'"
		
		_predict `vtyp' `varn' `if' `in', stdp eq(#1)
		label var `varn' "`pred'"
		exit
	}	

	*!	prediction xb1
	if "`type'" == "stdp2"{
			
			//	Prediction
		local pred "S.E. of Linear Prediction of `dep2'"
		
		_predict `vtyp' `varn' `if' `in', stdp eq(#2)
		label var `varn' "`pred'"
		exit
	}	
	
	
	*!	conditional marginal probability: pmargcond1 (undocumented)
	if "`type'" == "pmargcond1"{
		
		local pred "Pr(`dep1'=1|`dep2'=1): Conditional Marginal Probability"
		
		qui{
			_predict double `xb' `if' `in', eq(#1)
			_predict double `zg' `if' `in', eq(#2)
		}
		
		tempname q1 q2 rhost etast
		
		scalar `q1' = 1
		scalar `q2' = 1
		scalar `rhost' = `q1'*`q2'*`rho'
		scalar `etast' = (1/sqrt(1-`rhost'*`rhost'))
		
		local w1 	`q1'*`xb'
		local w2 	`q2'*`zg'
		local v1 	(`w2' - `rhost'*`w1')*`etast'
		local v2 	(`w1' - `rhost'*`w2')*`etast'
		local s1 	normalden(`w1') * normal(`v1')
		local s2 	normalden(`w2') * normal(`v2')
		local Phi2	binormal(`w1',`w2',`rhost')
		local phi2	`etast'*normalden(`w1')*normalden(`v1')		
		
		gen `vtyp' `varn' = normal(`v2')	`if' `in'
		label var `varn' "`pred'"		
		exit
	}	
	error 198
end
