# Exports links between BioAcoustica's records (references, taxa, recordings
# and traits) as links.csv for audioBlastIngest, from a MariaDB (or MySQL)
# copy of the bio.acousti.ca database. Run it from the root of this
# repository:
#
#   Rscript export/links.R
#
# The database is found as export/references.R finds it. What a reference
# contains about a taxon (e.g. an oscillogram of it) and the topics of
# references are given as vocab.audioblast.org terms, which the script lists.
library(DBI)

content <- "https://vocab.audioblast.org/cv/referenceContent#"
topic <- "https://vocab.audioblast.org/cv/topic#"

#The term for what a reference contains about a taxon, for each of the site's
#Biblio Contents terms. A spectrogram of a call type gives the call type as
#the link's remarks. A reference that is only tagged with a taxon is about its
#acoustic behaviour.
contents <- data.frame(
  tid=c(6974, 6758, 7022, 7023, 7881, 6759, 6914, 6497, 6496, 6495, 6547, 7884,
        7001, 7004, 7002, 7003, 7940, 6616),
  term=c("Oscillogram", "Spectrogram", "Spectrogram", "Spectrogram", "Sonagram",
         "SongDescription", "StridulatoryApparatusDescription",
         "StridulatoryFilePhotograph", "StridulatoryFileSEMImage", "StridulatoryFileImage",
         "StridulatoryPositionPhotograph", "PlectrumPhotograph", "FemaleBehaviourDescription",
         "AcousticallyOrientatingPredatorDescription", "LaryngealMorphologyDescription",
         "LaryngealMorphologyImage", "FluidExpulsionDescription", "BurrowEntrancePhotograph"),
  remarks=c("", "", "Alarm Call", "Wing Whistle", rep("", 14)),
  stringsAsFactors=FALSE)
tagged <- "AcousticBehaviour"
#The reference that a taxon's Classification entry cites treats the taxon,
#whether or not it is the work that published its name
treatment <- "TaxonomicTreatment"

db <- dbConnect(RMariaDB::MariaDB(),
                host=Sys.getenv("BIOACOUSTICA_HOST", "127.0.0.1"),
                port=as.integer(Sys.getenv("BIOACOUSTICA_PORT", "3306")),
                user=Sys.getenv("BIOACOUSTICA_USER", "root"),
                password=Sys.getenv("BIOACOUSTICA_PASSWORD", ""),
                dbname=Sys.getenv("BIOACOUSTICA_DB", "bioacoustica"))
links <- dbGetQuery(db, paste(readLines("export/links.sql", encoding="UTF-8"), collapse="\n"))
topics <- dbGetQuery(db, "
  SELECT t.tid, t.name FROM taxonomy_term_data t
  JOIN taxonomy_vocabulary v ON v.vid = t.vid WHERE v.machine_name = 'non_bio'")
dbDisconnect(db)

unmapped <- setdiff(links$content[!is.na(links$content)], contents$tid)
if (length(unmapped) > 0) {
  stop("No term for the Biblio Contents terms ", paste(unmapped, collapse=", "))
}

#Topics are the site's Non-bio terms, named in UpperCamelCase, e.g. Marine
#Soundscapes is MarineSoundscapes
camel <- function(x) {
  return(vapply(strsplit(x, "[^A-Za-z0-9]+"), function(words) {
    words <- words[words != ""]
    return(paste0(toupper(substr(words, 1, 1)), substring(words, 2), collapse=""))
  }, character(1)))
}

links$qualifier <- NA_character_
links$qualifier[links$kind == "tagged"] <- paste0(content, tagged)
links$qualifier[links$kind == "classification"] <- paste0(content, treatment)
has <- !is.na(links$content)
row <- match(links$content[has], contents$tid)
links$qualifier[has] <- paste0(content, contents$term[row])
links$remarks[has] <- contents$remarks[row]
on <- !is.na(links$topic)
links$object_id[on] <- paste0(topic, camel(topics$name[match(links$topic[on], topics$tid)]))

#Subjects and objects are all BioAcoustica's own, so their sources are left
#empty, and audioBlastIngest fills them in
links$subject_source <- ""
links$object_source <- ""
columns <- c("subject_type", "subject_source", "subject_id", "predicate",
             "object_type", "object_source", "object_id", "qualifier", "remarks")
links <- links[, columns]
links[] <- lapply(links, function(x) ifelse(is.na(x), "", trimws(as.character(x))))
links <- unique(links)
links <- links[order(links$subject_type, as.numeric(links$subject_id), links$predicate,
                     links$object_type, links$object_id, links$qualifier), ]

#Every value is quoted, as in BioAcoustica's other exports
csv <- file("links.csv", "wb")
write.csv(links, csv, row.names=FALSE, eol="\r\n")
close(csv)

message(nrow(links), " links written to links.csv")
print(as.data.frame(table(paste(links$subject_type, sub(".*[/#]", "", links$predicate), links$object_type)),
                    responseName="links"), row.names=FALSE)
message("vocab.audioblast.org terms used:")
terms <- sort(unique(c(links$qualifier, links$object_id[links$object_type == "term"])))
writeLines(terms[terms != ""])
