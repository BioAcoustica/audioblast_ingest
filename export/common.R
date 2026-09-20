# Shared by the exports from a MariaDB (or MySQL) copy of the bio.acousti.ca
# database, which each run their own SQL and write one file for
# audioBlastIngest. Run them from the root of this repository, e.g.
#
#   Rscript export/recordings.R
#
# The database is found with the environment variables BIOACOUSTICA_HOST
# (default 127.0.0.1), BIOACOUSTICA_PORT (3306), BIOACOUSTICA_USER (root),
# BIOACOUSTICA_PASSWORD (none) and BIOACOUSTICA_DB (bioacoustica).
library(DBI)

#Connects to the database
bioacoustica <- function() {
  db <- dbConnect(RMariaDB::MariaDB(),
                  host=Sys.getenv("BIOACOUSTICA_HOST", "127.0.0.1"),
                  port=as.integer(Sys.getenv("BIOACOUSTICA_PORT", "3306")),
                  user=Sys.getenv("BIOACOUSTICA_USER", "root"),
                  password=Sys.getenv("BIOACOUSTICA_PASSWORD", ""),
                  dbname=Sys.getenv("BIOACOUSTICA_DB", "bioacoustica"))
  #Lists, e.g. of a paper's authors, are longer than GROUP_CONCAT's 1024 bytes
  invisible(dbExecute(db, "SET SESSION group_concat_max_len = 1000000"))
  return(db)
}

#The rows that export/<name>.sql selects
exported <- function(db, name) {
  sql <- readLines(file.path("export", paste0(name, ".sql")), encoding="UTF-8")
  return(dbGetQuery(db, paste(sql, collapse="\n")))
}

#The records that have lost a taxon to a deleted term, as export/lost-taxa.sql
#finds them: the rows of one export where it is named, e.g. "specimens", and
#all of them where it is not
lostTaxa <- function(db, type=NULL) {
  lost <- exported(db, "lost-taxa")
  if (!is.null(type)) {
    lost <- lost[lost$type == type, c("id", "tid")]
  }
  return(lost)
}

#URLs of files held in Drupal's public file system, with the parts of their
#paths encoded as Drupal encodes them (e.g. a space is %20)
fileURL <- function(uri) {
  out <- rep(NA_character_, length(uri))
  public <- !is.na(uri) & startsWith(uri, "public://")
  paths <- vapply(strsplit(sub("^public://", "", uri[public]), "/", fixed=TRUE), function(parts) {
    return(paste(vapply(parts, URLencode, character(1), reserved=TRUE, repeated=TRUE), collapse="/"))
  }, character(1))
  out[public] <- paste0("https://bio.acousti.ca/sites/default/files/", paths)
  return(out)
}

#Writes the file that audioBlastIngest reads: every value quoted, as in
#BioAcoustica's other exports, with nothing for the values a record lacks
write_export <- function(data, file) {
  data[] <- lapply(data, function(x) ifelse(is.na(x), "", as.character(x)))
  csv <- file(file, "wb")
  write.csv(data, csv, row.names=FALSE, eol="\r\n")
  close(csv)
  message(nrow(data), " rows written to ", file)
}
