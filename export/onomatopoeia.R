# Exports BioAcoustica's onomatopoeia and imitations as onomatopoeia.csv for
# audioBlastIngest, from a copy of the bio.acousti.ca database. See
# export/common.R for how the database is found and how to run this. The taxon
# whose sound each renders, and the reference it was taken from, are in
# links.csv.
source("export/common.R")

#What the site writes in a rendering's body, and the column each of those
#sentences belongs in. The body is the only place these are recorded: the site
#has no field for the sex or life stage a rendering is of, nor for the people
#who use it. Nine renderings have one, so they are read out by the sentence
#they are written as rather than by a pattern; anything else a body says is
#kept as remarks, and is reported here so that a sentence added later is
#noticed rather than silently filed as a remark.
#
#"US English" is the language of that rendering rather than a remark about it:
#arf-arf is given en by the site, and en-US is what the body says it is.
#"Lokele tribe of the Congo" names the people who use a rendering, which is
#what locality holds. It is not read as a language: the site left the language
#of both empty, Lokele is not a name ISO 639-3 or Glottolog registers, and the
#people are not the language. A language is never guessed here.
said <- data.frame(
  text=c("Male (cockerel)",
         "Ususally applies to juveniles (puppies)",
         "US English",
         "Lokele tribe of the Congo"),
  column=c("sex", "lifeStage", "language", "locality"),
  value=c("male", "juvenile", "en-US", "Lokele tribe of the Congo"),
  stringsAsFactors=FALSE)

#The sentences of a body, which the site writes as paragraphs of HTML
statements <- function(body) {
  text <- ifelse(is.na(body), "", body)
  text <- gsub("</p>", "\n", text, fixed=TRUE)
  text <- gsub("<br />", "\n", text, fixed=TRUE)
  text <- gsub("<[^>]*>", "", text)
  text <- gsub("&nbsp;", " ", text, fixed=TRUE)
  text <- gsub("&amp;", "&", text, fixed=TRUE)
  return(lapply(strsplit(text, "\n", fixed=TRUE), function(lines) {
    lines <- trimws(gsub("[[:space:]]+", " ", lines))
    return(lines[lines != ""])
  }))
}

#A language tag as IETF BCP 47 writes one: the language in lower case, a script
#in title case and a region in upper case, e.g. en-gb is en-GB. Case does not
#change which language a tag means, so this only makes the column consistent
#with itself; a tag this does not recognise is left as the site wrote it.
bcp47 <- function(tag) {
  return(vapply(tag, function(one) {
    if (is.na(one) || one == "") {return(NA_character_)}
    parts <- strsplit(one, "-", fixed=TRUE)[[1]]
    parts[1] <- tolower(parts[1])
    for (i in seq_along(parts)[-1]) {
      if (grepl("^[A-Za-z]{4}$", parts[i])) {
        parts[i] <- paste0(toupper(substr(parts[i], 1, 1)), tolower(substring(parts[i], 2)))
      } else if (grepl("^([A-Za-z]{2}|[0-9]{3})$", parts[i])) {
        parts[i] <- toupper(parts[i])
      }
    }
    return(paste(parts, collapse="-"))
  }, character(1), USE.NAMES=FALSE))
}

db <- bioacoustica()
onomatopoeia <- exported(db, "onomatopoeia")
dbDisconnect(db)

onomatopoeia$sex <- NA_character_
onomatopoeia$lifeStage <- NA_character_
onomatopoeia$locality <- NA_character_
onomatopoeia$remarks <- NA_character_

unknown <- character(0)
lines <- statements(onomatopoeia$body)
for (i in seq_len(nrow(onomatopoeia))) {
  kept <- character(0)
  for (line in lines[[i]]) {
    row <- match(line, said$text)
    if (is.na(row)) {
      unknown <- c(unknown, line)
      kept <- c(kept, line)
    } else {
      onomatopoeia[[said$column[row]]][i] <- said$value[row]
    }
  }
  if (length(kept) > 0) {onomatopoeia$remarks[i] <- paste(kept, collapse="; ")}
}
if (length(unknown) > 0) {
  message(length(unknown), " sentences have no column of their own and are kept as remarks:")
  writeLines(paste0("  ", sort(unique(unknown))))
}

onomatopoeia$language <- bcp47(onomatopoeia$language)

onomatopoeia <- onomatopoeia[, c("id", "word", "kind", "language", "sex",
                                 "lifeStage", "locality", "remarks", "info_url")]
write_export(onomatopoeia, "onomatopoeia.csv")

counts <- sort(table(onomatopoeia$kind), decreasing=TRUE)
print(data.frame(kind=names(counts), renderings=as.integer(counts)), row.names=FALSE)
languages <- onomatopoeia$language
languages[is.na(languages)] <- "(none)"
counts <- sort(table(languages), decreasing=TRUE)
print(data.frame(language=names(counts), renderings=as.integer(counts)), row.names=FALSE)
message(sum(is.na(onomatopoeia$language)), " renderings have no language, which is left for the site to say")
