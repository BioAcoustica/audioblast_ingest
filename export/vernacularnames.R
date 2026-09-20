# Exports BioAcoustica's vernacular names as vernacularnames.csv for
# audioBlastIngest, from a copy of the bio.acousti.ca database. See
# export/common.R for how the database is found and how to run this. The taxon
# each name is for, and the reference it was taken from, are in links.csv.
source("export/common.R")

db <- bioacoustica()
vernacular <- exported(db, "vernacularnames")
dbDisconnect(db)

#The language a name is in is the site's own field, which audioBlastIngest
#reads as a language tag. It was left empty for one batch of names: 215 bat
#names across eight families, and a frog and a bird, none of which cites a
#reference. Every one of them is English, and the site gives no other language
#for any of them, so they are given en here rather than left for a reader to
#guess at. No other source's blank language is filled in for it.
blank <- is.na(vernacular$language) | vernacular$language == ""
vernacular$language[blank] <- "en"
message(sum(blank), " names had no language of their own and are given en")

write_export(vernacular, "vernacularnames.csv")
counts <- sort(table(vernacular$language), decreasing=TRUE)
print(data.frame(language=names(counts), names=as.integer(counts)), row.names=FALSE)
