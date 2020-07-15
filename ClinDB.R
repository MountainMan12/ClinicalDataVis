library(data.table)
library(TCGAbiolinks)
library(regexPipes)
library(tidyverse)
library(RSQLite)

project_id <- TCGAbiolinks::getGDCprojects()$project_id %>%
  regexPipes::grep("TCGA", value = T) 

clinical <- vector(mode = "list", length = length(project_id))
j <- 1
for (i in project_id) {
  clinical[[j]] <- GDCquery_clinic(project = i, type = "clinical")
  j <- j + 1
}

#Create an sqllite database 
db <- src_sqlite("ClinicalDb.sqlite", create = TRUE)
k <- seq(1, length(project_id), by = 1)
for (i in k) {
  copy_to(db, df = clinical[[i]], name = project_id[[i]], indexes = list(colnames(clinical[[i]])), temporary = FALSE, overwrite = TRUE)
}
