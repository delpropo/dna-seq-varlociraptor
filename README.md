# Snakemake workflow: dna-seq-varlociraptor

This workflow has been modified from the original workflow to better work using the Umich HPC

## example of changes
addition of threads: 1 to many rules.  This is because --set-threads will not override the threads if threads is not defined in the rule.
If you can't modify the number of threads, this can cause job failures due to memory issues and slow runs.



[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/snakemake-workflows/dna-seq-varlociraptor/workflows/Tests/badge.svg?branch=master)](https://github.com/snakemake-workflows/dna-seq-varlociraptor/actions?query=branch%3Amaster+workflow%3ATests)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4675661.svg)](https://doi.org/10.5281/zenodo.4675661)


A Snakemake workflow for calling small and structural variants under any kind of scenario (tumor/normal, tumor/normal/relapse, germline, pedigree, populations) via the unified statistical model of [Varlociraptor](https://varlociraptor.github.io).



## Issues that need to be resolved
- addition of threads to rules
- allocation of memory in a rule specific way
  - many jobs fail due to a lack of memory
  - --mem-per-cpu=?g can only be set globally for the entire workflow.  This is not ideal as some jobs require more memory than others.
  - This can and does cause jobs to fail.
  - just as you can specify the number of threads to a rule and use that in a snakemake with --cpus-per-task {threads}, it would be better to be able to specify the --mem-per-cpu={???} in the same way.  This would allow for more flexibility in the workflow as many jobs can fail due to a lack of memory.
  - This has been brought up with snakemake in general but not appear to be resolved as of 4/5/23
- post run analysis of cpu and memory usage
    - it would be nice to have a way to analyze the cpu and memory usage of the workflow.  This would allow for better resource allocation.
- post run analysis
  - Further analysis
    - The end point of the data is either a vcf or tsv
    - The vcf is created by vembrane filter
      - this is convenient in that it is a vcf and can be used in other workflows
      - this is inconvenient in that the ANN field is more difficult to parse
    - the tsv is create by vembrane table
      - this is convenient in that it a table with the information in the ANN field
      - This is inconvenient in that it is not a vcf and therefore cannot be used in other workflows as easily
      - requires individual listing of the fields to be included in the table except for a few default fields.
    - Any changes to the dna-seq-varlociraptor workflow will require a change to the post run analysis workflow
      - addition or changes to annotation
      - changes in vembrane filter or vembrane table



## Usage

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=snakemake-workflows%2Fdna-seq-varlociraptor).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) repository and its DOI (see above).

snakedeploy deploy-workflow https://github.com/delpropo/dna-seq-varlociraptor . --tag master

for the original workflow enter current version

snakedeploy deploy-workflow https://github.com/snakemake-workflows/dna-seq-varlociraptor . --tag v3.21.1


