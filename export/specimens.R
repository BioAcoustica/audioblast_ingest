# Exports BioAcoustica's specimens and observations as specimens.csv for
# audioBlastIngest, from a copy of the bio.acousti.ca database. See
# export/common.R for how the database is found and how to run this.
source("export/common.R")

db <- bioacoustica()
specimens <- exported(db, "specimens")
lost <- lostTaxa(db, "specimens")
dbDisconnect(db)

#A specimen identified as a term that has since been deleted keeps the term id
#on the site but has nothing to take a name from, so its scientificName is
#empty here and links.R gives it no taxon
if (nrow(lost) > 0) {
  message(nrow(lost), " specimens are identified as a term that is no longer in the ",
          "classification:")
  print(lost, row.names=FALSE)
}

write_export(specimens, "specimens.csv")
