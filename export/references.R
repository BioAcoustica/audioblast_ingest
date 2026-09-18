# Exports BioAcoustica's bibliography as references.csv for audioBlastIngest,
# from a MariaDB (or MySQL) copy of the bio.acousti.ca database. Run it from
# the root of this repository:
#
#   Rscript export/references.R
#
# The database is found with the environment variables BIOACOUSTICA_HOST
# (default 127.0.0.1), BIOACOUSTICA_PORT (3306), BIOACOUSTICA_USER (root),
# BIOACOUSTICA_PASSWORD (none) and BIOACOUSTICA_DB (bioacoustica).
library(DBI)

db <- dbConnect(RMariaDB::MariaDB(),
                host=Sys.getenv("BIOACOUSTICA_HOST", "127.0.0.1"),
                port=as.integer(Sys.getenv("BIOACOUSTICA_PORT", "3306")),
                user=Sys.getenv("BIOACOUSTICA_USER", "root"),
                password=Sys.getenv("BIOACOUSTICA_PASSWORD", ""),
                dbname=Sys.getenv("BIOACOUSTICA_DB", "bioacoustica"))
#Lists of authors can be longer than GROUP_CONCAT's default of 1024 bytes
invisible(dbExecute(db, "SET SESSION group_concat_max_len = 1000000"))
sql <- paste(readLines("export/references.sql", encoding="UTF-8"), collapse="\n")
references <- dbGetQuery(db, sql)

#Files attached to references, as URLs with the parts of their paths encoded
#as Drupal encodes them (e.g. a space is %20), separated by semicolons
files <- dbGetQuery(db, "
  SELECT ff.entity_id AS id, f.uri
  FROM field_data_field_file ff
  JOIN file_managed f ON f.fid = ff.field_file_fid
  WHERE ff.entity_type = 'node' AND ff.bundle = 'biblio' AND ff.deleted = 0
    AND ff.field_file_display = 1 AND f.uri LIKE 'public://%'
  ORDER BY ff.entity_id, ff.delta")
dbDisconnect(db)
paths <- vapply(strsplit(sub("^public://", "", files$uri), "/", fixed=TRUE), function(parts) {
  return(paste(vapply(parts, URLencode, character(1), reserved=TRUE, repeated=TRUE), collapse="/"))
}, character(1))
urls <- tapply(paste0("https://bio.acousti.ca/sites/default/files/", paths), files$id, paste, collapse="; ")
references$attachments <- unname(urls[as.character(references$id)])

#Every value is quoted, as in BioAcoustica's other exports, and NULL is empty
references[] <- lapply(references, function(x) ifelse(is.na(x), "", as.character(x)))
csv <- file("references.csv", "wb")
write.csv(references, csv, row.names=FALSE, eol="\r\n")
close(csv)
message(nrow(references), " references written to references.csv")
