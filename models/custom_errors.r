# Custom errors
stop_custom <- function(.subclass, message, call = NULL, ...) {
  err <- structure(
    list(
      message = message,
      call = call,
      ...
    ),
    class = c(.subclass, "error", "condition")
  )
  stop(err)
}

readUserFileError <- function(msg, cond, ...) {
  stop_custom("readUserFileError", msg, cond$call, ...)
}

# Usage
# err <- catch_cnd(
#   stop_custom("error_new", "This is a custom error", x = 10)
# )
# class(err)
# err$x
