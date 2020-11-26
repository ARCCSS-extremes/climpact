#' climpactUI constructor
#'
#' new_climpactUI isn't intended for external use.
#' Instead, use @seealso [climpactUI()] which will validate arguments.
#'
#' climpactUI is a bit of a catch-all class, that provides dependencies to modules
#' and functions as we refactor climpact.
#' climpactUI is a strong candidate for refactoring
#' to split out behaviour and attributes into more coherent parts.
#'
new_climpactUI <- function(ns = character(),
                          userGuideLink = character(),
                          appendixBLink = character(),
                          sampleText = character()) {
  # basic type validation
  stopifnot(is.character(ns))
  stopifnot(is.character(userGuideLink))
  stopifnot(is.character(appendixBLink))
  stopifnot(is.character(sampleText))

  # create structure
  value <- structure(list(ns = ns,
                          userGuideLink = userGuideLink,
                          appendixBLink = appendixBLink,
                          sampleText = sampleText),
                      class = "climpactUI"
                    )
  return (value)
}

# climpactUI validator
validate_climpactUI <- function(s) {
  if(length(s$ns) == 0) {
    stop("ns must not be empty.")
  }
  return(s)
}

# Helper function for consumers
climpactUI <- function(ns = character(),
                      userGuideLink = character(),
                      appendixBLink = character()) {
  if (length(ns) == 0) {
    ns <- "ui"
  }
  if (length(userGuideLink) == 0) {
    userGuideLink <- "<a target=\"_blank\" href=user_guide/Climpact_user_guide.html>Climpact User Guide</a>"
  }
  if (length(appendixBLink) == 0) {
    appendixBLink <- "<a target=\"_blank\" href=user_guide/Climpact_user_guide.html#appendixb>Appendix B</a>"
  }
  sampleText <- paste0("The dataset <strong>must</strong> use the format described in ",
                appendixBLink, " of the ", userGuideLink, ".",
                "<br />",
                "For a sample dataset look at ")

  s <- new_climpactUI(ns, userGuideLink, appendixBLink, sampleText)
  validate_climpactUI(s)
}
