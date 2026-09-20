# Exports links between BioAcoustica's records (references, taxa, recordings,
# traits and specimens) as links.csv for audioBlastIngest, from a copy of the
# bio.acousti.ca database. See export/common.R for how the database is found
# and how to run this. What a reference contains about a taxon (e.g. an
# oscillogram of it) and the topics of references are given as
# vocab.audioblast.org terms, which the script lists.
source("export/common.R")

content <- "https://vocab.audioblast.org/cv/referenceContent#"
topic <- "https://vocab.audioblast.org/cv/topic#"
interaction <- "https://vocab.audioblast.org/cv/interaction#"

#How one taxon interacts with another, for each of the site's Ecological
#Interactions terms that its interactions use. The rest of that vocabulary is
#the Relation Ontology's biotic interactions (eats, pollinates, is parasite of,
#parasitoid of, is vector for), which should take their RO IRIs when something
#uses them; these three are the site's own and have none.
interactions <- c(
  "acoustically-orientating predator of"="AcousticallyOrientatingPredatorOf",
  "acoustically-orientating parasite of"="AcousticallyOrientatingParasiteOf",
  "responds to alarm call of"="RespondsToAlarmCallOf")

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
lost <- lostTaxa(db)
#A species profile says which taxa it is about in a field, and cites its
#references in the text, so its links are read from the descriptions export
#rather than from links.sql
descriptions <- exported(db, "descriptions")
published <- dbGetQuery(db, "SELECT nid FROM node WHERE type = 'biblio' AND status = 1")$nid
dbDisconnect(db)

#One link for each taxon a description is about, and one for each reference it
#cites. A reference that is no longer published is left out.
describes <- strsplit(ifelse(is.na(descriptions$taxa), "", descriptions$taxa), ",", fixed=TRUE)
cited <- lapply(citations(descriptions$value), function(ids) intersect(ids, as.character(published)))
missing <- setdiff(unlist(citations(descriptions$value)), as.character(published))
if (length(missing) > 0) {
  message(length(missing), " citations name a reference that is not published, so are left out: ",
          paste(sort(unique(missing)), collapse=", "))
}
described <- function(ids, predicate, type) {
  return(data.frame(subject_type="descriptions", subject_id=rep(descriptions$id, lengths(ids)),
                    predicate=predicate, object_type=type, object_id=unlist(ids),
                    content=NA, topic=NA, remarks=NA, term=NA, reference=NA, interaction=NA,
                    stringsAsFactors=FALSE))
}
links <- rbind(links,
               described(describes, "http://purl.obolibrary.org/obo/IAO_0000136", "taxa"),
               described(cited, "http://purl.org/dc/terms/source", "references"))

unmapped <- setdiff(links$content[!is.na(links$content)], contents$tid)
if (length(unmapped) > 0) {
  stop("No term for the Biblio Contents terms ", paste(unmapped, collapse=", "))
}

#An interaction is the relationship itself, so its term is the predicate
acts <- !is.na(links$interaction)
unnamed <- setdiff(links$interaction[acts], names(interactions))
if (length(unnamed) > 0) {
  stop("No term for the interactions ", paste(unnamed, collapse=", "))
}
links$predicate[acts] <- paste0(interaction, interactions[links$interaction[acts]])

#A record that names a term which has since been deleted is left with no taxon
#to link it to, so the link is missing from links.csv altogether
if (nrow(lost) > 0) {
  message(nrow(lost), " records are of a term that is no longer in the classification, ",
          "so they are given no link to a taxon:")
  print(lost, row.names=FALSE)
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
#Links that name their own term, e.g. the references that treat a taxon
named <- !is.na(links$term)
links$qualifier[named] <- paste0(content, links$term[named])
on <- !is.na(links$topic)
links$object_id[on] <- paste0(topic, camel(topics$name[match(links$topic[on], topics$tid)]))

#Subjects and objects are all BioAcoustica's own, so their sources are left
#empty, and audioBlastIngest fills them in
links$subject_source <- ""
links$object_source <- ""
columns <- c("subject_type", "subject_source", "subject_id", "predicate",
             "object_type", "object_source", "object_id", "qualifier", "remarks",
             "reference")
links <- links[, columns]
links[] <- lapply(links, function(x) ifelse(is.na(x), "", trimws(as.character(x))))
links <- unique(links)
links <- links[order(links$subject_type, as.numeric(links$subject_id), links$predicate,
                     links$object_type, links$object_id, links$qualifier), ]

write_export(links, "links.csv")
print(as.data.frame(table(paste(links$subject_type, sub(".*[/#]", "", links$predicate), links$object_type)),
                    responseName="links"), row.names=FALSE)
message("vocab.audioblast.org terms used:")
terms <- sort(unique(c(links$qualifier, links$object_id[links$object_type == "term"],
                       links$predicate[startsWith(links$predicate, interaction)])))
writeLines(terms[terms != ""])
