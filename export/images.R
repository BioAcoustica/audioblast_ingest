# Exports BioAcoustica's images as images.csv for audioBlastIngest, from a
# copy of the bio.acousti.ca database. See export/common.R for how the
# database is found and how to run this. What each image shows is links, which
# links.R exports.
source("export/common.R")

db <- bioacoustica()
images <- exported(db, "images")
dbDisconnect(db)

images$file <- fileURL(images$file)
images$license <- ccLicence(images$license)
#The site's time zone, as the dates a file was uploaded were shown in
images$post_date <- format(as.POSIXct(images$post_date, origin="1970-01-01", tz="UTC"),
                           "%Y-%m-%d %H:%M", tz="Europe/London")
#Titles are typed by hand, and a figure's is its legend
images$title <- gsub("\\s+", " ", trimws(images$title))

write_export(images, "images.csv")
filled <- vapply(images, function(x) sum(!is.na(x) & x != ""), integer(1))
print(data.frame(column=names(filled), images=as.integer(filled)), row.names=FALSE)
counts <- sort(table(images$subtype[!is.na(images$subtype)]), decreasing=TRUE)
message("images by kind:")
print(data.frame(subtype=names(counts), images=as.integer(counts)), row.names=FALSE)
unlicensed <- sum(is.na(images$license))
if (unlicensed > 0) {
  message(unlicensed, " images say no licence, so audioBLAST! gives none for them")
}
