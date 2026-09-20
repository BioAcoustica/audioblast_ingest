# Exports BioAcoustica's classification as taxa.txt for audioBlastIngest, from
# a copy of the bio.acousti.ca database. See export/common.R for how the
# database is found and how to run this.
source("export/common.R")

db <- bioacoustica()
taxa <- exported(db, "taxa")
dbDisconnect(db)

#Names and their unit names are typed with stray tabs and double spaces, which
#is all that a term's name and its units differ by
tidy <- function(x) {
  return(gsub("\\s+", " ", trimws(x)))
}
columns <- c("taxon", "unit1", "unit2", "unit3", "unit4", "rank", "parent_taxon")
taxa[columns] <- lapply(taxa[columns], tidy)

parts <- lapply(taxa[c("unit1", "unit2", "unit3", "unit4")], function(x) ifelse(is.na(x), "", x))
units <- tidy(do.call(paste, c(parts, sep=" ")))
different <- units != taxa$taxon
if (any(different)) {
  message(sum(different), " taxa are named differently from their unit names:")
  print(utils::head(data.frame(id=taxa$id[different], taxon=taxa$taxon[different],
                               units=units[different]), 10), row.names=FALSE)
}

names(taxa) <- c("id", "taxon", "Unit name 1", "Unit name 2", "Unit name 3", "Unit name 4",
                 "Rank", "parent_id", "parent_taxon")
write_export(taxa, "taxa.txt")
counts <- sort(table(taxa$Rank), decreasing=TRUE)
print(data.frame(rank=names(counts), taxa=as.integer(counts)), row.names=FALSE)
