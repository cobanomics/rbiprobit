{smcl}
{* *! version 1.0.0: 13aug2021}{...}
{vieweralsosee "[R] margins" "mansection R margins"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] marginsplot" "help marginsplot"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] predict" "help predict"}{...}
{viewerjumpto "Syntax" "rbiprobit tmeffects##syntax"}{...}
{viewerjumpto "Description" "rbiprobit tmeffects##description"}{...}
{viewerjumpto "Options" "rbiprobit tmeffects##options"}{...}
{viewerjumpto "Stores Results" "rbiprobit tmeffects##results"}{...}
{viewerjumpto "Examples" "rbiprobit tmeffects##examples"}{...}
{hline}
{hi:help rbiprobit tmeffects}{right:{browse "https://github.com/cobanomics/rbiprobit":github.com/cobanomics/rbiprobit}}
{hline}
{right:also see:  {help rbiprobit postestimation}}

{title:Title}

{p2colset 5 28 28 2}{...}
{p2col: {cmd:rbiprobit tmeffects} {hline 2}}Estimation of treatment effects of treatment variable {it:depvar_en} after {cmd:rbiprobit}
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:rbiprobit tmeffects}
{ifin}
[{cmd:,}
{it:{help rbiprobit tmeffects##options_table:options}}] 


{marker options_table}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt:{opt tmeff:ect(effecttype)}}specify type of treatment effect;
	{it:effecttype} may be {cmd:ate}, {cmd:atet}, or {cmd:atec}; default is {cmd:ate}
	{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt post}}post margins and their VCE as estimation results{p_end}
{synopt :{it:{help rbiprobit tmeffects##display_options:display_options}}}control
       columns and column formats, row spacing, line width, and
       factor-variable labeling
       {p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd: rbiprobit tmeffects} estimates the average treatment effect, average treatent
effect on the treated, and the average treatment effect on the conditional predicted
probability 



{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
	{opt tmeffect(effecttype)} specifies the type of the treatment effect of the
	treatment variable {it:depvar}_en on a specific response.

{phang2}
	{opt tmeffect(ate)}: {cmd:rbiprobit tmeffects} reports the average treatment effect,
	i.e. the finite difference between the univariate (marginal) probability of success 
	Pr({it:depvar}=1) and univariate (marginal) probability of failure 
	Pr({it:depvar}=1).
	
{phang2}
	{opt tmeffect(atet)}: {cmd:rbiprobit tmeffects} reports the average treatment effect
	on the treated, i.e. the finite difference between the univariate (marginal) 
	probability of success conditioned on sucess in treatment equation 
	normal({it:depvar=1}|{it:depvar}_en=1) and the univariate (marginal) 
	probability of sucess conditioned on failure in treatment equation 
	normal({it:depvar=1}|{it:depvar}_en=0).

{phang2}
	{opt tmeffect(atec)}: {cmd:rbiprobit tmeffects} reports the average treatment effect
	on the conditional probability, i.e. the finite difference between the conditional
	(on success in treatment equation) predicted probability of success 
	Pr({it:depvar}=1|{it:depvar}_en=1) and the conditional
	(on failure in treatment equation) predicted probability of success Pr({it:depvar}=1|{it:depvar}_en=0).

{pmore}
    Multiple {opt tmeffect()} options are not allowed with {cmd:rbiprobit tmeffects}.


{dlgtab:Reporting}

{phang}
	{opt level(#)}
	specifies the confidence level, as a percentage, for confidence intervals.
	The default is {cmd:level(95)} or as set by {helpb set level}.

{phang} 
	{opt post} 
	causes {cmd:rbiprobit tmeffects} to behave like a Stata estimation (e-class) command.
	{cmd:rbiprobit tmeffects} posts the vector of estimated margins along with the
	estimated variance-covariance matrix to {cmd:e()}, so you can treat the
	estimated margins just as you would results from any other estimation
	command.  For example, you could use {cmd:test} to perform simultaneous tests
	of hypotheses on the margins, or you could use {cmd:lincom} to create linear
	combinations.  See
	{it:{mansection R marginsRemarksandexamplesExample10Testingmargins---contrastsofmargins:Example 10: Testing margins -- contrasts of margins}} in {manlink R margins}.

{marker display_options}{...}
{phang}
{it:display_options}:
{opt noci},
{opt nopv:alues},
{opt vsquish},
{opt nofvlab:el},
{opt fvwrap(#)},
{opt fvwrapon(style)},
{opth cformat(%fmt)},
{opt pformat(%fmt)},
{opt sformat(%fmt)}, and
{opt nolstretch}.

{phang2}
{opt noci} 
suppresses confidence intervals from being reported in the coefficient table.

{phang2}
{opt nopvalues}
suppresses p-values and their test statistics from being reported in the
coefficient table.

{phang2}
{opt vsquish} 
specifies that the blank space separating factor-variable terms or
time-series-operated variables from other variables in the model be suppressed.

{phang2}
{opt nofvlabel} displays factor-variable level values rather than attached value
labels.  This option overrides the {cmd:fvlabel} setting; see 
{helpb set showbaselevels:[R] set showbaselevels}.

{phang2}
{opt fvwrap(#)} allows long value labels to wrap the first {it:#}
lines in the coefficient table.  This option overrides the
{cmd:fvwrap} setting; see {helpb set showbaselevels:[R] set showbaselevels}.

{phang2}
{opt fvwrapon(style)} specifies whether value labels that wrap will break
at word boundaries or break based on available space.

{phang3}
{cmd:fvwrapon(word)}, the default, specifies that value labels break at
word boundaries.

{phang3}
{cmd:fvwrapon(width)} specifies that value labels break based on available
space.

{pmore2}
This option overrides the {cmd:fvwrapon} setting; see
{helpb set showbaselevels:[R] set showbaselevels}.

{phang2}
{opt cformat(%fmt)} specifies how to format margins, standard errors, and
confidence limits in the table of estimated margins.

{phang2}
{opt pformat(%fmt)} specifies how to format p-values in the table of estimated margins.

{phang2}
{opt sformat(%fmt)} specifies how to format test statistics in the 
table of estimated margins.

{phang2}
{opt nolstretch} specifies that the width of the table of estimated margins
not be automatically widened to accommodate longer variable names. The default,
{cmd:lstretch}, is to automatically widen the table of estimated margins up to
the width of the Results window.  To change the default, use
{helpb lstretch:set lstretch off}.  {opt nolstretch} is not shown in the dialog
box.
{marker examples}{...}
{title:Examples}

{pstd}
These examples are intended for quick reference.  For a conceptual overview of Stata's
{cmd:margins} command and examples with discussion see
{it:{mansection R marginsRemarksandexamples:Remarks and examples}} in
{manlink R margins}.


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rbiprobit tmeffects} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(k_predict)}}number of {opt predict()} options{p_end}
{synopt:{cmd:r(k_margins)}}number of terms in {it:marginlist}{p_end}
{synopt:{cmd:r(k_by)}}number of subpopulations{p_end}
{synopt:{cmd:r(k_at)}}number of {opt at()} options{p_end}
{synopt:{cmd:r(level)}}confidence level of confidence intervals{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:margins}{p_end}
{synopt:{cmd:r(cmdline)}}command as typed{p_end}
{synopt:{cmd:r(est_cmd)}}{cmd:e(cmd)} from original estimation results{p_end}
{synopt:{cmd:r(est_cmdline)}}{cmd:e(cmdline)} from original estimation results{p_end}
{synopt:{cmd:r(title)}}Treatment Effects{p_end}
{synopt:{cmd:r(model_vce)}}{it:vcetype} from estimation command{p_end}
{synopt:{cmd:r(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:r(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:r(predict}{it:#}{cmd:_opts)}}the {it:#}th {cmd:predict()} option{p_end}
{synopt:{cmd:r(predict}{it:#}{cmd:_label)}}label from the {it:#}th {cmd:predict()} option{p_end}
{synopt:{cmd:r(expression)}}response expression{p_end}
{synopt:{cmd:r(xvars)}}{it:effectype} from {cmd:tmeffect()}{p_end}
{synopt:{cmd:r(derivatives)}}"dy/dx"{p_end}
{synopt:{cmd:r(emptycells)}}{it:empspec} from {cmd:emptycells()}{p_end}
{synopt:{cmd:r(mcmethod)}}{it:method} from {opt mcompare()}{p_end}

{p2col 5 20 24 2:Matrices}{p_end}
{synopt:{cmd:r(b)}}estimates{p_end}
{synopt:{cmd:r(V)}}variance-covariance matrix of the estimates{p_end}
{synopt:{cmd:r(Jacobian)}}Jacobian matrix{p_end}
{synopt:{cmd:r(_N)}}sample size corresponding to each margin estimate{p_end}
{synopt:{cmd:r(chainrule)}}chain rule information from the fitted model{p_end}
{synopt:{cmd:r(error)}}margin estimability codes;{break}
        {cmd:0} means estimable,{break}
        {cmd:8} means not estimable{p_end}
{synopt:{cmd:r(table)}}matrix
        containing the margins with their standard errors, test statistics,
        p-values, and confidence intervals{p_end}
{p2colreset}{...}


{pstd}
{cmd:rbiprobit tmeffects} with the {cmd:post} option also stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k_predict)}}number of {opt predict()} options{p_end}
{synopt:{cmd:e(k_margins)}}number of terms in {it:marginlist}{p_end}
{synopt:{cmd:e(k_by)}}number of subpopulations{p_end}
{synopt:{cmd:e(k_at)}}number of {opt at()} options{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:margins}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(est_cmd)}}{cmd:e(cmd)} from original estimation results{p_end}
{synopt:{cmd:e(est_cmdline)}}{cmd:e(cmdline)} from original estimation results{p_end}
{synopt:{cmd:e(title)}}Treatment Effects{p_end}
{synopt:{cmd:e(model_vce)}}{it:vcetype} from estimation command{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}, or just {cmd:b} if {cmd:nose} is specified{p_end}
{synopt:{cmd:e(predict}{it:#}{cmd:_opts)}}the {it:#}th {cmd:predict()} option{p_end}
{synopt:{cmd:e(predict}{it:#}{cmd:_label)}}label from the {it:#}th {cmd:predict()} option{p_end}
{synopt:{cmd:e(expression)}}prediction expression{p_end}
{synopt:{cmd:e(xvars)}}{it:effectype} from {cmd:tmeffect()}{p_end}
{synopt:{cmd:e(derivatives)}}"dy/dx"{p_end}
{synopt:{cmd:e(emptycells)}}{it:empspec} from {cmd:emptycells()}{p_end}

{p2col 5 20 24 2:Matrices}{p_end}
{synopt:{cmd:e(b)}}estimates{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimates{p_end}
{synopt:{cmd:e(Jacobian)}}Jacobian matrix{p_end}
{synopt:{cmd:e(_N)}}sample size corresponding to each margin estimate{p_end}
{synopt:{cmd:e(error)}}error code corresponding to {cmd:e(b)}{p_end}
{synopt:{cmd:e(chainrule)}}chain rule information from the fitted model{p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

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
    {helpb rbiprobit}, {helpb rbiprobit postestimation}, {helpb margins}
