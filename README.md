# rbiprobit
## Stata module to estimate recursive bivariate probit regressions

### __Table of Contents__
1. [Syntax](#1-syntax)
2. [Description](#2-description)
3. [Options](#3-options)
4. [Econometric Model](#4-econometric-model)
   1. [Recursive Bivariate Model](#41-recursive-bivariate-model)
   2. [Treatment Effects](#42-treatment-effects)
   3. [Decomposition of Marginal Effects](#43-decomposition-of-marginal-effects)
5. [Postestimation Commands](#5-postestimation-commands)
   1. [Treatment Effects Estimation](#51-treatment-effects-estimation)
   2. [Margins Estimation](#52-margins-estimation)
6. [Examples](#6-examples)
7. [References](#7-references)
8. [About](#8-about)
9. [How to install](#9-how-to-install)
10. [Changelog](#10-changelog)

## 1. Syntax

```git
rbiprobit depvar [=] [indepvars] [if] [in] , endogenous(depvar_en [=] [indepvars_en] [, enopts]) [options]
```

where _depvar_ is the outcome variable, _indepvars_ are the independent variables of the outcome equation, _depvar_en_ is the treatment variable, and _indepvars_en_ are the independent variable of the treatment equation. The endogenous treatment variable _depvar_en_ is automatically added as an explanatory variable on the right-hand side of the outcome equation by the command.

Independent variables may contain factor variables. All variables may contain time-series operators. `rbiprobit` provides to tailored postestimation commands and some common Stata postestimation commands.

## 2. Description

`rbiprobit` is a user-written command that fits a recursive bivariate probit regression using maximum likelihood estimation. It is implemented as an `lf1` ml evaluator. The model involves an outcome equation with the dependent variable _depvar_ and a treatment equation with the dependent variable _depvar_en_. Both dependent variables _depvar_ and _depvar_en_ have to be binary and coded as 0/1 variables.

`rbiprobit` automatically adds the treatment variable depvar_en as an independent variable on the right-hand side of the outcome equation. The independent variables in _indepvars_ and _indepvars_en_ may be different or identical. rbiprobit is limited to a recursive model with two equations.

_The current version of the command is stable and additional features are still work-in-progress. Future versions will include all suitable options of_ `biprobit`.


## 3. Options

_options_ | Description
----------| -------------
`level(#)`  |  set confidence level; default is `level(95)`
`nocnsreport`  |  do not display constraints
`display_options`  |  control columns and column formats, row spacing, line width, display of omitted variables and base and empty cells, and factor-variable labeling
`coeflegend`  |  display legend instead of statistics


## 4. Econometric Model

### 4.1. Recursive Bivariate Model
### 4.2. Treatment Effects
### 4.3. Decomposition of Marginal Effects

## 5. Postestimation Commands

---

The following postestimation commands are of __special interest__ after `rbiprobit`:

Command  | Description
-------------| -------------
`rbiprobit margdec`  |  marginal means, predictive margins, marginal effects, and average marginal effects of _indepvars_ and _indepvars_en_
`rbiprobit tmeffects`  | treatment effects of treatment variable _depvar_en_

<p style="color:red"><b>CAUTION: Limitations of margins after rbiprobit</b></p>

Do not use `margins` after you have fit your model by using `rbiprobit` if your are interested in marginal means, predictive margins, marginal effects or average marginal effects. `margins` doesn't account for the recursive nature of the model and will deliver __incorrect point estimates__ and / or __incorrect standard errors__ of the point estimates.

Instead, use the postestimation commands `rbiprobit margdec` and `rbiprobit tmeffects` written explicitly for `rbiprobit`. They cover some but not all options of `margins` and will deliver correct point estimates and standard errors.

---

The following postestimation commands are also available after `rbiprobit`:

Command  | Description
-------------| -------------
`predict`  |  predictions, residuals, influence statistics, and other diagnostic measures
`predictnl`  | point estimates, standard errors, testing, and inference for generalized predictions

__Syntax for predict__

```git
predict [type] newvar [if] [in] [, statistic ]

predict [type] {stub*|newvar_eq1 newvar_eq2 newvar_atanrho} [if] [in] , scores
```
predict creates a new variable containing predictions such as probabilities, linear predictions, and standard errors. The following statistics are available both in and out of sample; type `predict ... if e(sample) ...` if wanted only for the estimation sample.

    statistic          Description
    --------------------------------------------------------------------------------------------------
    Main
      p11              Pr(depvar=1, depvar_en=1); the default
      p10              Pr(depvar=1, depvar_en=0)
      p01              Pr(depvar=0, depvar_en=1)
      p00              Pr(depvar=0, depvar_en=0)
      pmarg1           Pr(depvar=1); marginal success probability for outcome equation
      pmarg2           Pr(depvar_en=1); marginal success probability for treatment equation
      pcond1           Pr(depvar=1 | depvar_en=1)
      pcond2           Pr(depvar_en=1 | depvar=1)
      xb1              linear prediction for outcome equation
      xb2              linear prediction for treatment equation
      stdp1            standard error of the linear prediction for outcome equation
      stdp2            standard error of the linear prediction for treatment equation
    --------------------------------------------------------------------------------------------------

### 5.1 Treatment Effects Estimation

```git
rbiprobit tmeffects [if] [in] [, options]
```

`rbiprobit tmeffects` estimates the average treatment effect, average treatent effect on the treated, and the average treatment effect on the conditional predicted probability

__Options__

    options                 Description
    --------------------------------------------------------------------------------------------------
    Main
      tmeffect(effecttype)    specify type of treatment effect; effecttype may be ate, atet, or atec;
                              default is ate
    Reporting
      level(#)                set confidence level; default is level(95)
      post                    post margins and their VCE as estimation results
      display_options         control columns and column formats, row spacing, line width, and
                              factor-variable labeling
    --------------------------------------------------------------------------------------------------

__Description of `tmeffect()`__

`tmeffect(effecttype)` specifies the type of the treatment effect of the treatment variable _depvar_en_ on a specific response.

Effecttype | Description
-----------| -----------
`ate`  |  rbiprobit tmeffects reports the average treatment effect, i.e. the finite difference between the univariate (marginal) probability of success Pr(depvar=1) and univariate (marginal) probability of failure Pr(depvar=1).
`atet`  |  rbiprobit tmeffects reports the average treatment effect on the treated, i.e. the finite difference between the univariate (marginal) probability of success conditioned on sucess in treatment equation normal(depvar=1\|depvar_en=1) and the univariate (marginal) probability of sucess conditioned on failure in treatment equation normal(depvar=1\|depvar_en=0).
`atec`  | rbiprobit tmeffects reports the average treatment effect on the conditional probability, i.e. the finite difference between the conditional (on success in treatment equation) predicted probability of success Pr(depvar=1\|depvar_en=1) and the conditional (on failure in treatment equation) predicted probability of success Pr(depvar=1\|depvar_en=0).


### 5.2 Margins Estimation

```git
rbiprobit margdec [if] [in] [, response_options options]
```

Margins are statistics calculated from predictions of a previously fit model by `rbiprobit` at fixed values of some covariates and averaging or otherwise integrating over the remaining covariates. The `rbiprobit margdec` command estimates margins of responses for specified values of independent variables in indepvars and indepvars_en and presents the results as a table.

Capabilities include estimated marginal means, least-squares means, average and conditional marginal and partial effects (which may be reported as derivatives or as elasticities), average and conditional adjusted predictions, and predictive margins. For estimation of margins of responses for specified values of the treatment variable _depvar_en_, please use `rbiprobit tmeffects`. `rbiprobit margdec` won't deliver results in this case.

__Options__

    response_options        Description
    --------------------------------------------------------------------------------------------------
    Main
      effect(effecttype)    specify type of effect for margins; effecttype may be total, direct, or
                              indirect; default is total
      predict(pred_opt)     estimate margins for predict, pred_opt
      dydx(varlist)         estimate marginal effect of variables in varlist
      eyex(varlist)         estimate elasticities of variables in varlist
      dyex(varlist)         estimate semielasticity -- d(y)/d(lnx)
      eydx(varlist)         estimate semielasticity -- d(lny)/d(x)
    --------------------------------------------------------------------------------------------------


    options                 Description
    --------------------------------------------------------------------------------------------------
    Reporting
      level(#)              set confidence level; default is level(95)
      post                  post margins and their VCE as estimation results
      display_options       control columns and column formats, row spacing, line width, and
                              factor-variable labeling
    --------------------------------------------------------------------------------------------------

Time-series operators are allowed if they were used in the estimation.

__Description of `effect()`__

`effect(effecttype)` specifies the _effecttype_ for the margins. Once independent variables are parts of _indepvars_ and _indepvars_en_, marginal effects can be splitted into a __direct__ and an __indirect__ marginal effect.

Effecttype | Description
-----------| -----------
`effect(total)`  |  rbiprobit margdec reports derivatives of the response with respect to varlist in `dydx(varlist)`, `eyex(varlist)`, `dyex(varlist)`, or `eydx(varlist)`, considering the incorporation of varlist in _indepvars_ and/or _indepvars_en_.
`effect(direct)`  |  rbiprobit margdec reports derivatives of the response with respect to varlist from `dydx(varlist)`, `eyex(varlist)`, `dyex(varlist)`, or `eydx(varlist)`, considering only the incorporation of varlist in _indepvars_ and not taking into account the appearance of varlist in _indepvars_en_.
`effect(indirect)`  | rbiprobit margdec reports derivatives of the response with respect to varlist from `dydx(varlist)`, `eyex(varlist)`, `dyex(varlist)`, or `eydx(varlist)`, considering only the incorporation of varlist in _indepvars_en_ and not taking into account the appearance of varlist in _indepvars_.



## 6. Examples

__Examples for `rbiprobit`__

_Estimation of a recursive bivariate probit model_

    . webuse class10, clear
    (Class of 2010 profile)

    . rbiprobit graduate = income i.roommate i.hsgpagrp, ///
    >         endog(program = i.campus i.scholar income i.hsgpagrp)

    Univariate Probits for starting values
    Comparison:       log likelihood = -2673.8688

    Iteration 0:   log likelihood = -2804.2962
    Iteration 1:   log likelihood = -2702.2693
    Iteration 2:   log likelihood = -2670.8816
    Iteration 3:   log likelihood = -2668.0927
    Iteration 4:   log likelihood = -2667.6281
    Iteration 5:   log likelihood = -2667.5469
    Iteration 6:   log likelihood = -2667.5305
    Iteration 7:   log likelihood = -2667.5275
    Iteration 8:   log likelihood = -2667.5269
    Iteration 9:   log likelihood = -2667.5269
    Iteration 10:  log likelihood = -2667.5268

    Recursive Bivariate Probit Regression           Number of obs     =      2,500
                                                    Wald chi2(12)     =     964.07
    Log likelihood = -2667.5268                     Prob > chi2       =     0.0000

    ------------------------------------------------------------------------------
                 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
    graduate     |
       1.program |   .3522094   .1770159     1.99   0.047     .0052646    .6991542
          income |   .1434782   .0142911    10.04   0.000     .1154681    .1714882
                 |
        roommate |
            yes  |    .267713   .0588568     4.55   0.000     .1523559    .3830701
                 |
        hsgpagrp |
        2.5-2.9  |   .9451679   .1357869     6.96   0.000     .6790305    1.211305
        3.0-3.4  |   1.939513    .147325    13.16   0.000     1.650761    2.228264
        3.5-4.0  |   6.535829   127.5038     0.05   0.959     -243.367    256.4387
                 |
           _cons |  -2.076232   .2181295    -9.52   0.000    -2.503758   -1.648706
    -------------+----------------------------------------------------------------
    program      |
          campus |
            yes  |   .7465297   .0747092     9.99   0.000     .6001024    .8929569
                 |
         scholar |
            yes  |   .9007975   .0579886    15.53   0.000      .787142    1.014453
          income |  -.0785837   .0096477    -8.15   0.000    -.0974928   -.0596746
                 |
        hsgpagrp |
        2.5-2.9  |   .0586754   .1099653     0.53   0.594    -.1568526    .2742035
        3.0-3.4  |   .0651845   .1152074     0.57   0.572    -.1606179    .2909869
        3.5-4.0  |  -.0970995   .1780755    -0.55   0.586    -.4461211    .2519222
                 |
           _cons |  -.4441949   .1276995    -3.48   0.001    -.6944812   -.1939085
    -------------+----------------------------------------------------------------
        /atanrho |   .4138925    .118934     3.48   0.001     .1807862    .6469988
    -------------+----------------------------------------------------------------
             rho |   .3917727   .1006793                       .178842    .5696461
    ------------------------------------------------------------------------------
    Wald test of rho=0: chi2(1) = 12.1105                     Prob > chi2 = 0.0005

_Prediction after_ `rbiprobit`

    . webuse class10, clear
    (Class of 2010 profile)

    . qui: rbiprobit graduate = income i.roommate i.hsgpagrp, ///
    >         endog(program = i.campus i.scholar income i.hsgpagrp)

    . predict p11, p11
    . predict p1, pmarg1
    . predict pcond1, pcond1

    . sum p11 p1 pcond1

        Variable |        Obs        Mean    Std. Dev.       Min        Max
    -------------+---------------------------------------------------------
             p11 |      2,500    .3759793    .1683146   .0348119   .8205418
              p1 |      2,500    .6134214    .2680251   .0284513          1
          pcond1 |      2,500    .7313554    .2417841   .0859672          1



__Examples for `rbiprobit margdec`__

_Total, direct, and indirect average marginal effects of_ `income` _on joint probability_ `p11`

    . webuse class10, clear
    (Class of 2010 profile)
    . qui: rbiprobit graduate = income i.roommate i.hsgpagrp, ///
    >         endog(program = i.campus i.scholar income i.hsgpagrp)

    . rbiprobit margdec, dydx(income) effect(total) predict(p11)

    Average marginal effects                        Number of obs     =      2,500
    Model VCE    : OIM

    Expression   : Pr(graduate=1,program=1), predict(p11)
    dy/dx w.r.t. : income

    ------------------------------------------------------------------------------
                 |            Delta-method
                 |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
          income |   .0032146    .002856     1.13   0.260    -.0023831    .0088123
    ------------------------------------------------------------------------------

    . rbiprobit margdec, dydx(income) effect(direct) predict(p11)

    Average marginal effects                        Number of obs     =      2,500
    Model VCE    : OIM

    Expression   : Pr(graduate=1,program=1), predict(p11)
    dy/dx w.r.t. : income

    ------------------------------------------------------------------------------
                 |            Delta-method
                 |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
          income |   .0207027   .0017927    11.55   0.000     .0171891    .0242163
    ------------------------------------------------------------------------------

    . rbiprobit margdec, dydx(income) effect(indirect) predict(p11)

    Average marginal effects                        Number of obs     =      2,500
    Model VCE    : OIM

    Expression   : Pr(graduate=1,program=1), predict(p11)
    dy/dx w.r.t. : income

    ------------------------------------------------------------------------------
                 |            Delta-method
                 |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
          income |  -.0174881     .00214    -8.17   0.000    -.0216825   -.0132937
    ------------------------------------------------------------------------------



__Examples for `rbiprobit tmeffects`__

_ATE, ATET, and ATEC of treatment variable_ `propgram`

    . webuse class10, clear
    (Class of 2010 profile)
    . qui: rbiprobit graduate = income i.roommate i.hsgpagrp, ///
    >         endog(program = i.campus i.scholar income i.hsgpagrp)

    . rbiprobit tmeffects, tmeffect(ate)

    Treatment effect                                Number of obs     =      2,500
    Model VCE    : OIM

    Expression   : Pr(graduate=1), predict(pmarg1)
    Effect       : Average treatment effect
    dydx w.r.t.  : 1.program

    ------------------------------------------------------------------------------
                 |            Delta-method
                 |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
             ate |   .0981233   .0476266     2.06   0.039     .0047769    .1914697
    ------------------------------------------------------------------------------

    . rbiprobit tmeffects, tmeffect(atet)

    Treatment effect                                Number of obs     =      1,352
    Model VCE    : OIM

    Expression   : normal(graduate=1|program=1) - normal(graduate=1|program=0)
    Effect       : Average treatment effect on the treated
    dydx w.r.t.  : 1.program

    ------------------------------------------------------------------------------
                 |            Delta-method
                 |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
            atet |   .1033448   .0489003     2.11   0.035     .0075019    .1991877
    ------------------------------------------------------------------------------

    . rbiprobit tmeffects, tmeffect(atec)

    Treatment effect                                Number of obs     =      2,500
    Model VCE    : OIM

    Expression   : Pr(graduate=1|program=1)-Pr(graduate=1|program=0), predict(pcond1)-predict(pcond10)
    Effect       : Average treatment effect on conditional probability
    dydx w.r.t.  : 1.program

    ------------------------------------------------------------------------------
                 |            Delta-method
                 |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
            atec |   .2765848   .0164366    16.83   0.000     .2443696    .3087999
    ------------------------------------------------------------------------------



## 7. References

[Coban, M. (2020)](http://doku.iab.de/discussionpapers/2020/dp2320.pdf). Redistribution Preferences, Attitudes towards Immigrants, and Ethnic Diversity, IAB Discussion Paper 2020/23.

Greene, W.H. (2018). Econometric Analysis, 8th Edition, Pearson.

[Hasebe, T. (2013)](https://doi.org/10.1016/j.econlet.2013.08.028). Marginal effects of a bivariate binary choice model, Economic Letters 121(2), pp. 298-301.

## 8. About

__Mustafa Coban__\
Institute for Employment Research (Germany)

email:         mustafa.coban@iab.de\
github:        [github.com/cobanomics](https://github.com/cobanomics)\
webpage:       [mustafacoban.de](https://www.mustafacoban.de)


## 9. How to Install

The latest version can be obtained via
```git
net install rbiprobit, from("https://cobanomics.github.io/rbiprobit/")
```

## 10. Changelog
There is currently no changelog. Current version of the command is the initial version 1.0.0
