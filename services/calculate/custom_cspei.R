# Computation of the Standardized Precipitation-Evapotranspiration Index (SPEI).
# Generic function
cspei <- function(x, y, ...) UseMethod('cspei')

# Fit SPEI.
cspei <- function(data, scale, kernel = list(type = 'rectangular', shift = 0),
  distribution = 'log-Logistic', fit = 'ub-pwm', na.rm = FALSE,
  ref.start = NULL, ref.end = NULL, x = FALSE, ...) {
  scale <- as.numeric(scale)
  na.rm <- as.logical(na.rm)
  x <- as.logical(x)
  #if (!exists("data",inherits=F) | !exists("scale",inherits=F)) {
  #	stop('Both data and scale must be provided')
  #}
  if (sum(is.na(data)) > 0 & na.rm == FALSE) {
    stop('Error: Data must not contain NAs')
  }
  if (distribution != 'log-Logistic' & distribution != 'Gamma' & distribution != 'PearsonIII') {
    stop('Distrib must be one of "log-Logistic", "Gamma" or "PearsonIII"')
  }
  if (fit != 'max-lik' & fit != 'ub-pwm' & fit != 'pp-pwm') {
    stop('Method must be one of "ub-pwm" (default), "pp-pwm" or "max-lik"')
  }
  if ({!is.null(ref.start) & length(ref.start) != 2 } | {!is.null(ref.end) & length(ref.end) != 2 }) {
    stop('Start and end of the reference period must be a numeric vector of length two.')
  }
  if (!is.ts(data)) {
    data <- ts(as.matrix(data), frequency = 12)
  } else {
    data <- ts(as.matrix(data), frequency = frequency(data), start = start(data))
  }
  m <- ncol(data)
  fr <- frequency(data)

  if (distribution == 'Gamma') {
    coef <- array(NA, c(2, m, fr), list(par = c('alpha', 'beta'), colnames(data), NULL))
  }
  if (distribution == 'log-Logistic') {
    coef <- array(NA, c(3, m, fr), list(par = c('xi', 'alpha', 'kappa'), colnames(data), NULL))
  }
  if (distribution == 'PearsonIII') {
    coef <- array(NA, c(3, m, fr), list(par = c('mu', 'sigma', 'gamma'), colnames(data), NULL))
  }

  # Loop through series (columns in data)
  if (!is.null(ref.start) & !is.null(ref.end)) {
    data.fit <- window(data, ref.start, ref.end)
  } else {
    data.fit <- data
  }
  std <- data * NA
  for (s in 1:m) {
    # Cumulative series (acu)
    acu <- data.fit[, s] * NA
    acu.pred <- std[, s]
    if (scale > 1) {
      wgt <- kern(scale, kernel$type, kernel$shift)
      for (t in scale:length(acu)) {
        acu[t] <- sum(data.fit[t:{ t - scale + 1 }, s] * wgt)
      }
      # next t
      for (t in scale:length(acu.pred)) {
        acu.pred[t] <- sum(data[t:{ t - scale + 1 }, s] * wgt)
      }
      # next t
    } else {
      acu <- data.fit[, s]
      acu.pred <- data[, s]
    }

    # Loop through the months
    for (c in (1:fr)) {
      # Filter month m, excluding NAs
      f <- seq(c, length(acu), fr)
      f <- f[!is.na(acu[f])]
      ff <- seq(c, length(acu.pred), fr)
      ff <- ff[!is.na(acu.pred[ff])]


      # Monthly series, sorted
      month <- sort(acu[f])

      if (length(month) == 0 | is.na(sd(month, na.rm = TRUE))) {
        std[f] <- NA
        next ()
      }

      if (fit == 'pp-pwm') {
        pwm <- pwm.pp(month, -0.35, 0)
      } else {
        pwm <- pwm.ub(month)
      }
      lmom <- pwm2lmom(pwm)
      if (!are.lmom.valid(lmom) | is.nan(sum(lmom[[1]]))) {
        next ()
      }

      if (distribution == 'log-Logistic') {
        # Fit a generalized log-Logistic distribution
        llpar <- parglo(lmom)
        if (fit == 'max-lik') {
          llpar <- parglo.maxlik(month, llpar$para)
        }
        # Compute standardized values
        std[ff, s] <- qnorm(pglo(acu.pred[ff], llpar))
        coef[, s, c] <- llpar$para
      } else {
        # Probability of monthly precipitation = 0 (pze)
        zeros <- sum(month == 0)
        pze <- sum(month == 0) / length(month)
        # 				month <- sort(month)
        if (distribution == 'Gamma') {
          # Fit a Gamma distribution
          gampar <- pargam(lmom.ub(month))
          # Compute standardized values
          std[ff, s] <- qnorm(cdfgam(acu.pred[ff], gampar))
          std[ff, s] <- qnorm(pze + (1 - pze) * pnorm(std[ff, s]))
          coef[, s, c] <- gampar$para
        } else if (distribution == 'PearsonIII') {
          # Fit a PearsonIII distribution
          p3par <- parpe3(lmom.ub(month))
          # Compute standardized values
          std[ff, s] <- qnorm(cdfpe3(acu.pred[ff], p3par))
          std[ff, s] <- qnorm(pze + (1 - pze) * pnorm(std[ff, s]))
          coef[, s, c] <- parpe3$para
        }
        # end if
      }
      # end if
    }
    # next c (month)
  }
  # next s (series)
  colnames(std) <- colnames(data)

  z <- list(call = match.call(expand.dots = FALSE),
    fitted = std, coefficients = coef, scale = scale, kernel = list(type = kernel$type,
    shift = kernel$shift, values = kern(scale, kernel$type, kernel$shift)),
    distribution = distribution, fit = fit, na.action = na.rm)
  if (x) z$data <- data
  if (!is.null(ref.start)) z$ref.period <- rbind(ref.start, ref.end)

  class(z) <- 'spei'
  return(z)
}
