# Exports everything else that BioAcoustica's recordings and specimens hold as
# details.csv for audioBlastIngest, from a copy of the bio.acousti.ca
# database. See export/common.R for how the database is found and how to run
# this.
source("export/common.R")

db <- bioacoustica()
details <- exported(db, "details")
dbDisconnect(db)

#Scans of the original metadata and traces are given as URLs
scan <- startsWith(details$value, "public://")
details$value[scan] <- fileURL(details$value[scan])

write_export(details, "details.csv")
counts <- sort(table(details$name), decreasing=TRUE)
print(data.frame(name=names(counts), details=as.integer(counts)), row.names=FALSE)
