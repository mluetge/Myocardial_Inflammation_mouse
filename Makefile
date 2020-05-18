basedir := /mnt/data/TCRM_Christina
basedirref := /mnt/data/referenceFiles
fastqdir := /data/scRNAseq/TCRM_Christina

cellranger := /mnt/tools/cellranger-3.0.2/cellranger

genome := $(basedirref)/Mus_musculus.GRCm38.dna.primary_assembly.fa
gtf := $(basedirref)/Mus_musculus.GRCm38.94.gtf

customtx := $(basedirref)/eyfp_tdtomato_sequences.fa
customgtf := $(basedirref)/eyfp_tdtomato_sequences.gtf
extendedgenome := $(basedirref)/Mus_musculus.GRCm38.dna.primary_assembly_extended_orig.fa

extendedgtf := $(basedirref)/Mus_musculus.GRCm38.90_extended_orig.gtf
extendedgenomename := Ensembl_GRCm38.94_extended_orig


R_OPTS := --vanilla
R := R_LIBS=/mnt/tools/R-3.6.0/library/ /mnt/tools/R-3.6.0/bin/R
sce_Rscript := $(basedir)/analysis/processCellrangerOut.R
org :=mouse

samples := 1_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3 2_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3 3_20200317_Ccl19-EYFP_balbc_PDPN_v3 4_20200317_Ccl19-EYFP_balbc_PDPN_v3
run := CellRangerV3

.PHONY: all

all: $(basedirref)/$(extendedgenomename)/reference.json \
$(foreach S,$(samples),data/$(run)/$(S)/outs/web_summary.html) \
$(foreach S,$(samples),data/processedData/$(S)_$(shell date +%Y_%m_%d).rds)

## ------------------------------------------------------------------------------------ ##
## Generate reference for CellRanger
## ------------------------------------------------------------------------------------ ##
$(extendedgenome): $(genome) $(customtx)
	mkdir -p $(@D)
	cat $(genome) $(customtx) > $(extendedgenome)

$(extendedgtf): $(gtf) $(customgtf)
	mkdir -p $(@D)
	cat $(gtf) $(customgtf) > $(extendedgtf)

$(basedirref)/$(extendedgenomename)/reference.json: $(extendedgenome) $(extendedgtf)
	mkdir -p $(basedirref)
	cd $(basedirref) && $(cellranger) mkref --nthreads=12 --genome=$(extendedgenomename) --fasta=$(notdir $(extendedgenome)) --genes=$(notdir $(extendedgtf))

## ------------------------------------------------------------------------------------ ##
## Run CellRanger to count reads
## ------------------------------------------------------------------------------------ ##

Project := NovaSeq_20200507_NOV363_o6934_DataDelivery
define cellrangerrule
data/$(run)/$(1)/outs/web_summary.html: $(basedirref)/$(extendedgenomename)/reference.json \
$(fastqdir)/$(Project)/$(1)/$(1)_$(2)_L001_I1_001.fastq.gz \
$(fastqdir)/$(Project)/$(1)/$(1)_$(2)_L001_R1_001.fastq.gz \
$(fastqdir)/$(Project)/$(1)/$(1)_$(2)_L001_R2_001.fastq.gz \
$(fastqdir)/$(Project)/$(1)/$(1)_$(2)_L002_I1_001.fastq.gz \
$(fastqdir)/$(Project)/$(1)/$(1)_$(2)_L002_R1_001.fastq.gz \
$(fastqdir)/$(Project)/$(1)/$(1)_$(2)_L002_R2_001.fastq.gz
	mkdir -p data/$(run)
	cd data/$(run) && \
	$(cellranger) count --id=$(1) --fastqs=$(fastqdir)/$(Project)/$(1) \
	--sample=$(1) --nosecondary \
	--transcriptome=$(basedirref)/Ensembl_GRCm38.94_extended --localcores=8
endef
$(eval $(call cellrangerrule,1_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3,S13))
$(eval $(call cellrangerrule,2_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3,S13))
$(eval $(call cellrangerrule,3_20200317_Ccl19-EYFP_balbc_PDPN_v3,S13))
$(eval $(call cellrangerrule,4_20200317_Ccl19-EYFP_balbc_PDPN_v3,S13))

## ------------------------------------------------------------------------------------ ##
## Generate sce object
## ------------------------------------------------------------------------------------ ##
#data/HungweiILCs_plus_LP_EYFP_$(shell date +%Y_%m_%d).rds: $(foreach S,$(run),data/$(S)/*/outs/web_summary.html) \
$(sce_Rscript)
#	$(R) CMD BATCH $(R_OPTS) "--args $(addsuffix filtered_gene_bc_matrices/Ensembl_GRCm38.94_extended,$(dir $(filter-out $(sce_Rscript),$^))) $(basedir) $@" $(sce_Rscript)

define processCRrule
data/processedData/$(1)_$(shell date +%Y_%m_%d).rds: data/$(run)/$(1)/outs/web_summary.html
	$(R) CMD BATCH $(R_OPTS) "--args $(addsuffix filtered_feature_bc_matrix,data/$(run)/$(1)/outs/) $(org) $(basedir) data/processedData/$(1)_$(shell date +%Y_%m_%d).rds" $(sce_Rscript)
endef

$(eval $(call processCRrule,1_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3))
$(eval $(call processCRrule,2_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3))
$(eval $(call processCRrule,3_20200317_Ccl19-EYFP_balbc_PDPN_v3))
$(eval $(call processCRrule,4_20200317_Ccl19-EYFP_balbc_PDPN_v3))


