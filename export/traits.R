# Exports BioAcoustica's bioacoustic traits as traits.txt for audioBlastIngest,
# from a copy of the bio.acousti.ca database. See export/common.R for how the
# database is found and how to run this. Ontology links and sexes are repaired
# where the intent is beyond doubt, and whatever is left for a person to decide
# is listed.
source("export/common.R")

vocab <- "https://vocab.audioblast.org/"

#Sexes as they are typed on the site, and what they are
sexes <- c("male"="Male", "female"="Female", "Maleq"="Male", "Males"="Male",
           "Male;Female"="Male; Female")

db <- bioacoustica()
traits <- exported(db, "traits")
lost <- lostTaxa(db, "traits")
dbDisconnect(db)

#The site's ontology links are typed by hand, so a few name the vocabulary's
#host wrongly or reach it over http. The scheme and host are repaired; the term
#each one names is left alone.
link <- trimws(traits$ontology_link)
link[!is.na(link) & link == ""] <- NA
link <- sub("^https?://(voacb\\.audioblast\\.org|vocabaudioblast\\.org|vocab\\.audioblast\\.org)/",
            vocab, link)
traits$ontology_link <- link

#Links that still don't name a vocabulary term are left as they are: the terms
#they want don't exist yet, and inventing an IRI for them is not this script's
#to do (see docs/vocabulary-backlog.md in api.audioblast.org)
unknown <- !is.na(link) & (!startsWith(link, vocab) | grepl("%(?![0-9A-Fa-f]{2})", link, perl=TRUE))
if (any(unknown)) {
  counts <- sort(table(link[unknown]), decreasing=TRUE)
  message(sum(unknown), " trait values link to something that is not a vocabulary term:")
  print(data.frame(link=names(counts), values=as.integer(counts)), row.names=FALSE)
}

sex <- trimws(traits$sex)
known <- sex %in% names(sexes)
sex[known] <- unname(sexes[sex[known]])
odd <- !is.na(sex) & sex != "" & !sex %in% c("Male", "Female", "Male; Female")
if (any(odd)) {
  message(sum(odd), " trait values have a sex that is not male, female or both: ",
          paste0("\"", unique(sex[odd]), "\"", collapse=", "))
}
traits$sex <- sex

several <- traits$taxa > 1
if (any(several)) {
  message(sum(several), " trait values are of a node with several taxa, ",
          "whose other taxa are in links.csv")
}

#A trait value takes its name from the first taxon of its node and links.R
#gives every one of them, so a value whose node names a term that has since
#been deleted loses the name here, the link there, or both
if (nrow(lost) > 0) {
  message(nrow(lost), " trait values are of a term that is no longer in the ",
          "classification:")
  print(lost, row.names=FALSE)
}

traits$reference <- ""
columns <- c("traitID", "taxonID", "taxon", "trait", "ontology_link", "value", "call_type",
             "sex", "temperature", "reference", "cascade", "annotation_id")
traits <- traits[, columns]
names(traits) <- c("traitID", "taxonID", "Taxonomic name", "Trait", "Ontology Link", "Value",
                   "Call Type", "Sex", "Temperature", "Reference", "Cascade", "Annotation ID")

write_export(traits, "traits.txt")
counts <- sort(table(traits$Trait), decreasing=TRUE)
print(utils::head(data.frame(trait=names(counts), values=as.integer(counts)), 15), row.names=FALSE)
