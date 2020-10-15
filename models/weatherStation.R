# weatherStation constructor
new_weatherStation <- function(name = character(), latitude = double(), longitude = double(), observations) {
    # basic type validation
  stopifnot(is.character(stationName))
  stopifnot(is.double(latitude))
  stopifnot(is.double(longitude))


  # create structure
  value <- structure(list(name = name,
                      latitude = latitude,
                      longitude = longitude,
                      observations = observations),
                      class = "weatherStation"
                    )
  return (value)
}

# weatherStation validator
validate_weatherStation <- function(s) {
  if(length(s$name) == 0) {
    stop("Name must not be empty.")
  }
  if (s$latitude > 90 || s$latitude < -90) {
    stop("Latitude must be between -90 and 90.", call. = FALSE)
  }
  if (s$longitude > 180 || s$longitude < -180) {
    stop("Longitude must be between -180 and 180", call. = FALSE)
  }
  return(s)
}

# Helper function for consumers
weatherStation <- function(name = character(),
                            latitude = double(),
                            longitude = double(),
                            observations) {
  latitude <- as.double(latitude)
  longitude <- as.double(longitude)
  s <- new_weatherStation(name, latitude, longitude, observations)
  validate_weatherStation(s)  
}