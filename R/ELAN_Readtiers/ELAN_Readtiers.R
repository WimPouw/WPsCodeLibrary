library(rstudioapi)
#library(devtools)
#devtools::install_github("langdoc/FRelan")
library(tidyverse)
library(tibble)
library(xml2)
library(reticulate) #for python

#current folder
basefolder <- dirname(rstudioapi::getSourceEditorContext()$path) #get path of current R doc
testfile <- paste0(basefolder, "/Example.eaf")

source_python(paste0(basefolder, "/pyelan-master/pyelan-master/pyelan.py"))


tierSet(file = "Example.eaf")