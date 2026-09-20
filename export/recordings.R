# Exports BioAcoustica's recordings as recordings.csv for audioBlastIngest,
# from a copy of the bio.acousti.ca database. See export/common.R for how the
# database is found and how to run this.
source("export/common.R")

#The licence of each of the Creative Commons module's licence types (see
#creative_commons.module in Scratchpads). Type 1 is no licence, which is left
#empty, and the site gives the licences in their 4.0 version.
licences <- c(
  "2"="by", "3"="by-sa", "4"="by-nd", "5"="by-nc", "6"="by-nc-sa", "7"="by-nc-nd")
public <- c("8"="publicdomain/zero/1.0", "9"="publicdomain/mark/1.0")

#Sizes as Drupal writes them, e.g. 1069487 bytes is "1.02 MB". Halves are
#rounded up, as PHP rounds them, so that 4.125 MB is 4.13 MB.
humanSize <- function(bytes) {
  units <- c("bytes", "KB", "MB", "GB", "TB", "PB")
  round2 <- function(x) floor(x * 100 + 0.5) / 100
  size <- as.numeric(bytes)
  unit <- rep(1, length(size))
  for (i in seq_along(units)[-1]) {
    bigger <- !is.na(size) & round2(size) >= 1024
    size[bigger] <- size[bigger] / 1024
    unit[bigger] <- i
  }
  return(ifelse(is.na(size), NA_character_, paste(round2(size), units[unit])))
}

db <- bioacoustica()
recordings <- exported(db, "recordings")
dbDisconnect(db)

recordings$file <- fileURL(recordings$file)
recordings$size <- humanSize(recordings$size_raw)
#The site's time zone, as the dates a recording was uploaded were shown in
recordings$post_date <- format(as.POSIXct(recordings$post_date, origin="1970-01-01", tz="UTC"),
                               "%Y-%m-%d %H:%M", tz="Europe/London")
licence <- as.character(recordings$license)
recordings$license <- ifelse(licence %in% names(licences),
                             paste0("https://creativecommons.org/licenses/", licences[licence], "/4.0/"),
                             ifelse(licence %in% names(public),
                                    paste0("https://creativecommons.org/", public[licence], "/"), NA))

write_export(recordings, "recordings.csv")
