#' climdexInputParams constructor
#' 
#' new_climdexInputParams isn't intended for external use.
#' Instead, use @seealso [climdexInputParams()] which will validate arguments.
#' 
new_climdexInputParams <- function(wsdi_ud = double(),
                                    csdi_ud = double(),
                                    rx_ud = double(),
                                    txtn_ud = double(),
                                    rnnmm_ud = double(),
                                    Tb_HDD = double(),
                                    Tb_CDD = double(),
                                    Tb_GDD = double(),
                                    custom_SPEI = double(),
                                    var.choice = character(),
                                    op.choice = character(),
                                    constant.choice = double()) {
  # basic type validation
  stopifnot(is.double(wsdi_ud))
  stopifnot(is.double(csdi_ud))
  stopifnot(is.double(rx_ud))
  stopifnot(is.double(txtn_ud))
  stopifnot(is.double(rnnmm_ud))
  stopifnot(is.double(Tb_HDD))
  stopifnot(is.double(Tb_CDD))
  stopifnot(is.double(Tb_GDD))
  stopifnot(is.double(custom_SPEI))
  stopifnot(is.character(var.choice))
  stopifnot(is.character(op.choice))
  stopifnot(is.numeric(constant.choice))

  value <- structure(list(wsdi_ud = wsdi_ud,
                          csdi_ud = csdi_ud,
                          rx_ud = rx_ud,
                          txtn_ud = txtn_ud,
                          rnnmm_ud = rnnmm_ud,
                          Tb_HDD = Tb_HDD,
                          Tb_CDD = Tb_CDD,
                          Tb_GDD = Tb_GDD,
                          custom_SPEI = custom_SPEI,
                          var.choice = var.choice,
                          op.choice = op.choice,
                          constant.choice = constant.choice
                      ),
                      class = "climdexInputParams"
                    )
  return(value)
}

#' climdexInputParams validator
#'
#' This function will be called by @seealso [climdexInputParams()] 
#' when creating a new climdexInputParams.
#'
#' Checks that request attributes are valid.
#' @param r A climdexInputParams to validate
#'
#' @return If all attributes are valid, the climdexInputParams is returned.
#' Otherwise an error is returned describing the problem with validation.
validate_climdexInputParams <- function(r) {
  message <- ""
  if ((p$wsdi_ud < 1)  || (p$wsdi_ud > 10)) {
    message <- "WSDId: value must be between 1 and 10"
  }
  if ((p$csdi_ud < 1)  || (p$csdi_ud > 10)) {
    message <- paste(message, "CSDId value must be between 1 and 10", sep = "\n")
  }
  if (p$rx_ud < 1) {
    message <- paste(message, "RXnDAY: value must be a positive number", sep = "\n")
  }
  if (p$txtn_ud < 1) {
    message <- paste(message, "TXdTNd and TXbdTNbd: value must be a positive number", sep = "\n")
  }
  if (p$rnnmm_ud < 0) {
    message <- paste(message, "Rnnmm: value must be greater than or equal to zero", sep = "\n")
  }
  if (p$custom_SPEI < 1) {
    message <- paste(message, "Custom SPEI/SPI time scale value must be a positive number", sep = "\n")
  }
  if (message != "") {
    stop(message)
  }
  return(r)
}


#' climdexInputParams constructor for consumers
#' 
#' Creates a new climdexInputParams and validates all attributes are valid.
#' 
#' @param   wsdi_ud         double 
#' @param   csdi_ud         double 
#' @param   rx_ud           double 
#' @param   txtn_ud         double 
#' @param   rnnmm_ud         double 
#' @param   Tb_HDD          double 
#' @param   Tb_CDD          double 
#' @param   Tb_GDD          double 
#' @param   custom_SPEI     double 
#' @param   var.choice      character
#' @param   op.choice       character
#' @param   constant.choice double
#' 
#' @return  A climdexInputParams object if all attributes are valid or otherwise, executes error action.
climdexInputParams <- function(wsdi_ud = double(),
                                csdi_ud = double(),
                                rx_ud = double(),
                                txtn_ud = double(),
                                rnnmm_ud = double(),
                                Tb_HDD = double(),
                                Tb_CDD = double(),
                                Tb_GDD = double(),
                                custom_SPEI = double(),
                                var.choice = "",
                                op.choice = "",
                                constant.choice = double()) {
  wsdi_ud <- as.double(wsdi_ud)
  csdi_ud <- as.double(csdi_ud)
  rx_ud <- as.double(rx_ud)
  txtn_ud <- as.double(txtn_ud)
  rnnmm_ud <- as.double(rnnmm_ud)
  Tb_HDD <- as.double(Tb_HDD)
  Tb_CDD <- as.double(Tb_CDD)
  Tb_GDD <- as.double(Tb_GDD)
  custom_SPEI <- as.double(custom_SPEI)

  p <- new_climdexInputParams(wsdi_ud, csdi_ud, rx_ud, 
                              txtn_ud, rnnmm_ud, 
                              Tb_HDD, Tb_CDD, Tb_GDD, 
                              custom_SPEI, 
                              var.choice, op.choice, constant.choice)
  validate_climdexInputParams(p) 
}