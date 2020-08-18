basedir := /mnt/data/TCRM_Christina
basedirref := /mnt/data/referenceFiles/balbc
fastqdir := /data/scRNAseq/TCRM_Christina

cellranger := /mnt/tools/cellranger-3.0.2/cellranger

genome := $(basedirref)/Mus_musculus.GRCm38.dna.primary_assembly.fa
gtf := $(basedirref)/Mus_musculus.GRCm38.100.gtf

customtx := $(basedirref)/eyfp_tdtomato_sequences.fa
customgtf := $(basedirref)/eyfp_tdtomato_sequences.gtf
extendedgenome := $(basedirref)/Mus_musculus.GRCm38.dna.primary_assembly_extended_orig.fa

extendedgtf := $(basedirref)/Mus_musculus.GRCm38.100_extended_orig.gtf
extendedgenomename := Ensembl_GRCm38.100_extended_orig


R_OPTS := --vanilla
R := R_LIBS=/mnt/tools/Rlibs/release-3.10-lib/ /mnt/tools/R-3.6.1/bin/R
sce_Rscript := $(basedir)/analysis/processCellrangerOut.R
org :=mouse

samples := 1_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3 2_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3 3_20200317_Ccl19-EYFP_balbc_PDPN_v3 4_20200317_Ccl19-EYFP_balbc_PDPN_v3 6_20200610_TCRM_balbc_4w_PDPN_v3 7_20200610_TCRM_balbc_4w_PDPN_v3 8_20200610_TCRM_balbc_12w_PDPN_v3 9_20200610_TCRM_balbc_8w_PDPN_v3 10_20200610_Littermate_control_balbc_4w_PDPN_v3 11_20200610_Littermate_control_balbc_4w_PDPN_v3
samples := 12_20200723_Mu_LN_Lin_neg_FSC_Balbc_v3 14_20200729_Mu_balbc_medisLN_TCRM_stromal_cells_v3 15_20200729_Mu_balbc_medisLN_LM_stromal_cells_v3
samples := 13_20200723_Hu_LN_Lin_neg_FSC_v3
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
	--transcriptome=$(basedirref)/Ensembl_GRCm38.100_extended_orig --localcores=8
endef
$(eval $(call cellrangerrule,1_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3,S1))
$(eval $(call cellrangerrule,2_20200317_TCRMxCcl19-EYFP_balbc_PDPN_v3,S2))
$(eval $(call cellrangerrule,3_20200317_Ccl19-EYFP_balbc_PDPN_v3,S3))
$(eval $(call cellrangerrule,4_20200317_Ccl19-EYFP_balbc_PDPN_v3,S4))

## ------------------------------------------------------------------------------------ ##

Project := NovaSeq_20200622_NOV394_o7096_DataDelivery
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
	--transcriptome=$(basedirref)/Ensembl_GRCm38.100_extended_orig --localcores=8
endef
$(eval $(call cellrangerrule,6_20200610_TCRM_balbc_4w_PDPN_v3,S6))
$(eval $(call cellrangerrule,7_20200610_TCRM_balbc_4w_PDPN_v3,S7))
$(eval $(call cellrangerrule,8_20200610_TCRM_balbc_12w_PDPN_v3,S8))
$(eval $(call cellrangerrule,9_20200610_TCRM_balbc_8w_PDPN_v3,S9))
$(eval $(call cellrangerrule,10_20200610_Littermate_control_balbc_4w_PDPN_v3,S10))
$(eval $(call cellrangerrule,11_20200610_Littermate_control_balbc_4w_PDPN_v3,S11))

## ------------------------------------------------------------------------------------ ##

Project := NovaSeq_20200731_NOV429_o7288_DataDelivery
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
	--transcriptome=$(basedirref)/Ensembl_GRCm38.100_extended_orig --localcores=8
endef
$(eval $(call cellrangerrule,12_20200723_Mu_LN_Lin_neg_FSC_Balbc_v3,S12))
$(eval $(call cellrangerrule,14_20200729_Mu_balbc_medisLN_TCRM_stromal_cells_v3,S14))
$(eval $(call cellrangerrule,15_20200729_Mu_balbc_medisLN_LM_stromal_cells_v3,S15))
$(eval $(call cellrangerrule,13_20200723_Hu_LN_Lin_neg_FSC_v3,S13))

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
$(eval $(call processCRrule,6_20200610_TCRM_balbc_4w_PDPN_v3))
$(eval $(call processCRrule,7_20200610_TCRM_balbc_4w_PDPN_v3))
$(eval $(call processCRrule,8_20200610_TCRM_balbc_12w_PDPN_v3))
$(eval $(call processCRrule,9_20200610_TCRM_balbc_8w_PDPN_v3))
$(eval $(call processCRrule,10_20200610_Littermate_control_balbc_4w_PDPN_v3))
$(eval $(call processCRrule,11_20200610_Littermate_control_balbc_4w_PDPN_v3))
$(eval $(call processCRrule,12_20200723_Mu_LN_Lin_neg_FSC_Balbc_v3))
$(eval $(call processCRrule,14_20200729_Mu_balbc_medisLN_TCRM_stromal_cells_v3))
$(eval $(call processCRrule,15_20200729_Mu_balbc_medisLN_LM_stromal_cells_v3))
$(eval $(call processCRrule,13_20200723_Hu_LN_Lin_neg_FSC_v3))