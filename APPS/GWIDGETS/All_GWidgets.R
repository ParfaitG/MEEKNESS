
setwd("/path/to/working/directory")

dbs <- c("Oracle", "DB2", "SQLServer", "Postgres", "MySQL", "SQLite", "Mongo")

for (i in dbs) {
   system(paste0("Rscript ", getwd(), "/", i, "_GWidgets.R"), wait=FALSE)
   Sys.sleep(5)
}
