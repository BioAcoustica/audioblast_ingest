# Exports BioAcoustica's bibliography as references.csv for audioBlastIngest,
# from a copy of the bio.acousti.ca database. See export/common.R for how the
# database is found and how to run this.
source("export/common.R")

db <- bioacoustica()
references <- exported(db, "references")

#Files attached to references, as URLs separated by semicolons
files <- dbGetQuery(db, "
  SELECT ff.entity_id AS id, f.uri
  FROM field_data_field_file ff
  JOIN file_managed f ON f.fid = ff.field_file_fid
  WHERE ff.entity_type = 'node' AND ff.bundle = 'biblio' AND ff.deleted = 0
    AND ff.field_file_display = 1 AND f.uri LIKE 'public://%'
  ORDER BY ff.entity_id, ff.delta")
dbDisconnect(db)
urls <- tapply(fileURL(files$uri), files$id, paste, collapse="; ")
references$attachments <- unname(urls[as.character(references$id)])

write_export(references, "references.csv")
