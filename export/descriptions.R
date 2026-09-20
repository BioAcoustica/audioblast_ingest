# Exports what BioAcoustica's species profiles say about taxa as
# descriptions.csv for audioBlastIngest, from a copy of the bio.acousti.ca
# database. See export/common.R for how the database is found and how to run
# this. The taxa a description is about and the references it cites are links
# (see export/links.R), so they are not columns here.
source("export/common.R")

db <- bioacoustica()
descriptions <- exported(db, "descriptions")
dbDisconnect(db)

#[bib]12290[/bib] is how the site cites a reference in text. links.R makes a
#link of each; what is left is the sentence without them, so the brackets that
#held them go too.
descriptions$value <- citationsOut(descriptions$value)

descriptions <- descriptions[, c("id", "topic", "value", "info_url")]
write_export(descriptions, "descriptions.csv")
counts <- sort(table(descriptions$topic), decreasing=TRUE)
print(data.frame(topic=names(counts), descriptions=as.integer(counts)), row.names=FALSE)
message(length(unique(sub("[.].*", "", descriptions$id))), " species profiles, ",
        nrow(descriptions), " descriptions, ",
        max(nchar(descriptions$value)), " characters at the longest")
