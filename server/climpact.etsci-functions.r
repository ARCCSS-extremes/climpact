# ------------------------------------------------
# This file contains functions for ET-SCI indices. These functions build upon the functionality provided by the R package
# climdex.pcic developed by the Pacific Climate Impacts Consortium (PCIC).
# ------------------------------------------------

library(climdex.pcic)
library(SPEI)

software_id <- "2.0.0"

# fd
# Annual count when TN < 0ºC
# same as climdex.df except allows monthly and annual calculation
climdex.fd <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmin)); return(number.days.op.threshold(ci@data$tmin, ci@date.factors[[match.arg(freq)]], 0, "<") * ci@namasks[[match.arg(freq)]]$tmin) }

# fd2
# Annual count when TN < 2ºC
# same as climdex.fd except < 2
climdex.tnlt2 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmin)); return(number.days.op.threshold(ci@data$tmin, ci@date.factors[[match.arg(freq)]], 2, "<") * ci@namasks[[match.arg(freq)]]$tmin) }

# fdm2
# Annual count when TN < -2ºC
# same as climdex.fd except < -2
climdex.tnltm2 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmin)); return(number.days.op.threshold(ci@data$tmin, ci@date.factors[[match.arg(freq)]], -2, "<") * ci@namasks[[match.arg(freq)]]$tmin) }

# fdm20
# Annual count when TN < -20ºC
# same as climdex.fd except < -20
climdex.tnltm20 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmin)); return(number.days.op.threshold(ci@data$tmin, ci@date.factors[[match.arg(freq)]], -20, "<") * ci@namasks[[match.arg(freq)]]$tmin) }

# wsdin
# Annual count of days with at least n consecutive days when TX>90th percentile where n>= 2 (and max 10)
# same as climdex.wsdi except user specifies number of consecutive days
climdex.wsdid <- function(ci, spells.can.span.years=FALSE,n=5) { stopifnot(!is.null(ci@data$tmax) || !is.null(ci@quantiles$tmax)); return(threshold.exceedance.duration.index(ci@data$tmax, ci@date.factors$annual, ci@jdays, ci@quantiles$tmax$outbase$q90, ">", spells.can.span.years=spells.can.span.years, max.missing.days=ci@max.missing.days['annual'], min.length=n) * ci@namasks$annual$tmax) }

# csdin
# Annual count of days with at least n consecutive days when TN<10th percentile where n>= 2 (and max 10)
# same as climdex.csdi except user specifies number of consecutive days
climdex.csdid <- function(ci, spells.can.span.years=FALSE,n=5) { stopifnot(!is.null(ci@data$tmin) || !is.null(ci@quantiles$tmin)); return(threshold.exceedance.duration.index(ci@data$tmin, ci@date.factors$annual, ci@jdays, ci@quantiles$tmin$outbase$q10, "<", spells.can.span.years=spells.can.span.years, max.missing.days=ci@max.missing.days['annual'], min.length=n) * ci@namasks$annual$tmin) }

# tr
# Count of days when TN > 20
# same as climdex.tr from climdex.pcic package except allows monthly and annual calculation
climdex.tr <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmin)); return(number.days.op.threshold(ci@data$tmin, ci@date.factors[[match.arg(freq)]], 20, ">") * ci@namasks[[match.arg(freq)]]$tmin) }

# tm5a
# Annual count when TM >= 5ºC
# same as climdex.tr except >= 5C
climdex.tmge5 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tavg)); return(number.days.op.threshold(ci@data$tavg, ci@date.factors[[match.arg(freq)]], 5, ">=") * ci@namasks[[match.arg(freq)]]$tavg) }

# tm5b
# Annual count when TM < 5ºC
# same as climdex.tr except < 5C
climdex.tmlt5 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tavg)); return(number.days.op.threshold(ci@data$tavg, ci@date.factors[[match.arg(freq)]], 5, "<") * ci@namasks[[match.arg(freq)]]$tavg) }

# tm10a
# Annual count when TM >= 10ºC
# same as climdex.tr except >= 10C
climdex.tmge10 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tavg)); return(number.days.op.threshold(ci@data$tavg, ci@date.factors[[match.arg(freq)]], 10, ">=") * ci@namasks[[match.arg(freq)]]$tavg) }

# tm10b
# Annual count when TM < 10ºC
# same as climdex.tr except < 10C
climdex.tmlt10 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tavg)); return(number.days.op.threshold(ci@data$tavg, ci@date.factors[[match.arg(freq)]], 10, "<") * ci@namasks[[match.arg(freq)]]$tavg) }

# id
# Count when TX < 0
# same as climdex.id in climdex.pcic package except allows monthly and annual calculation
climdex.id <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmax)); return(number.days.op.threshold(ci@data$tmax, ci@date.factors[[match.arg(freq)]], 0, "<") * ci@namasks[[match.arg(freq)]]$tmax) }

# su
# Annual count when TX >= 25ºC
# same as climdex.su in climdex.pcic package except allows monthly and annual calculation
climdex.su <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmax)); return(number.days.op.threshold(ci@data$tmax, ci@date.factors[[match.arg(freq)]], 25, ">") * ci@namasks[[match.arg(freq)]]$tmax) }

# su30
# Annual count when TX >= 30ºC
# same as climdex.su except >= 30C
climdex.txge30 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmax)); return(number.days.op.threshold(ci@data$tmax, ci@date.factors[[match.arg(freq)]], 30, ">=") * ci@namasks[[match.arg(freq)]]$tmax) }

# su35
# Annual count when TX >= 35ºC
# same as climdex.su except >= 35C
climdex.txge35 <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmax)); return(number.days.op.threshold(ci@data$tmax, ci@date.factors[[match.arg(freq)]], 35, ">=") * ci@namasks[[match.arg(freq)]]$tmax) }

# HDDheat
# Annual sum of Tb-TM (where Tb is a user-defined location-specific base temperature and TM < Tb). Recomputes climdex input object to re-test newly created tavg array for NA criteria.
climdex.hddheatn <- function(ci,Tb=18) { 
        stopifnot(is.numeric(Tb),!is.null(ci@data$tavg))
	Tbarr = array(Tb,length(ci@data$tavg))
	tavg.tmp <- ci@data$tavg 
	tavg.tmp = ifelse(tavg.tmp >= Tbarr,NaN,tavg.tmp)
        tavg.tmp = ifelse(is.na(tavg.tmp),NaN,tavg.tmp)
	return(tapply.fast(Tbarr - tavg.tmp,ci@date.factors$annual,sum,na.rm=TRUE)*ci@namasks$annual$tavg)}

# CDDcold
# Annual sum of TM-Tb (where Tb is a user-defined location-specific base temperature and TM > Tb)
climdex.cddcoldn <- function(ci,Tb=18) { 
        stopifnot(is.numeric(Tb),!is.null(ci@data$tavg))
	Tbarr = array(Tb,length(ci@data$tavg))
        tavg.tmp <- ci@data$tavg
        tavg.tmp = ifelse(tavg.tmp <= Tbarr,NaN,tavg.tmp)
        tavg.tmp = ifelse(is.na(tavg.tmp),NaN,tavg.tmp)
	return(tapply.fast(tavg.tmp - Tbarr,ci@date.factors$annual,sum,na.rm=TRUE)*ci@namasks$annual$tavg)}

# GDDgrow
# Annual sum of TM-Tb (where Tb is a user-defined location-specific base temperature and TM > Tb)
climdex.gddgrown <- function(ci,Tb=10) {
        stopifnot(is.numeric(Tb),!is.null(ci@data$tavg))
	Tbarr = array(Tb,length(ci@data$tavg))
        tavg.tmp <- ci@data$tavg
        tavg.tmp = ifelse(tavg.tmp <= Tbarr,NaN,tavg.tmp)
        tavg.tmp = ifelse(is.na(tavg.tmp),NaN,tavg.tmp)
	return(tapply.fast(tavg.tmp - Tbarr,ci@date.factors$annual,sum,na.rm=TRUE)*ci@namasks$annual$tavg)}

# cdd
# number of consecutive dry days (when precipitation < 1.0 mm)
# same as climdex.cdd in climdex.pcic package except allows monthly and annual calculation
climdex.cdd <- function(ci, spells.can.span.years=TRUE,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$prec)); return(spell.length.max(ci@data$prec, ci@date.factors[[match.arg(freq)]], 1, "<", spells.can.span.years) * ci@namasks[[match.arg(freq)]]$prec) }

# cwd
# number of consecutive wet days (when precipitation >= 1.0 mm)
# same as climdex.cwd in climdex.pcic package except allows monthly and annual calculation
climdex.cwd <- function(ci, spells.can.span.years=TRUE,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$prec)); return(spell.length.max(ci@data$prec, ci@date.factors[[match.arg(freq)]], 1, ">=", spells.can.span.years) * ci@namasks[[match.arg(freq)]]$prec) }

# Rxnday
# Monthly maximum consecutive n-day precipitation (up to a maximum of 10)
# Same as rx5day except specifying a monthly frequency and accepting user specified number of consecutive days
climdex.rxdday <- function(ci, center.mean.on.last.day=FALSE,n=7,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$prec),is.numeric(n),is.logical(center.mean.on.last.day)); return(nday.consec.prec.max(ci@data$prec, ci@date.factors[[match.arg(freq)]], n, center.mean.on.last.day) * ci@namasks[[match.arg(freq)]]$prec) }

# r95p as per Donat et al. (2013). This is the same as r95ptot in climdex and will need correcting in that package
climdex.r95p <- function(ci) { stopifnot(!is.null(ci@data$prec),!is.null(ci@quantiles$prec)); return(total.precip.op.threshold(ci@data$prec, ci@date.factors$annual, ci@quantiles$prec['q95'], ">") * ci@namasks$annual$prec) }

# r99p as per Donat et al. (2013). This is the same as r99ptot in climdex and will need correcting in that package
climdex.r99p <- function(ci) { stopifnot(!is.null(ci@data$prec),!is.null(ci@quantiles$prec)); return(total.precip.op.threshold(ci@data$prec, ci@date.factors$annual, ci@quantiles$prec['q99'], ">") * ci@namasks$annual$prec) }

# r95ptot
# This function replaces an identically named function in the climdex.pcic package. This is the correct definition.
climdex.r95ptot <- function(ci) { stopifnot(!is.null(ci@data$prec),!is.null(ci@quantiles$prec)); prcptot <- total.precip.op.threshold(ci@data$prec, ci@date.factors$annual, 1, ">=") * ci@namasks$annual$prec
		r95p <- total.precip.op.threshold(ci@data$prec, ci@date.factors$annual, ci@quantiles$prec['q95'], ">") * ci@namasks$annual$prec
		return(100*r95p/prcptot) }

# r99ptot
# This function replaces an identically named function in the climdex.pcic package. This is the correct definition.
climdex.r99ptot <- function(ci) { stopifnot(!is.null(ci@data$prec),!is.null(ci@quantiles$prec)); prcptot <- total.precip.op.threshold(ci@data$prec, ci@date.factors$annual, 1, ">=") * ci@namasks$annual$prec
                r99p <- total.precip.op.threshold(ci@data$prec, ci@date.factors$annual, ci@quantiles$prec['q99'], ">") * ci@namasks$annual$prec
                return(100*r99p/prcptot) }

# r10mm
# Count of days with precip > 10mm
# Same as climdex.r10mm in climdex.pcic package except allows monthly and annual calculation
climdex.r10mm <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$prec)); return(number.days.op.threshold(ci@data$prec, ci@date.factors[[match.arg(freq)]], 10, ">=") * ci@namasks[[match.arg(freq)]]$prec) }

# r20mm
# Count of days with precip > 20mm
# Same as climdex.r20mm in climdex.pcic package except allows monthly and annual calculation
climdex.r20mm <- function(ci,freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$prec)); return(number.days.op.threshold(ci@data$prec, ci@date.factors[[match.arg(freq)]], 20, ">=") * ci@namasks[[match.arg(freq)]]$prec) }

# rnnmm
# Count of days with precip > nn mm
# Same as climdex.rnnmm in climdex.pcic package except allows monthly and annual calculation
climdex.rnnmm <- function(ci, threshold=1,freq=c("monthly", "annual")) {
  stopifnot(!is.null(ci@data$prec));
  if(!is.numeric(threshold) || length(threshold) != 1) stop("Please specify a single numeric threshold value.");

  return(number.days.op.threshold(ci@data$prec, ci@date.factors[[match.arg(freq)]], threshold, ">=") * ci@namasks[[match.arg(freq)]]$prec)
}

# tx95t
# Value of 95th percentile of TX
climdex.tx95t <- function(ci, freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmax),!is.null(ci@quantiles$tmax)); return(ci@quantiles$tmax$outbase$q95) }





################# TEMPORARY INCLUSION FROM CLIMDEX.PCIC
# The following functions have been copied from climdex.pcic while a bug in percent.days.op.threshold is present. 
# Once/if this is fixed in climdex.pcic then the following lines can be deleted. Issue has been logged on their github page.
# nherold, Nov 2020.
get.years <- function(dates) {
  return(as.POSIXlt(dates)$year + 1900)
}

percent.days.op.threshold <- function(temp, dates, jdays, date.factor, threshold.outside.base, base.thresholds, base.range, op='<', max.missing.days) {
  f <- match.fun(op)
  dat <- f(temp, threshold.outside.base[jdays])
  
  inset <- dates >= base.range[1] & dates <= base.range[2]
  ## Don't use in-base thresholds with data shorter than two years; no years to replace with.
  if(sum(inset) > 0 && length(dates) >= 360 * 2) {
    jdays.base <- jdays[inset]
    years.base <- get.years(dates[inset])

    ## Get number of base years, subset temp data to base period only.
    temp.base <- temp[inset]
    years.base.range <- range(years.base)
    byrs <- (years.base.range[2] - years.base.range[1] + 1)

    ## Linearize thresholds, then compare them to the temperatures
    bdim <- dim(base.thresholds)
    dim(base.thresholds) <- c(bdim[1] * bdim[2], bdim[3])
    yday.byr.indices <- jdays.base + (years.base - get.years(base.range)[1]) * bdim[1]
    f.result <- f(rep(temp.base, byrs - 1), base.thresholds[yday.byr.indices,])
    dim(f.result) <- c(length(yday.byr.indices), bdim[3])

    ## Chop up data along the 2nd dim into a list; sum elements of the list
#    dat[inset] <- rowSums(f.result, na.rm=TRUE) / (byrs - 1)
    # Replace above line to properly return NA when all values are NA (problem was occurring because sum(c(Na,NA)) = 0, when it should equal NA).
    dat[inset] <- apply(f.result,1,function(x) if (all(is.na(x))) x[NA_integer_] else sum(x, na.rm = TRUE) / (byrs - 1))
  }
  dat[is.nan(dat)] <- NA
  if(missing(date.factor))
    return(dat)
  na.mask <- get.na.mask(dat, date.factor, max.missing.days)
  ## FIXME: Need to monthly-ize the NA mask calculation, which will be ugly.
  ret <- tapply.fast(dat, date.factor, mean, na.rm=TRUE) * 100 * na.mask
  ret[is.nan(ret)] <- NA
  return(ret)
}

climdex.tn10p <- function(ci, freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmin) && !is.null(ci@quantiles$tmin)); return(percent.days.op.threshold(ci@data$tmin, ci@dates, ci@jdays, ci@date.factors[[match.arg(freq)]], ci@quantiles$tmin$outbase$q10, ci@quantiles$tmin$inbase$q10, ci@base.range, "<", ci@max.missing.days[match.arg(freq)]) * ci@namasks[[match.arg(freq)]]$tmin) }

climdex.tx10p <- function(ci, freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmax) && !is.null(ci@quantiles$tmax)); return(percent.days.op.threshold(ci@data$tmax, ci@dates, ci@jdays, ci@date.factors[[match.arg(freq)]], ci@quantiles$tmax$outbase$q10, ci@quantiles$tmax$inbase$q10, ci@base.range, "<", ci@max.missing.days[match.arg(freq)]) * ci@namasks[[match.arg(freq)]]$tmax) }

climdex.tn90p <- function(ci, freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmin) && !is.null(ci@quantiles$tmin)); return(percent.days.op.threshold(ci@data$tmin, ci@dates, ci@jdays, ci@date.factors[[match.arg(freq)]], ci@quantiles$tmin$outbase$q90, ci@quantiles$tmin$inbase$q90, ci@base.range, ">", ci@max.missing.days[match.arg(freq)]) * ci@namasks[[match.arg(freq)]]$tmin) }

climdex.tx90p <- function(ci, freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$tmax) && !is.null(ci@quantiles$tmax)); return(percent.days.op.threshold(ci@data$tmax, ci@dates, ci@jdays, ci@date.factors[[match.arg(freq)]], ci@quantiles$tmax$outbase$q90, ci@quantiles$tmax$inbase$q90, ci@base.range, ">", ci@max.missing.days[match.arg(freq)]) * ci@namasks[[match.arg(freq)]]$tmax) }

################# END TEMPORARY INCLUSION FROM CLIMDEX.PCIC




# tx50p
# Percentage of days of days where TX>50th percentile
# same as climdex.tx90p, except for 50th percentile
climdex.txgt50p <- function(ci, freq=c("monthly", "annual")) {
	stopifnot(!is.null(ci@data$tmax),!is.null(ci@quantiles$tmax$outbase$q50))
	return(percent.days.op.threshold(ci@data$tmax, ci@dates, ci@jdays, ci@date.factors[[match.arg(freq)]], ci@quantiles$tmax$outbase$q50, ci@quantiles$tmax$inbase$q50, ci@base.range, ">", ci@max.missing.days[match.arg(freq)]) * ci@namasks[[match.arg(freq)]]$tmax) }

# ntxntn
# Annual count of n consecutive days where both TX > 95th percentile and TN > 95th percentile, where n >= 2 (and max of 10)
# This function needs the new function dual.threshold.exceedance.duration.index, which was based on threshold.exceedance.duration.index
climdex.txdtnd <- function(ci, n=5) { 
	stopifnot(!is.null(ci@data$tmax),!is.null(ci@quantiles$tmax),!is.null(ci@data$tmin),!is.null(ci@quantiles$tmin))
	return(dual.threshold.exceedance.duration.index(ci@data$tmax, ci@data$tmin, ci@date.factors$annual, ci@jdays, ci@quantiles$tmax$outbase$q95,ci@quantiles$tmin$outbase$q95, 
		">",">", n=n, max.missing.days=ci@max.missing.days['annual']) * ci@namasks$annual$tmax) }

# ntxbntnb
# Annual count of n consecutive days where both TX < 5th percentile and TN < 5th percentile, where n >= 2 (and max of 10)
# This function needs the new function dual.threshold.exceedance.duration.index, which was based on threshold.exceedance.duration.index
climdex.txbdtnbd <- function(ci, n=5) {
        stopifnot(!is.null(ci@data$tmax),!is.null(ci@quantiles$tmax),!is.null(ci@data$tmin),!is.null(ci@quantiles$tmin))
        return(dual.threshold.exceedance.duration.index(ci@data$tmax, ci@data$tmin, ci@date.factors$annual, ci@jdays, ci@quantiles$tmax$outbase$q5,ci@quantiles$tmin$outbase$q5,
                "<","<", n=n, max.missing.days=ci@max.missing.days['annual']) * ci@namasks$annual$tmax) }

# prcptot
# Modified from climdex.pcic to calculate monthly or annual values
climdex.prcptot <- function(ci, freq=c("monthly", "annual")) { stopifnot(!is.null(ci@data$prec)); return(total.precip.op.threshold(ci@data$prec, ci@date.factors[[match.arg(freq)]], 1, ">=") * ci@namasks[[match.arg(freq)]]$prec) }

climdex.tmm <- function(cio,freq=c("monthly", "annual")) { stopifnot(!is.null(cio@data$tavg)); return(suppressWarnings(tapply.fast(cio@data$tavg, cio@date.factors[[match.arg(freq)]], mean, na.rm=TRUE)) * cio@namasks[[match.arg(freq)]]$tmin * cio@namasks[[match.arg(freq)]]$tmax) }

climdex.tnm<- function(cio,freq=c("monthly", "annual")) { stopifnot(!is.null(cio@data$tmin)); return(suppressWarnings(tapply.fast(cio@data$tmin, cio@date.factors[[match.arg(freq)]], mean, na.rm=TRUE)) * cio@namasks[[match.arg(freq)]]$tmin) }

climdex.txm <- function(cio,freq=c("monthly", "annual")) { stopifnot(!is.null(cio@data$tmax)); return(suppressWarnings(tapply.fast(cio@data$tmax, cio@date.factors[[match.arg(freq)]], mean, na.rm=TRUE)) * cio@namasks[[match.arg(freq)]]$tmax) }

# dual.threshold.exceedance.duration.index
# calculates the number of n consecutive days where op1 and op2 operating on daily.temp1 and daily.temp2 respectively are satisfied.
dual.threshold.exceedance.duration.index <- function(daily.temp1, daily.temp2, date.factor, jdays, thresholds1, thresholds2, op1=">", op2=">", n, max.missing.days) {
	stopifnot(is.numeric(c(daily.temp1,daily.temp2, thresholds1,thresholds2, n)), is.factor(date.factor),is.function(match.fun(op1)),is.function(match.fun(op2)),n > 0,length(daily.temp1)==length(daily.temp2))
	f1 <- match.fun(op1)
	f2 <- match.fun(op2)
	na.mask1 <- get.na.mask(is.na(daily.temp1 + thresholds1[jdays]), date.factor, max.missing.days)
	na.mask2 <- get.na.mask(is.na(daily.temp2 + thresholds2[jdays]), date.factor, max.missing.days)
	na.mask_combined = na.mask1 & na.mask2
	
	return(tapply.fast(1:length(daily.temp1), date.factor, function(idx) {
	      periods1 = f1(daily.temp1[idx], thresholds1[jdays[idx]])
	      periods2 = f2(daily.temp2[idx], thresholds2[jdays[idx]])
	      periods_combined = select.blocks.gt.length(periods1 & periods2,n)
	
	      # only consider events as separate if they are separated by more than k days.
	      k <- 3
	      invert_periods_combined = !periods_combined					# make TRUE = FALSE and vice versa
	      invert_periods_combined = select.blocks.gt.length(invert_periods_combined,k)	# make any run of k or less days of 'TRUE' values (i.e. FALSE) equal FALSE.
	      periods_combined = !invert_periods_combined					# invert array again.
	      runlength = rle(periods_combined)
	      return(length(runlength$lengths[runlength$values==TRUE])) }) * na.mask_combined)
}

# SPEI. From the SPEI CRAN package.
# INPUT:
#    - climdex input object
#    - scale
#    - kernal
#    - distribution
#    - fit
# OUTPUT:
#    - a monthly (as per the index definition) time-series of SPEI values.
climdex.spei <- function(ci,scale=c(3,6,12),kernal=list(type='rectangular',shift=0),distribution='log-Logistic',fit='ub-pwm',lat=NULL) { 
        stopifnot(is.numeric(scale),all(scale>0),!is.null(ci@data$prec))
        if(is.null(ci@data$tmin) | is.null(ci@data$tmax) | is.null(ci@data$prec)) stop("climdex.spei requires tmin, tmax and precip.")

        scale <- c(3,6,12)      # hard-coded for Climpact definition.
        ts.origin = ("1850-01-01")      # arbitrarily chosen origin for time-series object

        # if we are to use thresholds from a previous calculation then set computefuture flag to TRUE
	if(all(!is.null(ci@quantiles$raw$tmax),!is.null(ci@quantiles$raw$tmin),!is.null(ci@quantiles$raw$prec))) computefuture = TRUE else computefuture = FALSE

        ts.start <- c(as.numeric(format(ci@dates[1],format="%Y")),1)
        ts.end <- c(as.numeric(format(ci@dates[length(ci@dates)],format="%Y")),12)
        ref.start = c(as.numeric(format(ci@base.range[1],format="%Y")),1)
        ref.end = c(as.numeric(format(ci@base.range[2],format="%Y")),12)

# If using a base period from a previous time series:
#  Concatenate base period tmin, tmax and prec that is passed by user. Beginning of the time series will have base period data, end of the time series will have data from ci, any data in the middle will remain NA.
#  This is done because SPEI needs the base period data to use as a reference and does not have an option to read this in separately. Thus, we construct a synthetic time series that dates from the base period to the end of the 
#  current periods' data (i.e. the data in the 'ci' object).
        if(computefuture){
	# construct dates for time series beginning at start of reference period and ending at end of data.
		if(attr(ci@dates,"cal")=="360") { 
			beg = as.PCICt(paste(ref.start[1],"01","01",sep="-"),cal="360_day")
			end = as.PCICt(paste(ts.end[1],"12","30",sep="-"),cal="360_day") 
			pcict.origin = as.PCICt(ts.origin,cal="360_day")
		} else if (attr(ci@dates,"cal")=="365") { 
			beg = as.PCICt(paste(ref.start[1],"01","01",sep="-"),cal="365_day")
                        end = as.PCICt(paste(ts.end[1],"12","31",sep="-"),cal="365_day") 
                        pcict.origin = as.PCICt(ts.origin,cal="365_day")
                } else if (attr(ci@dates,"cal")=="gregorian" || attr(ci@dates,"cal")=="proleptic_gregorian") {
                        beg = as.PCICt(paste(ref.start[1],"01","01",sep="-"),cal="gregorian")
                        end = as.PCICt(paste(ts.end[1],"12","31",sep="-"),cal="gregorian") 
                        pcict.origin = as.PCICt(ts.origin,cal="gregorian")
		}

		dat.seq = seq(beg,end,by = "day")
		diffdat = (dat.seq - pcict.origin)#*86400
		spidates = as.PCICt(as.numeric(diffdat),cal=attr(ci@dates,"cal"),pcict.origin)

		spitmin <- spitmax <- spiprec <- spifactor <- array(NA,length(spidates))
		spitmin[1:length(ci@quantiles$raw$tmin)] = ci@quantiles$raw$tmin
	        spitmax[1:length(ci@quantiles$raw$tmax)] = ci@quantiles$raw$tmax
	        spiprec[1:length(ci@quantiles$raw$prec)] = ci@quantiles$raw$prec
	
		spitmin[(length(spitmin)-length(ci@data$tmin)+1):length(spitmin)] = ci@data$tmin
	        spitmax[(length(spitmax)-length(ci@data$tmax)+1):length(spitmax)] = ci@data$tmax
	        spiprec[(length(spiprec)-length(ci@data$prec)+1):length(spiprec)] = ci@data$prec
	        spifactor = factor(format(spidates,format="%Y-%m"))
	
	# change ts.start when doing future runs since SPEI can't handle ref.start values after ts.end values, I think!
		ts.start = as.numeric(c(format(ci@base.range[1],format="%Y"),1)) #ref.start
	} else {
		spitmin = ci@data$tmin
		spitmax = ci@data$tmax
		spiprec = ci@data$prec
		spifactor = ci@date.factors$monthly

                if(attr(ci@dates,"cal")=="360") {
                        beg = as.PCICt(paste(ts.start[1],"01","01",sep="-"),cal="360_day")
                        end = as.PCICt(paste(ts.end[1],"12","30",sep="-"),cal="360_day")
                        pcict.origin = as.PCICt(ts.origin,cal="360_day")
                } else if (attr(ci@dates,"cal")=="365") {
                        beg = as.PCICt(paste(ts.start[1],"01","01",sep="-"),cal="365_day")
                        end = as.PCICt(paste(ts.end[1],"12","31",sep="-"),cal="365_day")
                        pcict.origin = as.PCICt(ts.origin,cal="365_day")
                } else if (attr(ci@dates,"cal")=="gregorian" || attr(ci@dates,"cal")=="proleptic_gregorian") {
                        beg = as.PCICt(paste(ts.start[1],"01","01",sep="-"),cal="gregorian")
                        end = as.PCICt(paste(ts.end[1],"12","31",sep="-"),cal="gregorian")
                        pcict.origin = as.PCICt(ts.origin,cal="gregorian")
                }

                dat.seq = seq(beg,end,by = "day")
                diffdat = (dat.seq - pcict.origin)#*86400
                spidates = as.PCICt(as.numeric(diffdat),cal=attr(ci@dates,"cal"),pcict.origin)
	}

# get monthly means of tmin and tmax. And monthly total precip.
        tmax_monthly <- as.numeric(tapply.fast(spitmax,spifactor,mean,na.rm=TRUE))
        tmin_monthly <- as.numeric(tapply.fast(spitmin,spifactor,mean,na.rm=TRUE))
        prec_sum <- as.numeric(tapply.fast(spiprec,spifactor,function(x) { if(all(is.na(x))) { return(NA) } else { return(sum(x,na.rm=TRUE)) } } ))	# Needed this function since summing a series of NA with na.rm = TRUE results in zero instead of NA.

	tmax_monthly[tmax_monthly=="NaN"] <- NA
	tmin_monthly[tmin_monthly=="NaN"] <- NA

# calculate PET
        pet <- hargreaves(tmin_monthly,tmax_monthly,lat=lat,Pre=prec_sum,na.rm=TRUE)

# calculate SPEI
        x <- array(NA,c(3,length(unique(factor(format(spidates,format="%Y-%m"))))))
        for (i in 1:length(x[,1])) {
                spei_col <- spei(ts(prec_sum-pet,freq=12,start=ts.start,end=ts.end),scale=scale[i],ref.start=ref.start,ref.end=ref.end,distribution=distribution,fit=fit,kernal=kernal,na.rm=TRUE)
                tmpvar <- spei_col$fitted

        # remove NA, -Inf and Inf values which most likely occur due to unrealistic values in P or PET. This almost entirely occurs in ocean regions and varies depending on the fitting distribution used.
#                tmpvar[is.na(tmpvar)] <- NaN
#                tmpvar <- ifelse(tmpvar=="-Inf",-2.33,tmpvar)
#                tmpvar <- ifelse(tmpvar=="Inf",2.33,tmpvar)
                tmpvar <- ifelse(tmpvar=="-Inf",NA,tmpvar)
                tmpvar <- ifelse(tmpvar=="Inf",NA,tmpvar)

                tmpvar <- ifelse(tmpvar=="NaNf",NA,tmpvar)
                tmpvar <- ifelse(tmpvar=="NaN",NA,tmpvar)
                x[i,] <- tmpvar
        }
        rm(tmpvar)

# - Strip back off all data not part of the original time series.
# - Another kludge here relates to an ostensible bug in the SPEI function. When SPEI is fed a series of NA values followed by valid data, it returns values of SPEI/SPI for those NA values, when it shouldn't.
#    The author has been alerted to this problem. But this means that when a synthetic time series has been made for scenarios using reference data from a different dataset, the initial SPEI/SPI values need
#    to be manually removed. The first 2, 5 and 11 values for each final time series needs NA'ing, corresponding to 3, 6 and 12 month calculation periods.
	if(computefuture) {
		x <- x[,(length(x[1,])-length(unique(ci@date.factors$monthly))+1):length(x[1,])]
		for(i in 1:length(scale)) { x[i,1:(scale[i]-1)] <- NA }
	}

        return((x))
}

# SPI. From the SPEI CRAN package.
# INPUT:
#    - climdex input object
#    - scale
#    - kernal
#    - distribution
#    - fit
# OUTPUT:
#    - a monthly (as per the index definition) time-series of SPI values.
climdex.spi <- function(ci,scale=c(3,6,12),kernal=list(type='rectangular',shift=0),distribution='Gamma',fit='ub-pwm') {
        stopifnot(is.numeric(scale),all(scale>0),!is.null(ci@data$prec))
        if(is.null(ci@data$prec)) stop("climdex.spi requires precip.")

        scale <- c(3,6,12)      # hard-coded for Climpact definition.
        ts.origin = ("1850-01-01")      # arbitrarily chosen origin for time-series object

	# if we are to use thresholds from a previous calculation then set computefuture flag to TRUE
        if(all(!is.null(ci@quantiles$raw$prec))) computefuture = TRUE else computefuture = FALSE

        ts.start <- c(as.numeric(format(ci@dates[1],format="%Y")),1)
        ts.end <- c(as.numeric(format(ci@dates[length(ci@dates)],format="%Y")),12)
        ref.start =  c(as.numeric(format(ci@base.range[1],format="%Y")),1)
        ref.end = c(as.numeric(format(ci@base.range[2],format="%Y")),12)

# If using a base period from a previous time series:
#  Concatenate base period tmin, tmax and prec that is passed by user. Beginning of the time series will have base period data, end of the time series will have data from ci, any data in the middle will remain NA.
#  This is done because SPEI needs the base period data to use as a reference and does not have an option to read this in separately. Thus, we construct a synthetic time series that dates from the base period to the end of the 
#  current periods' data (i.e. the data in the 'ci' object).
        if(computefuture){
                # construct dates
                if(attr(ci@dates,"cal")=="360") {
                        beg = as.PCICt(paste(ref.start[1],"01","01",sep="-"),cal="360_day")
                        end = as.PCICt(paste(ts.end[1],"12","30",sep="-"),cal="360_day")
                        pcict.origin = as.PCICt(ts.origin,cal="360_day")
                } else if (attr(ci@dates,"cal")=="365") {
                        beg = as.PCICt(paste(ref.start[1],"01","01",sep="-"),cal="365_day")
                        end = as.PCICt(paste(ts.end[1],"12","31",sep="-"),cal="365_day")
                        pcict.origin = as.PCICt(ts.origin,cal="365_day")
                } else if (attr(ci@dates,"cal")=="gregorian" || attr(ci@dates,"cal")=="proleptic_gregorian") { 
                        beg = as.PCICt(paste(ref.start[1],"01","01",sep="-"),cal="gregorian")
                        end = as.PCICt(paste(ts.end[1],"12","31",sep="-"),cal="gregorian")
                        pcict.origin = as.PCICt(ts.origin,cal="gregorian")
                }

                dat.seq = seq(beg,end,by = "day")
                diffdat = (dat.seq - pcict.origin)
                spidates = as.PCICt(as.numeric(diffdat),cal=attr(ci@dates,"cal"),pcict.origin)

                spiprec <- spifactor <- array(NA,length(spidates))
                spiprec[1:length(ci@quantiles$raw$prec)] = ci@quantiles$raw$prec

                spiprec[(length(spiprec)-length(ci@data$prec)+1):length(spiprec)] = ci@data$prec
                spifactor = factor(format(spidates,format="%Y-%m"))

        # change ts.start when doing future runs since SPEI can't handle ref.start values after ts.end values, I think!
                ts.start = as.numeric(c(format(ci@base.range[1],format="%Y"),1))
        } else {
                spitmin = ci@data$tmin
                spitmax = ci@data$tmax
                spiprec = ci@data$prec
                spifactor = ci@date.factors$monthly

                if(attr(ci@dates,"cal")=="360") {
                        beg = as.PCICt(paste(ts.start[1],"01","01",sep="-"),cal="360_day")
                        end = as.PCICt(paste(ts.end[1],"12","30",sep="-"),cal="360_day")
                        pcict.origin = as.PCICt(ts.origin,cal="360_day")
                } else if (attr(ci@dates,"cal")=="365") {
                        beg = as.PCICt(paste(ts.start[1],"01","01",sep="-"),cal="365_day")
                        end = as.PCICt(paste(ts.end[1],"12","31",sep="-"),cal="365_day")
                        pcict.origin = as.PCICt(ts.origin,cal="365_day")
                } else if (attr(ci@dates,"cal")=="gregorian" || attr(ci@dates,"cal")=="proleptic_gregorian") {
                        beg = as.PCICt(paste(ts.start[1],"01","01",sep="-"),cal="gregorian")
                        end = as.PCICt(paste(ts.end[1],"12","31",sep="-"),cal="gregorian")
                        pcict.origin = as.PCICt(ts.origin,cal="gregorian")
                }

                dat.seq = seq(beg,end,by = "day")
                diffdat = (dat.seq - pcict.origin)
                spidates = as.PCICt(as.numeric(diffdat),cal=attr(ci@dates,"cal"),pcict.origin)
        }

# get monthly total precip.
        prec_sum <- as.numeric(tapply.fast(spiprec,spifactor,sum,na.rm=TRUE))

# calculate spi
        x <- array(NA,c(3,length(unique(factor(format(spidates,format="%Y-%m"))))))
        for (i in 1:3) {
                spi_col <- spi(ts(prec_sum,freq=12,start=ts.start,end=ts.end),scale=scale[i],ref.start=ref.start,ref.end=ref.end,distribution=distribution,fit=fit,kernal=kernal,na.rm=TRUE)
                tmpvar <- (spi_col$fitted)

        # remove NA, -Inf and Inf values which most likely occur due to unrealistic values in P. This almost entirely occurs in ocean regions and varies depending on the fitting distribution used.
#                tmpvar[is.na(tmpvar)] = NaN
#                tmpvar <- ifelse(tmpvar=="-Inf",-2.33,tmpvar)
#                tmpvar <- ifelse(tmpvar=="Inf",2.33,tmpvar)
                tmpvar <- ifelse(tmpvar=="-Inf",NA,tmpvar)
                tmpvar <- ifelse(tmpvar=="Inf",NA,tmpvar)

                tmpvar <- ifelse(tmpvar=="NaNf",NA,tmpvar)
                tmpvar <- ifelse(tmpvar=="NaN",NA,tmpvar)

                x[i,] <- tmpvar
        }
        rm(tmpvar)

# - Strip back off all data not part of the original time series.
# - Another kludge here relates to an ostensible bug in the SPEI function. When SPEI is fed a series of NA values followed by valid data, it returns values of SPEI/SPI for those NA values, when it shouldn't.
#    The author has been alerted to this problem. But this means that when a synthetic time series has been made for scenarios using reference data from a different dataset, the initial SPEI/SPI values need
#    to be manually removed. The first 2, 5 and 11 values for each final time series needs NA'ing, corresponding to 3, 6 and 12 months calculation periods.
        if(computefuture) {
                x <- x[,(length(x[1,])-length(unique(ci@date.factors$monthly))+1):length(x[1,])]
                for(i in 1:length(scale)) { x[i,1:(scale[i]-1)] <- NA }
        }

        return((x))
}

# hw
# Calculate heat wave indices. See Perkins and Alexander (2013) and Nairn and Fawcett (2013) for calculations.
# Leap days are removed.
#
# INPUT:
#    - climdex input object
#    - pwindow: number of days to apply a moving window for calculating percentiles. Hard-coded to 15 currently to ensure user does not deviate from definitions.
#    - min.base.data.fraction.present: minimum fraction of data required to calculate percentiles.
#    - ehfdef: Calculate the Excess Heat Factor (EHF) using either "PA13" for Perkins and Alexander (2013) with slight modifications (personal comms Perkins 2016),
#	       or using "NF13" for Nairn and Fawcett (2013).
#
# OUTPUT: This function will return a 3D dataset of dimensions [definition,aspect,years], with corresponding lengths [4,5,nyears].
#
# HEAT WAVE DEFINITIONS:
#    - TX90p
#    - TN90p
#    - EHF (Excess Heat Factor)
#    - ECF (Excess Cold Factor)
# HEAT WAVE ASPECTS:
#    - HWM: heat wave magnitude
#    - HWA: heat wave amplitude
#    - HWN: heat wave number
#    - HWD: heat wave duration
#    - HWF: heat wave frequency
climdex.hw <- function(ci,pwindow=15,min.base.data.fraction.present,ehfdef="PA13") {
	stopifnot(!is.null(ci@data$tmin),!is.null(ci@data$tmax))
	ts.origin = ("1850-01-01")      # arbitrarily chosen origin for time-series object
	
	# step 1. Get data needed for the three definitions of a heat wave. 
	# recalculate tavg here to ensure it is based on tmax/tmin. Then get 15 day moving windows of percentiles.
	tavg = (ci@data$tmax + ci@data$tmin)/2
	b1 = as.numeric(format(ci@base.range[1],format="%Y"))
	b2 = as.numeric(format(ci@base.range[2],format="%Y"))
	
	# If there are no quantiles provided (i.e. no threshold file has been read into the main program) then create thresholds
	if(any(is.null(ci@quantiles$tmax$outbase$q90_15days),is.null(ci@quantiles$tmin$outbase$q90_15days),is.null(ci@quantiles$tavg$outbase$q90_15days))) {
		# retrieve array indices corresponding to base period, for calculation of quantiles for ECF and EHF_NF13
		factor.numeric = as.numeric(levels(ci@date.factors$annual))[ci@date.factors$annual]
		ind = which(factor.numeric >= b1 & factor.numeric <= b2)
	        if(ehfdef == "NF13") { tavg95p <- quantile(tavg[ind],0.95,na.rm=TRUE) }
	        # need to reference 'tmax' data slot in tavg90p because of naming convention in get.outofbase.quantiles
	        tavg90p <- suppressWarnings(get.outofbase.quantiles(tavg,ci@data$tmin,tmax.dates=ci@dates,tmin.dates=ci@dates,base.range=c(b1,b2),n=15,temp.qtiles=0.9,prec.qtiles=0.9,
	                                                        min.base.data.fraction.present=min.base.data.fraction.present))
	        tavg90p <- tavg90p$tmax$outbase$q90
	        TxTn90p <- suppressWarnings(get.outofbase.quantiles(ci@data$tmax,ci@data$tmin,tmax.dates=ci@dates,tmin.dates=ci@dates,base.range=c(b1,b2),n=15,temp.qtiles=0.9,prec.qtiles=0.9,
	                                                        min.base.data.fraction.present=min.base.data.fraction.present))
	        tn90p <- TxTn90p$tmin$outbase$q90
	        tx90p <- TxTn90p$tmax$outbase$q90 
		tavg05p <- quantile(tavg[ind],0.05,na.rm=TRUE) }
	else {
		tn90p <- ci@quantiles$tmin$outbase$q90_15days
		tx90p <- ci@quantiles$tmax$outbase$q90_15days
		tavg90p <- ci@quantiles$tavg$outbase$q90_15days
		tavg05p <- ci@quantiles$tavg[["q5"]]
	        if(ehfdef == "NF13") { tavg95p <- ci@quantiles$tavg[["q95"]] }
	}

	# take any non leap year to create 365 month-day factors
	beg = as.Date("2001-01-01",format="%Y-%m-%d")
	end = as.Date("2001-12-31",format="%Y-%m-%d")
	dat.seq = seq(beg,end,by = "1 day")
	fact = factor(format(dat.seq,format="%m-%d"))
	
	# create date sequence from beginning of record to end, then create month-day factors
	if(attr(ci@dates,"cal")=="360") {
	        beg2 = as.PCICt(paste(ci@date.factors$annual[1],"01","01",sep="-"),cal="360_day")
	        end2 = as.PCICt(paste(ci@date.factors$annual[length(ci@date.factors$annual)],"12","30",sep="-"),cal="360_day")
	        pcict.origin = as.PCICt(ts.origin,cal="360_day")
	} else if (attr(ci@dates,"cal")=="365") {
	        beg2 = as.PCICt(paste(ci@date.factors$annual[1],"01","01",sep="-"),cal="365_day")
	        end2 = as.PCICt(paste(ci@date.factors$annual[length(ci@date.factors$annual)],"12","31",sep="-"),cal="365_day")
	        pcict.origin = as.PCICt(ts.origin,cal="365_day")
	} else if (attr(ci@dates,"cal")=="gregorian" || attr(ci@dates,"cal")=="proleptic_gregorian") {
	        beg2 = as.PCICt(paste(ci@date.factors$annual[1],"01","01",sep="-"),cal="gregorian")
	        end2 = as.PCICt(paste(ci@date.factors$annual[length(ci@date.factors$annual)],"12","31",sep="-"),cal="gregorian")
	        pcict.origin = as.PCICt(ts.origin,cal="gregorian")
	}
	
	dat.seq2 = seq(beg2,end2,by = "day")
	fact2 = factor(format(dat.seq2,format="%m-%d"))
	
	# remove leap days from factors and temperature time series, except when calendar is 360 day as leap years have no meaning in this case.
	if(attr(ci@dates,"cal")=="proleptic_gregorian" || attr(ci@dates,"cal")=="gregorian") {
		tmax <- ci@data$tmax[!fact2 %in% as.factor("02-29")]
		tmin <- ci@data$tmin[!fact2 %in% as.factor("02-29")]
		tavg <- tavg[!fact2 %in% as.factor("02-29")]
		monthly.factors <- ci@date.factors$monthly[!fact2 %in% as.factor("02-29")]
		annual.factors <- ci@date.factors$annual[!fact2 %in% as.factor("02-29")]
		fact2 <- fact2[!fact2 %in% as.factor("02-29")]
	} else {
	        tmax <- ci@data$tmax
	        tmin <- ci@data$tmin
	        tavg <- tavg
	        monthly.factors <- ci@date.factors$monthly
	        annual.factors <- ci@date.factors$annual
	}
	
	# get shells for the following three variables and duplicate
	EHIaccl <- EHIsig <- EHF <- array(NA,length(tavg))
	ECIaccl <- ECIsig <- ECF <- array(NA,length(tavg))
	
	# assign daily percentiles to the entire time series. If gregorian then February 29 days will be NA.
	annualrepeat_tavg90 <- annualrepeat_tavg05 <- array(NA,length(tavg))
	if(ehfdef == "NF13") { annualrepeat_tavg90 = array(tavg95p,length(tavg)) }
	else if (ehfdef == "PA13") { annualrepeat_tavg90 = tavg90p[match(fact2,fact2)] }
	
	annualrepeat_tavg05 <- array(tavg05p,length(tavg)) 
	
	# Calculate EHI/ECI values and EHF/ECF for each day of the given record. Must start at day 33 since the previous 32 days are required for each calculation.
	for (a in 33:length(tavg)) {
	        EHIaccl[a] = (sum(tavg[a],tavg[a-1],tavg[a-2])/3) - (sum(tavg[(a-32):(a-3)],na.rm=TRUE)/30)
	        EHIsig[a] = (sum(tavg[a],tavg[a-1],tavg[a-2])/3) - as.numeric(unlist(annualrepeat_tavg90[a]))  #as.numeric(unlist(tavg90p$tmax[1])[annualrepeat[a]]) #[(a %% 365)]
	        EHF[a] = max(1,EHIaccl[a])*EHIsig[a]
	
	        ECIaccl[a] = (sum(tavg[a],tavg[a-1],tavg[a-2])/3) - (sum(tavg[(a-32):(a-3)],na.rm=TRUE)/30)
	        ECIsig[a] = (sum(tavg[a],tavg[a-1],tavg[a-2])/3) - as.numeric(unlist(annualrepeat_tavg05[a]))  #as.numeric(unlist(tavg90p$tmax[1])[annualrepeat[a]]) #[(a %% 365)]
	        ECF[a] = min(-1,ECIaccl[a])*(-1*ECIsig[a])
	}

# step 2. Determine if tx90p, tn90p or EHF conditions have persisted for >= 3 days. If so, count number of summer heat waves.
	# assign the 365 percentiles to the entire time series based on date factors (so as to account for leap years) - February 29 days will be NA.
	tx90p_arr <- array(NA,length(tmax))
	tx90p_arr <- tx90p[match(fact2,fact)]
	tn90p_arr <- array(NA,length(tmin))
	tn90p_arr <- tn90p[match(fact2,fact)]

	# Record which days had temperatures higher than 90p or where EHF > 0 
	tx90p_boolean <- (tmax > tx90p_arr)
	tn90p_boolean <- (tmin > tn90p_arr)
	EHF_boolean <- (EHF > 0)
	ECF_boolean <- (ECF < 0)
	
	# Remove runs that are < 3 days long
	tx90p_boolean <- select.blocks.gt.length(tx90p_boolean,2)
	tn90p_boolean <- select.blocks.gt.length(tn90p_boolean,2)
	EHF_boolean <- select.blocks.gt.length(EHF_boolean,2)
	ECF_boolean <- select.blocks.gt.length(ECF_boolean,2)

# Step 3. Calculate aspects for each definition.
	hw_index <- array(NA,c(4,5,length(levels(annual.factors))))
	hw1_index <- array(NA,c(5,length(levels(annual.factors))))
	hw2_index <- array(NA,c(5,length(levels(annual.factors))))
	hw3_index <- array(NA,c(5,length(levels(annual.factors))))
	hw4_index <- array(NA,c(5,length(levels(annual.factors))))
	
	hw_index[1,,] <- get.hw.aspects(hw1_index,tx90p_boolean,annual.factors,monthly.factors,tmax,ci@northern.hemisphere,ehfdef,namask=ci@namasks$annual$tmax)
	hw_index[2,,] <- get.hw.aspects(hw2_index,tn90p_boolean,annual.factors,monthly.factors,tmin,ci@northern.hemisphere,ehfdef,namask=ci@namasks$annual$tmin)
	hw_index[3,,] <- get.hw.aspects(hw3_index,EHF_boolean,annual.factors,monthly.factors,EHF,ci@northern.hemisphere,ehfdef,ehf=TRUE,namask=ci@namasks$annual$tmin*ci@namasks$annual$tmax)
	hw_index[4,,] <- get.hw.aspects(hw4_index,ECF_boolean,annual.factors,monthly.factors,ECF,ci@northern.hemisphere,ehfdef,ecf=TRUE,namask=ci@namasks$annual$tmin*ci@namasks$annual$tmax)
	
	rm(tavg,tavg90p,EHIaccl,EHIsig,EHF,tx90p_boolean,tn90p_boolean,EHF_boolean,tx90p_arr,tn90p_arr,hw1_index,hw2_index,hw3_index,tn90p,tx90p,beg,end,beg2,end2,dat.seq,dat.seq2,fact,fact2,ECIaccl,ECIsig,ECF)
	return(hw_index)
}

# get.hw.aspects
# Calculate heat wave aspects as per Perkins and Alexander (2013). HWM, HWA, HWN, HWD, HWF. 
# EHF definition is updated (personal comms Perkins 2015). Changes include using the 90th percentile (instead of 95th) and using 15-day window running percentiles,
# instead of climatological percentiles. Thus each day of the calendar year has a unique percentile associated with it.
#
# INPUT:
#    - aspect.array: empty array used to hold aspects.
#    - boolean.str: an array of booleans indicating the existence of a heatwave for each day.
#    - yearly.date.factors: annual date factors from climdex.input object.
#    - monthly.date.factors: monthly date factors from climdex.input object.
#    - daily.data: daily values of either TX, TN or EHF.
#    - northern.hemisphere: boolean for determining summer months.
#    - ehfdef: Calculate the Excess Heat Factor (EHF) using either "PA13" for Perkins and Alexander (2013) with slight modifications (personal comms Perkins 2016),
#	   or using "NF13" for Nairn and Fawcett (2013).
#
# OUTPUT:
#    - aspect.array: filled with calculated aspects.
get.hw.aspects <- function(aspect.array,boolean.str,yearly.date.factors,monthly.date.factors,daily.data,northern.hemisphere,ehfdef,ehf=FALSE,ecf=FALSE,namask=1) {
	if(all(is.na(daily.data))) { return(aspect.array) }

	month <- substr(monthly.date.factors,nchar(as.character(levels(monthly.date.factors)[1]))-1,nchar(as.character(levels(monthly.date.factors)[1])))

	daily.data.full = daily.data # make a copy of all daily data
	boolean.str.full = boolean.str # make a copy of all boolean data

	nyears = length(levels(yearly.date.factors))
	extended_window = 90	# number of days beyond the summer season in which to look for HWs that started inside the summer season (but ended after it).
	aspect_ind = 1 # keep track of the index of the aspect array to store data in

	for (year in levels(yearly.date.factors)[1]:levels(yearly.date.factors)[nyears]) {
		if((ehf==TRUE && ehfdef=="NF13") || ecf==TRUE) { summer_indices = which(yearly.date.factors %in% as.factor(year)) } else {
		if(northern.hemisphere==FALSE) {
			summer_indices = which(monthly.date.factors %in% as.factor(paste(year,"-11",sep="")) | monthly.date.factors %in% as.factor(paste(year,"-12",sep="")) | monthly.date.factors %in% as.factor(paste(year+1,"-01",sep="")) |
	        	        monthly.date.factors %in% as.factor(paste(year+1,"-02",sep="")) | monthly.date.factors %in% as.factor(paste(year+1,"-03",sep="")))
		} else {
	                summer_indices = which(monthly.date.factors %in% as.factor(paste(year,"-05",sep="")) | monthly.date.factors %in% as.factor(paste(year,"-06",sep="")) | monthly.date.factors %in% as.factor(paste(year,"-07",sep="")) |
	                        monthly.date.factors %in% as.factor(paste(year,"-08",sep="")) | monthly.date.factors %in% as.factor(paste(year,"-09",sep="")))
		} }

		extended_indices = seq((summer_indices[1]),(summer_indices[length(summer_indices)]+extended_window),1)
		extended_data = daily.data.full[extended_indices]
		extended_boolean = boolean.str.full[extended_indices]
		rle_extended_boolean = rle(as.logical(extended_boolean))
		last_day_of_hw_season = (length(extended_boolean)-extended_window)

		# indices of extended_data that include heatwaves that start during season and end before end of season.
		truevals = which((rle_extended_boolean$lengths)>=3 & cumsum(rle_extended_boolean$lengths)<=last_day_of_hw_season & rle_extended_boolean$values==TRUE)

		# If any days of a HW that started prior to the season of interest occur inside the season of interest, count the days that occur inside the season
		if(all(!is.na(extended_boolean[1:2]),!is.na(boolean.str.full[summer_indices[1]-1]))) {
#			if(all(extended_boolean[1:2]==TRUE,extended_boolean[3]==FALSE) && length(truevals)>0 && boolean.str.full[summer_indices[1]-1]==TRUE)
			if(all(extended_boolean[1:2]==TRUE,extended_boolean[3]==FALSE,boolean.str.full[summer_indices[1]-1]==TRUE))
			{
				if(length(truevals)==0) truevals = c(1)
				else if(length(truevals)>0 && truevals[1]!=1) truevals = c(1,truevals)
			}
		}
		if(all(!is.na(extended_boolean[1]),!is.na(boolean.str.full[summer_indices[1]-2]),!is.na(boolean.str.full[summer_indices[1]-1]))) {
#			if(all(extended_boolean[1]==TRUE,extended_boolean[2]==FALSE,length(truevals)>0,boolean.str.full[summer_indices[1]-2]==TRUE,boolean.str.full[summer_indices[1]-1]==TRUE)) 
			if(all(extended_boolean[1]==TRUE,extended_boolean[2]==FALSE,boolean.str.full[summer_indices[1]-2]==TRUE,boolean.str.full[summer_indices[1]-1]==TRUE)) 
			{
				if(length(truevals)==0) truevals = c(1)
				else if(length(truevals)>0 && truevals[1]!=1) truevals = c(1,truevals)
			}
		}

		# indices of heatwave(s) that end after season.
		extvals = which((rle_extended_boolean$lengths)>=3 & cumsum(rle_extended_boolean$lengths)>last_day_of_hw_season & rle_extended_boolean$values==TRUE)

		if(!is.na(last_day_of_hw_season) && length(cumsum(rle_extended_boolean$lengths)) > 1) {
			if(length(extvals)>0 && extvals[1] > 1 && cumsum(rle_extended_boolean$lengths)[extvals[1]-1]<last_day_of_hw_season) 
			# then the next heatwave actually started in summer and should be counted. However, if the HW is longer than 14 days
	        {
	                truevals = c(truevals,extvals[1])
	                if(cumsum(rle_extended_boolean$lengths)[extvals[1]] > (length(summer_indices)+14))	#length(summer_indices)+14))
					{
						rle_extended_boolean$lengths[extvals[1]] = rle_extended_boolean$lengths[extvals[1]] - (cumsum(rle_extended_boolean$lengths)[extvals[1]]-(length(summer_indices)+14))#(length(summer_indices)+14))
					}
	        }
		}

		# If more than 25 daily HW values are missing per season, set nhw to NA (which propogates and makes all other aspects NA)
		# 25 is chosen to be greater than the climdex.pcic '15' since any missing values in the preceding 3 days for EHF/ECF calcs also translate into an NA value for EHF/ECF.
#		if(sum(is.na(extended_data[1:last_day_of_hw_season]))>25) { nhw = NA } else { nhw = length(truevals) }  # number of heatwaves
		nhw = length(truevals)

		if(!is.na(nhw) && nhw>0){
			hwm = array(NA,nhw)  # array to store heatwave mean temperature
			hwa = array(NA,nhw)
			for (i in 1:nhw) { # over each run
				if(truevals[i]==1) { i1 = 1 } else { i1 = cumsum(rle_extended_boolean$lengths)[truevals[i]-1] + 1 }      # "+1" to begin on day 1 of heat wave - not the last day of the non-heatwave
					i2 = cumsum(rle_extended_boolean$lengths)[truevals[i]]
					hwm[i] = mean(extended_data[i1:i2],na.rm=TRUE)
					if(ecf==TRUE) { hwa[i] = min(extended_data[i1:i2],na.rm=TRUE) } 
					else { hwa[i] = max(extended_data[i1:i2],na.rm=TRUE) }
			}
		} else { hwm = NA ; hwa = NA }
	
		hwm2 = mean(hwm,na.rm=TRUE)
		hwn = nhw
	
		# HWM
		if(is.nan(hwm2) || is.na(hwm2)) { aspect.array[1,aspect_ind] = NA } else { aspect.array[1,aspect_ind] = hwm2 }
		# HWA
		if(is.nan(hwm2) || is.na(hwm2)) { aspect.array[2,aspect_ind] = NA } else { if (ecf==TRUE) {aspect.array[2,aspect_ind] = hwa[which.min(hwm)] } else {aspect.array[2,aspect_ind] = hwa[which.max(hwm)] } }
		# HWN
		aspect.array[3,aspect_ind] = hwn
		# HWD
		if(is.nan(hwm2) || is.na(hwm2)) { aspect.array[4,aspect_ind] = NA } else { aspect.array[4,aspect_ind] = max(rle_extended_boolean$lengths[truevals],na.rm=TRUE) }
		# HWF
		if(is.na(hwn)) { aspect.array[5,aspect_ind] = NA } else { aspect.array[5,aspect_ind] = sum(rle_extended_boolean$lengths[truevals],na.rm=TRUE) }

		aspect_ind = aspect_ind + 1
	}

	aspect.array[2,] <- ifelse(aspect.array[2,]=="-Inf",NA,aspect.array[2,])
	aspect.array[4,] <- ifelse(aspect.array[4,]=="-Inf",NA,aspect.array[4,])

	# In the case where insufficient inbase data exists then no quantiles will be calculated and HWA, HWM and HWD will be all NA. Howevere, this results in all years reporting zero heatwaves when it should report NA.
	# The following line replaces HWF and HWN with NA values when all HWM values are NA. The plot and write functions subsequently deal appropriately with indices that contain all NA values (by not plotting them).
	if(all(is.na(aspect.array[1,]))) { aspect.array[3,]=aspect.array[3,NA] ; aspect.array[5,]=aspect.array[5,NA] }

	if (northern.hemisphere==FALSE) {
		if(ehf==TRUE && ehfdef=="NF13") { }	# If in southern hemisphere, remove last year since there is only half a summer (can risk removing 366 days since it won't infringe on the previous summer)
		else { aspect.array[,length(aspect.array[1,])] <- NA }
	}

	# apply na.mask to outgoing data
	aspect.array[1,] <- aspect.array[1,]*namask
	aspect.array[2,] <- aspect.array[2,]*namask
	aspect.array[3,] <- aspect.array[3,]*namask
	aspect.array[4,] <- aspect.array[4,]*namask
	aspect.array[5,] <- aspect.array[5,]*namask

	rm(summer_indices,extended_indices,extended_data,extended_boolean,rle_extended_boolean,truevals,nhw,hwm,hwa,hwm2,last_day_of_hw_season,extvals,daily.data.full,boolean.str.full,ehf,ecf)
	return(aspect.array)
}







###############################
# Due seemingly to a bug in R or improper handling in this code these functions are copied from climdex.pcic so that they can be properly referenced by workers when running in parallel.
# These are un modified.
get.na.mask <- function(x, f, threshold) {
  return(c(1, NA)[1 + as.numeric(tapply.fast(is.na(x), f, function(y) { return(sum(y) > threshold) } ))])
}

# unmodded
tapply.fast <- function (X, INDEX, FUN = NULL, ..., simplify = TRUE) {
  FUN <- if (!is.null(FUN))
    match.fun(FUN)

  if (length(INDEX) != length(X))
    stop("arguments must have same length")

  if (is.null(FUN))
    return(INDEX)

  namelist <- levels(INDEX)
  ans <- lapply(split(X, INDEX), FUN, ...)

  ans <- unlist(ans, recursive = FALSE)
  names(ans) <- levels(INDEX)
  return(ans)
}
