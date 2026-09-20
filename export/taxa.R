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

units <- do.call(cbind, lapply(taxa[c("unit1", "unit2", "unit3", "unit4")],
                               function(x) ifelse(is.na(x), "", x)))
joined <- tidy(apply(units, 1, paste, collapse=" "))

#A name is held as up to four units, and the term's own name is those units
#joined with spaces. That leaves a subgenus bare -- Mus Mus musculus -- which
#is not how a name is written and not a name anyone can match. The zoological
#code puts a subgenus in parentheses between the genus and the species epithet,
#so Mus (Mus) musculus.
#
#Which unit is the subgenus follows from the rank and the number of units: a
#species written with three has one, and a subspecies written with four has
#one. A species written with two units, a subspecies with three, and every name
#of a higher rank have no subgenus and are left alone, as are the species that
#are a single quoted name ("asphalt cicada"), of which bio.acousti.ca has 78.
#
#A taxon whose rank disagrees with the units it is written with keeps its name
#as it is rather than being guessed at: the rank is what says which unit is
#which, so a wrong rank cannot be read around. Those are reported here to be
#corrected at bio.acousti.ca.
#A taxon the site gives no rank for is left alone as well, as there is nothing
#to read the units by
rank <- ifelse(is.na(taxa$rank), "", taxa$rank)
subgenus <- function(units, rank) {
  n <- rowSums(units != "")
  return((rank == "Species" & n == 3) | (rank == "Subspecies" & n == 4))
}
has <- subgenus(units, rank)
bracketed <- units
bracketed[has, 2] <- paste0("(", units[has, 2], ")")
named <- tidy(apply(bracketed, 1, paste, collapse=" "))

message(sum(has), " taxa are written with a subgenus, which is now in parentheses, e.g. ",
        paste(utils::head(named[has], 3), collapse="; "))

#A rank that disagrees with the units is a rank to correct at the site: a
#species cannot be written with four units, nor a genus with more than one.
wrongRank <- function(units, rank) {
  n <- rowSums(units != "")
  return((rank == "Species" & n > 3) | (rank == "Subspecies" & n > 4) |
         (rank != "" & !rank %in% c("Species", "Subspecies") & n > 1))
}
wrong <- wrongRank(units, rank)
if (any(wrong)) {
  message(sum(wrong), " taxa have a rank that does not match the units they are written with, ",
          "so their names are left as the site gives them:")
  print(data.frame(id=taxa$id[wrong], rank=taxa$rank[wrong], taxon=taxa$taxon[wrong],
                   units=joined[wrong]), row.names=FALSE)
}

#The term's own name should be its units joined, give or take the whitespace
#tidied above; one that isn't is the site's to look at
different <- joined != taxa$taxon
if (any(different)) {
  message(sum(different), " taxa are named differently from their unit names:")
  print(utils::head(data.frame(id=taxa$id[different], taxon=taxa$taxon[different],
                               units=joined[different]), 10), row.names=FALSE)
}

taxa$taxon <- named
#A parent is named as it names itself, so a child of Mus (Mus) musculus does
#not say its parent is Mus Mus musculus
#Ids are looked up by name, so they are matched as text: a root's parent is 0,
#which as a number would be no position at all rather than no parent
taxa$parent_taxon <- unname(setNames(named, as.character(taxa$id))[as.character(taxa$parent_id)])

names(taxa) <- c("id", "taxon", "Unit name 1", "Unit name 2", "Unit name 3", "Unit name 4",
                 "Rank", "parent_id", "parent_taxon")
write_export(taxa, "taxa.txt")
counts <- sort(table(taxa$Rank), decreasing=TRUE)
print(data.frame(rank=names(counts), taxa=as.integer(counts)), row.names=FALSE)
