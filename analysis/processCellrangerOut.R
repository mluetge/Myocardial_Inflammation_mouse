######## process Cellranger output ########################################
#### Aim: Standard workflow to automate processing of cellranger output ###
#### For each sample sce and seurat objects plus marker genes are gene- ###
#### rated and stored at NAS server to be available. SCE objects can be ###
#### merged for final processing using cbind(sce1, sce2) ##################
###########################################################################

## load packages
library(processSCE)
library(runSeurat3)

##commandargs
args <- commandArgs(TRUE)
n <- length(args)
#res_file <- paste0(args[n-1], "/", args[n])
seuratOut <-  paste0(args[n-1], "/", gsub(".rds","",args[n]), "_seurat.rds")
#markerOut <-  paste0(args[n-1], "/", gsub(".rds","",args[n]), "_markerGenes.txt")
#specificOut <-  paste0(args[n-1], "/", gsub(".rds","",args[n]), "_specificGenes.txt")
#filteredOut <- paste0(args[n-1], "/", gsub(".rds","",args[n]), "_GenesFiltered.rds")
QCout <- paste0(args[n-1], "/filteringReport.txt")
org <- args[n-2]

## input dir to fastq files from Cellranger and dataset name
fastqdirs <- c()
datasetNam <- c()
for(i in seq_len(n-3)){
  path <- args[i]
  fastqdirs[i] <- paste0(args[n-1], "/", path)
  datasetNam[i] <- gsub("^.*/","",gsub("/outs.*$","",args[i]))
}

## create sce object and run QC
sce <- createSCEobject(sampleDir=fastqdirs, dataset=datasetNam)
sce <- runQC(sce = sce, organism=org)
sce <- findOutlier(sce = sce, return.plot = F, QCfile=QCout)
sce <- sce[, !(sce$total_counts_drop | sce$total_features_drop |
                 sce$mito_drop)]
## save sce
#saveRDS(sce, file=res_file)
sce <- filterGenes(sce)
#saveRDS(sce, file=filteredOut)
detach(package:processSCE)

## create seurat object and save marker files
seurat <- createSeurat3(sce=sce, res = c(0.25, 0.6, 0.8, 0.4))
remove(sce)
#createMarkerLists(seurat, markerOut=markerOut, specificOut = specificOut)
saveRDS(seurat, file=seuratOut)

## session info
sessionInfo()
date()
