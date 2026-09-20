# Exports BioAcoustica's specimens and observations as specimens.csv for
# audioBlastIngest, from a copy of the bio.acousti.ca database. See
# export/common.R for how the database is found and how to run this.
source("export/common.R")

db <- bioacoustica()
specimens <- exported(db, "specimens")
dbDisconnect(db)

write_export(specimens, "specimens.csv")
