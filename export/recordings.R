# Exports BioAcoustica's recordings as recordings.csv for audioBlastIngest,
# from a copy of the bio.acousti.ca database. See export/common.R for how the
# database is found and how to run this.
source("export/common.R")

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
lost <- lostTaxa(db, "recordings")
dbDisconnect(db)

#A recording of a term that has since been deleted has nothing to take a name
#from, so its taxon is empty here and links.R gives it no taxon
if (nrow(lost) > 0) {
  message(nrow(lost), " recordings are of a term that is no longer in the ",
          "classification:")
  print(lost, row.names=FALSE)
}

recordings$file <- fileURL(recordings$file)
recordings$size <- humanSize(recordings$size_raw)
#The site's time zone, as the dates a recording was uploaded were shown in
recordings$post_date <- format(as.POSIXct(recordings$post_date, origin="1970-01-01", tz="UTC"),
                               "%Y-%m-%d %H:%M", tz="Europe/London")
recordings$license <- ccLicence(recordings$license)

write_export(recordings, "recordings.csv")
