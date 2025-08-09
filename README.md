# Benchmarking of select tools for targeted detection of gene clusters (co-located sets of genes, e.g. BGCs)

Benchmarking gene cluster detection by various bioinformatic tools:

1. cblaster: [GitHub](https://github.com/gamcil/cblaster); [Article](https://academic.oup.com/bioinformaticsadvances/article/1/1/vbab016/6342405) 
2. prepTG & fai in the zol suite: [GitHub](https://github.com/Kalan-Lab/zol); [Article](https://academic.oup.com/nar/article/53/3/gkaf045/8001966)
3. GATOR-GC: [GitHub](https://github.com/chevrettelab/gator-gc); [Article](https://academic.oup.com/nar/article/53/13/gkaf606/8192810)

> [!Important]
> We are the authors of the zol suite.

This benchmarking is partially a response to the comparisons reported between the three tools listed above in the GATOR-GC manuscript published in early July. 

An immutable form of the initial and future releases of this repo can be found on Zenodo: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16690728.svg)](https://doi.org/10.5281/zenodo.16690728)

## Remarks on benchmarking and issues with the zol suite mentioned in the GATOR-GC manuscript

We first want to apologize to users and acknowledge that there was a bug in prepTG that affected database creation if genomes were provided in GenBank format with inconsistent qualifiers. However, one kind user had brought this to our attention and we had fixed this back in April 2025 in v1.5.11 (https://github.com/Kalan-Lab/zol/releases/tag/v1.5.11). More recently, we further improved logging on the processing of input genomes. prepTG databases created using the `--gtdb-taxon` option, the `--download-premade` option, or by providing genomes in FASTA format were not affected by this issue. Second, I want to clearly state that I am planning on supporting zol for at least five years from the time of publication. We recently made substantial improvements for the creation of smaller prepTG databases and faster runtimes for fai. Third, we think there are some issues with the benchmarking performed in the GATOR-GC benchmarking and we have attempted to redo comparisons in this repo. Finally, we encourage users to try all software referenced in the benchmarking for themselves, each has their unique advantages and disadvantages.

On this page, we:

- [Reassess benchmarking](https://github.com/raufs/gene_cluster_detection_benchmarking/tree/main?tab=readme-ov-file#benchmarking) in the GATOR-GC manuscript which reported that GATOR-GC had increased sensitivity relative to cblaster and fai (in zol suite), including newer and improved versions of the latter. We ultimately find that all tools exhibit similar sensitivity, though can differ substantially on efficiency and database size.
- [Discuss the two bugs brought up in the GATOR-GC manuscript](https://github.com/raufs/gene_cluster_detection_benchmarking/tree/main?tab=readme-ov-file#notes-on-bugs-in-zol-and-related-programs) and how they have been resolved.
- [Highlight two future updates](https://github.com/raufs/gene_cluster_detection_benchmarking/tree/main?tab=readme-ov-file#two-updates-we-plan-to-implement-in-future-releases) that we plan to implement in future releases as further indication of our dedication to maintaining the suite.

## Benchmarking

We were ultimately surprised by the benchmarking results in GATOR-GC and, given the algorithms behind each tool, expected their sensitivity to be more similar under analogous parameter settings for the specific example showcase used for benchmarking. Here, we repeat the comparisons to the best of our ability, assessing both sensitivity and efficiency differences between cblaster, fai/prepTG (in the zol suite), and GATOR-GC. 

Our main conclusions are:

1. Sensitivity is nearly identical / very similar between cblaster, fai (in zol suite), and GATOR-GC when more analogous parameters are used.
2. The final diskpace of prepTG (zol suite) databases was comparable and, in newer versions, is substantially smaller than cblaster and pre-GATOR-GC when input GenBank files are also accounted for in the latter programs - which are needed for their downstream functionalities. In addition, prepTG databases can be moved around easily on the server or between servers (how we make available pre-made databases for instance).
3. That newer versions of fai which uses a DIAMOND linclust non-redundant database are nearly as fast as GATOR-GC in a mimic experiment for finding homologs of FK BGCs and that both newer and older versions of fai are substantially faster than GATOR-GC and cblaster for searching and extracting gene clusters in GenBank format from large databases at scale. Both GATOR-GC and cblaster however can likely be parallelized during certain steps to significantly boost speeds.

<img width="1434" height="1322" alt="image" src="https://github.com/user-attachments/assets/91bda082-aa90-44a6-a998-e366061400cf" />

### Construction of the target genome dataset and gathering of query sequences

Because the details of the target genomes dataset used in the GATOR-GC paper for their benchmarking was unavailable, I used a set of 6,191 _Streptomyces_ genomes from GTDB R226 (accessions listed in this repository). This is because most of the genomes with hits to the macrolide encoding FK family biosynthetic queries were _Streptomyces_ in the GATOR-GC paper. To prepare the genomes in GenBank format (needed for cblaster and GATOR-GC database creation), FASTA genomes were downloaded and processed to GenBanks using prepTG v1.5.19 with gene calling performed using pyrodigal v3.6.3. Relevant protein queries were downloaded from NCBI’s Protein database as described in the Supplemental Table S1 of the GATOR-GC study. Because <1% of the _Streptomyces_ genomes searched featured a BGC of interest, we also applied GATOR-GC and fai for finding a set of three syntenically conserved translation related genes that are near-core to the genus and do not include PKS or NRPS domains. To determine this operon, we searched for homologs of a random _Streptomyces_ ribosomal gene (S7) using [fast.genomics](https://fast.genomics.lbl.gov/cgi/neighbors.cgi?seqDesc=109%20a.a.%20beginning%20with%20QDKVEKNKTP&seq=QDKVEKNKTPALEGSPQRRGVCTRVFTTTPKKPNSALRKVARVRLTSGIEVTAYIPGEGHNLQEHSIVLVRGGRVKDLPGVRYKIIRGSLDTQGVKNRKQARSRYGAKK) and found that across diverse bacteria from multiple Actinomycetes orders it was consistently found together with elongation factor G and ribosomal protein S12. These three proteins were thus used as queries. 

### Versions and resources used:

For this benchmarking, we used v1.0.0 of GATOR-GC, v1.3.20 of cblaster, and versions 1.5.10 (version used in GATOR-GC benchmarking) and 1.6.3 (latest version at the time of this benchmarking). We ran experiments on the same computing system described in the zol manuscript. For all fai timing runs except use of cblaster to search for the translation-related operon, two separate runs were performed and runtime was calculated as the average of the two runs. For all commands, 50 threads were specified.  

### Rationale for parameter configurations:

After consideration of the algorithms for the three software packages, we ignored the use of optional proteins and only used the required proteins for the FK family query search example. While all three software can take optional proteins and similarly annotate their presence in detected gene clusters, what actually mattered for gene cluster detection in the GATOR-GC manuscript benchmarking setup were the four required proteins to our understanding. We also adjusted the parameters for cblaster and fai to better match the loose searching criteria required by GATOR-GC (namely setting maximum E-value to 1e-5). While cblaster also supports altering coverage/identity cutoffs, because PKS genes have multiple domains which complicates use of these parameters, we set relevant cutoffs to 0. The parameter `--hitlist_size` in cblaster was also increased to 1,000,000. In addition, because GATOR-GC creates some additional visualizations to make it more comparable to runtimes of cblaster search + extract_clusters and fai we requested that GATOR-GC skip creating some optional plotting via issuing the arguments `-nc -nn`. Also, since both GATOR-GC and fai account for intermediate genes, cblaster was run with the `-ig` flag and the `--maximum_clusters` set to 1,000,000 to perform this for all gene clusters identified. If you look at results of GATOR-GC and compare them to equivalents in the comparator programs - you will find that the available results mostly match up. For conservation analyses, we provide pretty similar data in the consolidated spreadsheet produced by fai and cblaster search provides this as its main tabular result file. GATOR-GC assesses conservation for each gene cluster identified  and this results in some additional time - so we try to mark the time it took to get to simply the extraction of homologous gene clusters. One reason cblaster was at a slight disadvantage for timing was that it didn’t offer "default" sensitivity for DIAMOND blastp, similar to earlier fai versions (<v1.6.1), thus we used “mid-sensitive” to best match the use of "default" DIAMOND sensitivity for them. Finally, while fai was run with `--draft-mode` in the GATOR-GC manuscript, we did not use it because: (1) neither GATOR-GC nor cblaster have an equivalent mode to our knowledge and (2) it is not necessary since there are only four required proteins and for `--draft-mode` to take effect there needs to be at least six proteins in the query. We can improve documentation around point (2). 

For the FK search, we used 15 kb or 15 genes as the max distance separating required genes in candidate homologous gene clusters and requested 25 kb flanking contexts, similar to the GATOR-GC manuscript. For searching for the translational-operon, we allowed for only a distance of up to 5 kb or 5 genes between required proteins and requested only genes within 5 kb contexts be reported.

### Preparing databases:

The first step to construct a database of target genomes is performed by distinct programs/modules in each of the three packages: pre-gator-gc, cblaster makedb, and prepTG.

<img width="2156" height="700" alt="image" src="https://github.com/user-attachments/assets/ce412028-9234-4d67-9f0c-00a735bd2d7e" />

The exact commands we used can be found in subdirectories `database_creation/` within timing commands to measure resource usage.

**Notes**:
- pre-gator-gc produced two hidden files within pre-gator-gc_DB/ that were not recognized by gator-gc so I manually renamed these to get gator-gc to recognize them downstream.
- The memory of DIAMOND linclust for prepTG can be controlled via the `-mm` argument and will by default use 16GB for that step. Similarly, pre-gator-gc and cblaster’s memory can be controlled via the `-b` argument controlling the number of files to process at a time. 
- GATOR-GC requires both the database (38 GB) and the original GenBank files (uncompressed based on the help function and testing; 89 GB) as input, thus disk usage should account for both. Similarly, for cblaster extract_clusters to function properly, original GenBank files provided to cblaster makedb are required, however it can handle gzipped files (for this benchmarking, we used databases created from uncompressed inputs - which might potentially impact the speed of `cblaster extract_clusters`). In contrast, prepTG databases are completely independent of the input used to generate them and can be moved around/between servers. In newer versions, we also do a better job with compression (which takes away a little on the runtime when we extract gene cluster specific GenBank files downstream).

### Targeted searching for FK (PKS) gene clusters

<img width="1122" height="666" alt="image" src="https://github.com/user-attachments/assets/b2f93716-d3c9-4a1f-8c15-3ffc60446f03" />

The exact commands we used can be found in subdirectories `fk_search/` within timing commands to measure resource usage.

**Notes**:
- `cblaster search` only took ~16-18 minutes and `cblaster extract_clusters` took ~7-8 minutes.
- `GATOR-GC` should be even slightly faster - we just could not measure how fast it created only the window gene cluster files based on timestamps of files given the short runtime.

### Targeted searching for a highly conserved translation-associated operon amongst _Streptomyces_

<img width="1080" height="644" alt="image" src="https://github.com/user-attachments/assets/a1c69216-1feb-4095-8aae-73c63ba18701" />

The exact commands we used can be found in subdirectories `translation_operon_search/` within timing commands to measure resource usage.

**Notes**:
- `cblaster search` took over 30 hours for cblaster search alone - mainly due to time needed for extracting intermediate genes via the `--ig` option, it ran really fast without this option. `cblaster extract_clusters` was not attempted. 
- Based on file timestamps, it took GATOR-GC at least ~32 minutes to get past the step where it creates window GenBank files. 

### Running a more detailed zol analysis

We can also run a more detailed analysis using zol on the PKS gene cluster example. A comprehensive analysis is not recommended here and we instead recommend users select gene clusters which are more closely related to the query prior to running zol. This assessment can be done from the fai results, for instance we see the first six gene clusters detected are quite similar to the query and there is a drop off after:

<img width="612" height="330" alt="image" src="https://github.com/user-attachments/assets/1201dc95-081c-4376-b37a-fc7fb3525c89" />

zol allows for determining de novo ortholog groups, including domain-resolution ortholog groups. We can run zol in `-dom` mode so it doesn’t get stuck on multiple sequence alignments of giant multi-domain PKS sequences. But here we just run zol without `-dom` mode on the top six gene clusters in terms of similarity to the query proteins. Note, 25 kb flanking context was included in their extraction:

<img width="764" height="398" alt="image" src="https://github.com/user-attachments/assets/c391d739-4fd8-4845-8152-15dacbd58c7e" />

### Additional minor comments on zol suite references in the GATOR-GC manuscript

- In supplemental table S3, it claims that zol and fai are unable to perform gene cluster deduplication. While we don't use gene profiles, ANI-based dereplication has been available in zol since mid-2023 and was discussed in our manuscript.
- Also in supplemental table S3, while not showcasing domain architecture in a conventional manner, zol can be run in `-dom` mode and this can be input into cgcg.
- While HMM-based domain-resolution searching certainly has advantages - such as if looking for remote homology across multiple phyla - or to fine-tune querying - by requiring separate criteria for large NRPS/PKS enzymes - we want to note that fai also allows users to mark some of the proteins as "key" and use different criteria for searching for them than is required for the rest of the protein queries. In addition, DIAMOND blastp is a local alignment based approach, thus high homology of individual domains should be detected, albeit running blastp with such large protein queries can be very slow and avoiding this is certainly an advantage in GATOR-GC's approach.

## Notes on bugs in zol and related programs

There were two bugs reported in the GATOR-GC manuscript pertaining to prepTG and zol. Both of these had been resolved prior to the GATOR-GC publication.

The more major issue highlighted was with prepTG skipping many target genomes for inclusion in the database due to its handling of GenBank input files when they contain CDS features lacking translations.

This was indeed a major issue and someone kindly informed us of this which we promptly resolved in v1.5.11, released on April 17th, 2025. Our current solution to this involves skipping input GenBank files only when they contain a large fraction of such CDS features that lack translation qualifiers and involves better logging to inform users. More recently in v1.6.1, we also create a file in prepTG which lists input GenBank files that failed to process properly and explanations for why. Last paragraph of the help function of prepTG:

> If GenBank files are provided, CDS features are expected and further each CDS feature should contain a "translation" qualifier which features the protein sequence and optionally a "locus_tag" qualifier. Options to consider when providing GenBank files as input include `--rename-locus-tags`, `--error-no-lt`, and `--error-no-translation`. Note, by default, if a CDS does not feature a locus tag, it will be given an arbitrary one. Also, if a CDS does not feature a translation, the CDS feature will be skipped.  If >10% of CDS features are skipped for lacking a translation, then the entire genome will be skipped.

We recognize that this could have caused major issues and apologize to users affected. I had just finished grad school and was moving to a new state and my planned social media message to inform users just got lost. Our prior testing set of input GenBank files were largely limited to a handful from NCBI’s RefSeq without the issue and we ourselves primarily provide FASTA files as inputs for prepTG to re-perform uniform gene-calling using prepTG’s integration of p(y)rodigal and miniprot. If you used prepTG with FASTA files as inputs, this did not affect you. 

The second bug was related to a pretty rare issue with zol not accounting for the possibility of producing empty alignments for ortholog groups after trimming that should be resolved in v1.5.19. In the benchmarking, it was triggered because really distant PKS BGCs were compared and zol is designed for comparison of more similar orthologous gene clusters. zol has a `--dom` mode which uses Pfam domain annotation with pyhmmer to “chop-up” these giant proteins into domain resolution chunks and then infers orthologs of those instead (of course inspired by BiG-SCAPE/SLICE). We demonstrated this option/mode for investigation of a PKS containing BGC from the fungal species of Aspergillus flavus in our study. 

## Two updates we plan to implement in future releases

As mentioned, we are dedicated to maintaining zol and might also update some functionalities. Two ideas we are planning include:

1. Consider doing layered searching whereby fai with certain queries can be used to create a smaller, more limited, prepTG database only containing genomes which contain those queries. Then another query / fai run can be performed after this on the limited prepTG database - which should run faster. 

2. Have an option for on the fly GenBank creation for metagenomic datasets after gene cluster detection (in fai) to avoid creating large-space costly GenBank files for full (meta-)genomes in advance (in prepTG) to extract gene clusters from. Instead, with certain options contained, prepTG will harbor more light-weight annotation formats, like Prokka-like GFFs (TSV followed by FASTA) or GenBank files without translations.
