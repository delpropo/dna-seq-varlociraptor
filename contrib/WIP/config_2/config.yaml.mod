samples: config/samples.tsv

units: config/units.tsv
groups: config/groups.tsv

# Optional group annotation table. Uncomment to use.
# In the table, there has to be a column "group",
# with one entry for each group occurring in the
# sample sheet above. Any additional columns may be
# added to provide metadata for groups (e.g. if each
# group is a patient or individual).
# The given data will be shown in the header of the reported
# variant call overview tables.
# groups: config/groups.tsv

# Optional BED file with target regions
# target_regions: "path/to/taget-regions.bed"

ref:
  # Number of chromosomes to consider for calling.
  # The first n entries of the FASTA will be considered.
  n_chromosomes: 25
  # Ensembl species name
  species: homo_sapiens
  # Ensembl release
  release: 105
  # Genome build
  build: GRCh38
  # Optionally, instead of downloading the whole reference from Ensembl via the
  # parameters above, specify a specific chromosome below and uncomment the line.
  # This is usually only relevant for testing.
  

primers:
  trimming:
    activate: false
    # path to fasta files containg primer sequences
    primers_fa1: ""
    primers_fa2: ""
    # optional primer file allowing to define primers per sample
    # overwrites primers_fa1 and primers_fa2
    # the tsv file requires three fields: panel, fa1 and fa2 (optional)
    tsv: ""
    # Mean insert size between the outer primer ends.
    # If 0 or not set the bowtie default value of 250 will be used
    library_length: 0

# Estimation of tumor mutational burden.
mutational_burden:
  activate: false
  # Plotting modes - hist (stratified histogram)
  # or curve (stratified curve)
  # mode:
  #  - curve
  #  - hist
  events:
    # - somatic_tumor_low

# printing of variants in interactive tables
report:
  # if stratification is deactivated, one report for all
  # samples will be created.
  activate: true
  max_read_depth: 250
  stratify:
    activate: true
    # select a sample sheet column for stratification
    by-column: group

benchmarking:
  activate: false

calling:
  # Set to true to infer classical genotypes from Varlociraptor's VAF predictions
  # changed infer_genotypes to true on 1/12/23
  infer_genotypes: true
  delly:
    activate: true
  freebayes:
    activate: true
  # See https://varlociraptor.github.io/docs/calling/#generic-variant-calling
  scenario: config/scenario.yaml
  filter:
    # Filter candidate variants.  It should ideally generate a superset of all other filters defined below.  
    # Annotation of candidate variants tries to be as fast as possible, only using VEP.  See https://github.com/vembrane/vembrane
    candidates:         'ANN["IMPACT"] != "LOW"' # this line is required to even run.  No idea why but might be needed in the actual workflow.
    low_MAF:          'INFO["known_MAF"] <= 0.01' # this works.  
    med_MAF:          'INFO["known_MAF"] <= 0.10'
    high_MAF:         'INFO["known_MAF"] >= 0.9'
    low_no_MAF:       'INFO["known_MAF"] <= 0.01 or INFO["known_MAF"] is NA' # works
    med_no_MAF:       'INFO["known_MAF"] <= 0.10 or INFO["known_MAF"] is NA' 
    MAF_not_in_INFO:  'INFO["known_MAF"] is NA'  # determine if the key is in the dictionary
    benign:           '"benign" in ANN["CLIN_SIG"]' # works 
    not_benign:       '"benign" not in ANN["CLIN_SIG"] or "likely_benign" not in ANN["CLIN_SIG"]'  # works
    high_impact:      'ANN["IMPACT"] == "HIGH"'
    # https://useast.ensembl.org/info/genome/variation/prediction/classification.html#classes
    # remove most common variants such as SNV.  more can be added   short_tandem_repeat_variation
    rare_var:         'ANN["VARIANT_CLASS"] is NA or not {"SNV"}.isdisjoint(ANN["VARIANT_CLASS"])'
    # Add any number of named filters here (replace myfilter with a reasonable name,
    # and add more below). Filtering happens with the vembrane filter language
    # (see https://github.com/vembrane/vembrane), and you can refer to any fields that
    # have been added by VEP during annotation (in the INFO/ANN field, see section
    # annotations/vep below).
    # Filters will be applied independenty, and can be referred in FDR control below
    # to generate calls for different events.
    # You can for example filter by ANN fields, ID or dbsnp annotations here.
    # invalid: "'known_HGMD-PUBLIC_20204' not in FILTER"
    # If you need to use vembrane command line options beyond the filter expression,
    # please use the filter sub-structure with 'expression:' for the filter expression
    # and "aux-files:" for additional files with IDs for filtering. This can for example
    # be used for filtering by gene lists (with a file containing one gene name per line).
    # It appears that you can't use multiple columns in a file.  Tested and doesnt seem to work.  changed to single column 
    gene_list_filter:
      aux-files:
        super_interesting_genes: "config/super_interesting_genes.tsv"
      expression: "ANN['GENE'] in AUX['super_interesting_genes']"
    neurological_gene_filter:
      aux-files:
        neurological_genes: "config/2018_neurological_genes.tsv"
      expression: 'ANN["SYMBOL"] in AUX["neurological_genes"]'
  fdr-control:
    threshold: 0.05
    local: false
    events:
      filter_WIP_18:
        labels:
          label: WIP final filter 
        desc:    WIP final filter
        varlociraptor:
          - het
          - hom
        filter:
          - med_no_MAF
          - not_benign
          - neurological_gene_filter
      # Add any number of events here to filter for. The id of each event can be chosen freely, but contain only alphanumerics and underscore
      # ("somatic" below is just an example and can be modified as needed).
      high_impact_neuro_2:
        # labels for the callset, displayed in the report. Will fall back to id if no labels specified
        labels:
          high_impact: high impact  var het hom
        #  other-label: "other label text"
        # optional subcategory for callset (e.g. "known variants", or "VUS"), comment out or remove to disable
        # subcategory: some subcategory.  Natural language description of the callset obtained here. This will occur in the report.
        desc: high impact neurological filter
        varlociraptor:
          # Add varlociraptor events to aggregated over.  The probability for the union of these events is used for controlling the FDR
          - het
          - hom
        filter: 
          - high_impact
          - neurological_gene_filter
      # filter_neurological:
      #  labels:
      #    label: TBD
      #  desc:  neurological test
      #  varlociraptor:
      #    - het
      #    - het
      #   filter:
      #     - neurological_gene_filter
      # filter_expansion_WIP_9:
      #  labels:
      #    label: Structural Variants with expansion 
      #  desc: structural variants with an expansion
      #  varlociraptor:
      #    - het
      #    - het
      #  filter:
      #    - SVLEN
      #    - expansion
      # filter_not_benign:
      #  labels:
      #    label: not benign variants
      #  desc:    not benign variants
      #  varlociraptor:
      #    - het
      #    - het
      #  filter:
      #    - not_benign
      filter_variant_2:
        labels:
          variant: variant type filter
        desc:   variant type filter
        varlociraptor:
          - het
          - hom
        filter:
          - not_benign
          - neurological_gene_filter
          - rare_var
      #    - known_MAF
      # - MAF_low_or_unknown

















 


# If calc_consensus_reads is activated duplicates will be merged
remove_duplicates:
  activate: true

# Experimental: calculate consensus reads from PCR duplicates.
# if 'remove_duplicates' is deactivate only overlapping pairs will be merged
calc_consensus_reads:
  activate: false

annotations:
  vcfs:
    activate: true
    # annotate with known variants from ensembl
    known: resources/variation.vcf.gz
    # add more external VCFs as needed
    # cosmic: path/to/cosmic.vcf.gz
  dgidb:
    # annotate variants with drug interactions of affected genes
    activate: false
    # List of datasources for filtering dgidb entries
    # Available sources can be found on http://dgidb.org/api/v2/interaction_sources.json
    datasources:
      - DrugBank
  vep:
    # Consider removing --everything if VEP is slow for you (e.g. for WGS),
    # and think carefully about which annotations you need.  removed --everything.
    # Added canonical due to an issue with the files where it required canonical
    params:  --check_existing --canonical --variant_class
    plugins:
      # Add any plugin from https://www.ensembl.org/info/docs/tools/vep/script/vep_plugins.html
      # Plugin args can be passed as well, e.g. "LoFtool,path/to/custom/scores.txt".
      # REVEL is a pathogenicity predictor.  LoFtool is a loss of function
      - LoFtool
      - REVEL
      - GWAS   


# printing of variants in a table format (might be deprecated soon)
# deactivated this after having so many problems!
tables:
  activate: true 
  output:
    # Uncomment and add VEP annotation fields to include (IMPACT, Consequence, Feature, SYMBOL, and HGVSp are always included)
    expression: 'INFO["known_MAF"]'
    annotation_fields:
      - VARIANT_CLASS
      # - ANN["CLIN_SIG"]
      # - "CANONICAL"
      # - ANN["IMPACT"]
      # - INFO["known_MAF"]
      # - ANN["HGVSp"]
      - Feature_type
    event_prob: true
    observations: true
  generate_excel: false

# ANN values
# Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|
# Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STR
# AND|FLAGS|SYMBOL_SOURCE|HGNC_ID|CANONICAL|HGVSg|CLIN_SIG|SOMATIC|PHENO|LoFtool|REVEL">






# add a fake adapter due to issues with pretrimmed fq files
# Added SORTING_COLLECTION_SIZE_RATIO of 0.1 from 0.25 due to memory issues
# ADDED MAX_RECORDS_IN_RAM 10000 from 50000 due to memory issues
# continue to have memory issues.  increase Xmx to 200gb.  this is normally set dynamically and has been averaging about 100gb for 30gb files
# trying resources.mem_mb dut to failure with Xmx
# #  attempting parallel threads -XX:ParallelGCThreads=8 did not cause more threads to be run
params:
  cutadapt: "-a AGAGCACCACGTCTGAACTCCAGTCACAGGAGGATGCTGCTGCTATCGATGTAGCT"
  picard:
    MarkDuplicates: "--VALIDATION_STRINGENCY LENIENT --SORTING_COLLECTION_SIZE_RATIO 0.1 --MAX_RECORDS_IN_RAM 200000 "
  gatk:
    BaseRecalibrator: ""
    applyBQSR: ""
  varlociraptor:
    # add extra arguments for varlociraptor call
    # For example, in case of panel data consider to omit certain bias estimations
    # which might be misleading because all reads of an amplicon have the same start
    # position, strand etc. (--omit-strand-bias, --omit-read-position-bias,
    # --omit-softclip-bias, --omit-read-orientation-bias).
    call: ""
    # Add extra arguments for varlociraptor preprocess. By default, we limit the depth to 200.
    # Increase this value for panel sequencing!
    preprocess: "--max-depth 200"
  freebayes:
    min_alternate_fraction: 0.05 # Reduce for calling variants with lower VAFs
