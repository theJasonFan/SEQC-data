# SEQC Data

Download, aggregate and give SEQC samples better names.

Much thanks to SRA-Explorer written by Phil Ewels, from which "raw" metadata TSV files are downloaded.

## Usage

1. Run `snakemake --snakefile meta.snk` to generate clean metadata file.
2. Run `snakemake download -j <n_jobs>` to download (concurrently via Snakemake) FastQs
3. run `snakemake by_fc -j <n_jobs>` to aggregate gzipped FastQs by unique flowcells per cite.

## File name format from SRA

Sample title: GSM1156797: SEQC_ILM_BGI_A_1_L01_ATCACG_AC0AYTACXX; Homo sapiens; RNA-Seq
format: (geo) SEQC_(technology)_(location)_(sample)_(replicate #)_(lane)_(sample_tag?)_(flowcell ID).

## SEQC/MAQC-III Consortium - Scientific Data

*Cross-platform ultradeep transcriptomic profiling of human reference RNA samples by RNA-Seq*. 

These descriptions on RNA-Seq sequencing sites are expanded from descriptions in the related research manuscript13. 
Each sequencing site was assigned a three-letter code and each platform vendor designated three ‘official sites’ (superscripted by *) before samples were distributed. 
Illumina HiSeq 2000 data were provided by 7 sites (ordered alphabetically by the site code): 
    1. Australian Genome Research Facility (AGR);
    2. Beijing Genomics Institute (BGI)*;
    3. Weill Cornell Medical College (CNL)*; 
    4. City of Hope (COH); 
    5. Mayo Clinic (MAY)*; 
    6. Novartis (NVS); and 
    7. the New York Genome Center (NYG), generating 100+100 nt read-pairs. 
    
Life Technologies SOLiD 5500 data were provided by 4 sites: (1) the University of Liverpool (LIV); (2) Northwestern University (NWU)*; (3) the Pennsylvania State University (PSU)*; and (4) SeqWright Inc. (SQW)*, generating 51+36 nt read-pairs, except for Liverpool which applied a protocol variant giving single 76 nt reads.

## Notes:
- As of 11/09/20, MAY samples are not searchable by `All Fields` in SRA... and