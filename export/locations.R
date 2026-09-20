# Exports the places BioAcoustica's recordings were made and its specimens
# collected as locations.csv for audioBlastIngest, from a copy of the
# bio.acousti.ca database. See export/common.R for how the database is found
# and how to run this.
source("export/common.R")

db <- bioacoustica()
locations <- exported(db, "locations")
dbDisconnect(db)

#Names and the administrative units below them are typed by hand
columns <- c("name", "continent", "countryCode", "stateProvince", "county", "island",
             "islandGroup", "locality", "georeferenceRemarks", "geodeticDatum")
locations[columns] <- lapply(locations[columns], function(x) gsub("\\s+", " ", trimws(x)))

filled <- vapply(locations, function(x) sum(!is.na(x) & x != ""), integer(1))
print(data.frame(column=names(filled), places=as.integer(filled)), row.names=FALSE)

write_export(locations, "locations.csv")
counts <- sort(table(locations$countryCode[!is.na(locations$countryCode)]), decreasing=TRUE)
message("places by country:")
print(utils::head(data.frame(country=names(counts), places=as.integer(counts)), 10), row.names=FALSE)
