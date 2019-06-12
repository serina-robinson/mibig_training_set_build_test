## Install packages
pacman::p_load("caret", "data.table", "Biostrings", "phangorn", "ape", "seqinr", "DECIPHER", "cowplot", "tidymodels", "ranger", "tree", "rsample", "tidyverse", "randomForest","gbm","nnet","e1071","svmpath","lars","glmnet","svmpath")

# Set working directory
setwd("~/Documents/Wageningen_UR/github/mibig_training_set_build_test/")

# Extract loop
query_fil <- "data/myctu_faal32.fasta"
query <- readAAStringSet(query_fil)
ref <- readAAStringSet("data/A_domains_muscle.fasta")

# Align the query and the reference
alned <- AAStringSet(muscle::muscle(c(ref, query), in1 = "data/A_domains_muscle.fasta", in2 = query_fil, profile = T))
query_aln <- alned[length(alned)]
ref_aln <- alned["P0C062_A1"]

# Read in the 34 indices
aa34 <- fread("data/A34positions.txt", data.table = F, header = F)
aa34_inds <- as.numeric(aa34[1,])
aa34_inds_adj <- aa34_inds - 65

# Exract the 34 amino acid positions
poslist <- list()
position = 1

for(i in 1:width(ref_aln)) {
  if (substr(ref_aln, i, i) != "-") {
    if (position %in% aa34_inds_adj) {
      poslist[[i]] <- i
    }
    position = position + 1
  }
}


# Get the new indices
new_34inds <- unlist(poslist)

# Get 34 aa code
query_pos <- as.character(unlist(lapply(1:length(new_34inds), function(x) {
  substr(query_aln, new_34inds[x], new_34inds[x]) })))
seqstr <- AAStringSet(paste0(query_pos, collapse = ""))
names(seqstr) <- names(query)
seqstr


# Get FAAL loop
startind <- new_34inds[1]
stopind <- new_34inds[9]
loop_inds <- substr(query_aln, start = startind, stop = stopind)
as_loop <- paste0(seqstr, loop_inds)

# 