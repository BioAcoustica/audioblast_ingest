# Exports links between BioAcoustica's records (references, taxa, recordings,
# traits and specimens) as links.csv for audioBlastIngest, from a copy of the
# bio.acousti.ca database. See export/common.R for how the database is found
# and how to run this. What a reference contains about a taxon (e.g. an
# oscillogram of it) and the topics of references are given as
# vocab.audioblast.org terms, which the script lists.
source("export/common.R")

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

db <- bioacoustica()
links <- exported(db, "links")
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
about <- links$subject_type == "references" & links$object_type == "taxa"
links$qualifier[about] <- paste0(content, tagged)
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

write_export(links, "links.csv")
print(as.data.frame(table(paste(links$subject_type, sub(".*[/#]", "", links$predicate), links$object_type)),
                    responseName="links"), row.names=FALSE)
message("vocab.audioblast.org terms used:")
terms <- sort(unique(c(links$qualifier, links$object_id[links$object_type == "term"])))
writeLines(terms[terms != ""])
