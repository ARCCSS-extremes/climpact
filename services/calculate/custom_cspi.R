# Generic function
cspi <- function(x, y, ...) UseMethod('cspi')

# Fit SPI (previously spi() function). Default method.
cspi <- function(data, scale, kernel = list(type = 'rectangular', shift = 0),
  distribution = 'Gamma', fit = 'ub-pwm', na.rm = TRUE,
  ref.start = NULL, ref.end = NULL, x = FALSE, ...) {
  return(cspei(data, scale, kernel, distribution, fit, na.rm,
  ref.start, ref.end, x))
}
