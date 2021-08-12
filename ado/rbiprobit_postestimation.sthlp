{smcl}
{* *! version 1.0.0: 13aug2021}{...}
{vieweralsosee "rbiprobit" "help rbiprobit"}{...}
{viewerjumpto "Postestimation commands" "rbiprobit postestimation##description"}{...}
{viewerjumpto "Syntax for predict" "rbiprobit postestimation##syntax_predict"}{...}
{viewerjumpto "Examples" "rbiprobit postestimation##examples"}{...}
{hline}
{hi:help rbiprobit postestimation}{right:{browse "https://github.com/cobanomics/rbiprobit":github.com/cobanomics/rbiprobit}}
{hline}
{right:also see:  {help rbiprobit: help rbiprobit}}

{marker description}{...}
{title:Postestimation commands}

{pstd}
The following postestimation commands are of special interest after {cmd:rbiprobit}:

{synoptset 19}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt :{helpb rbiprobit_margdec:rbiprobit margdec}}marginal means, predictive margins, 
	marginal effects, and average marginal effects of {it:indepvars} and {it:indepvars}_en
	{p_end}
{synopt :{helpb rbiprobit_tmeffects:rbiprobit tmeffects}}treatment effects of treatment
	variable {it:depvar}_en
	{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
The following postestimation commands are available after {cmd:rbiprobit}:

{synoptset 17 tabbed}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt :{helpb rbiprobit postestimation##predict:predict}}predictions, residuals, influence statistics, and other diagnostic measures{p_end}
INCLUDE help post_predictnl
{synoptline}
{p2colreset}{...}


{marker syntax_predict}{...}
{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} 
{dtype}
{newvar} 
{ifin}
[{cmd:,} {it:statistic} ]

{p 8 16 2}
{cmd:predict}
{dtype}
{c -(}{it:stub*}{c |}{it:{help newvar:newvar_eq1}} {it:{help newvar:newvar_eq2}}
                     {it:{help newvar:newvar_atanrho}}{c )-}
{ifin}
{cmd:,}
{opt sc:ores}

{synoptset 17 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt p11}}Pr({it:depvar}=1, {it:depvar}_en=1); the default{p_end}
{synopt :{opt p10}}Pr({it:depvar}=1, {it:depvar}_en=0){p_end}
{synopt :{opt p01}}Pr({it:depvar}=0, {it:depvar}_en=1){p_end}
{synopt :{opt p00}}Pr({it:depvar}=0, {it:depvar}_en=0){p_end}
{synopt :{opt pmarg1}}Pr({it:depvar}=1); marginal success probability for outcome equation{p_end}
{synopt :{opt pmarg2}}Pr({it:depvar}_en=1); marginal success probability for treatment equation{p_end}
{synopt :{opt pcond1}}Pr({it:depvar}=1 | {it:depvar}_en=1){p_end}
{synopt :{opt pcond2}}Pr({it:depvar}_en=1 | {it:depvar}=1){p_end}
{synopt :{opt xb1}}linear prediction for outcome equation {p_end}
{synopt :{opt xb2}}linear prediction for treatment equation {p_end}
{synopt :{opt stdp1}}standard error of the linear prediction for outcome equation{p_end}
{synopt :{opt stdp2}}standard error of the linear prediction for treatment equation{p_end}
{synoptline}
{p2colreset}{...}
INCLUDE help esample


{marker des_predict}{...}
{title:Description for predict}

{pstd}
{cmd:predict} creates a new variable containing predictions such as
probabilities, linear predictions, and standard errors.


{marker options_predict}{...}
{title:Options for predict}

{phang}
{opt p11}, the default, calculates the joint predicted probability
Pr({it:depvar}=1, {it:depvar}_en=1).

{phang}
{opt p10} calculates the joint predicted probability 
Pr({it:depvar}=1,{it:depvar}_en=0).

{phang}
{opt p01} calculates the joint predicted probability 
Pr({it:depvar}=0,{it:depvar}_en=1).

{phang}
{opt p00} calculates the joint predicted probability 
Pr({it:depvar}=0,{it:depvar}_en=0).

{phang}
{opt pmarg1} calculates the univariate (marginal) predicted probability
of success Pr({it:depvar}=1).

{phang}
{opt pmarg2} calculates the univariate (marginal) predicted probability
of success Pr({it:depvar}_en=1).

{phang}
{opt pcond1} calculates the conditional (on success in treatment equation)
predicted probability of success Pr({it:depvar}=1 | {it:depvar}_en=1).

{phang}
{opt pcond2} calculates the conditional (on success in outcome equation)
predicted probability of success Pr({it:depvar}_en=1 | {it:depvar}=1).

{phang}
{opt xb1} calculates the probit linear prediction for the outcome equation.

{phang}
{opt xb2} calculates the probit linear prediction for the treatment equation.

{phang}
{opt stdp1} calculates the standard error of the linear prediction of the outcome equation.

{phang}
{opt stdp2} calculates the standard error of the linear prediction of the treatment equation.

{phang}
{opt scores} calculates equation-level score variables.

{pmore}
The first new variable will contain the derivative of the log likelihood with
respect to the first regression equation.

{pmore}
The second new variable will contain the derivative of the log likelihood with
respect to the second regression equation.

{pmore}
The third new variable will contain the derivative of the log likelihood with
respect to the third equation ({hi:atanrho}).


{marker examples}{...}
{title:Examples}


{marker author}{...}
{title:Author}

{phang}Mustafa Coban{p_end}
{phang}Institute for Employment Research (Germany){p_end}

{p2col 5 20 29 2:email:}mustafa.coban@iab.de{p_end}
{p2col 5 20 29 2:github:}{browse "https://github.com/cobanomics":github.com/cobanomics}{p_end}
{p2col 5 20 29 2:webpage:}{browse "https://www.mustafacoban.de":mustafacoban.de}{p_end}


{marker also_see}{...}
{title:Also see}

{psee}
    Online: help for
    {helpb rbiprobit}
