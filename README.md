# Snakemake workflow: dna-seq-varlociraptor

This workflow has been modified from the original workflow to better work using the Umich HPC

## example of changes
addition of threads: 1 to many rules.  This is because --set-threads will not override the threads if threads is not defined in the rule.
If you can't modify the number of threads, this can cause job failures due to memory issues and slow runs.



[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/snakemake-workflows/dna-seq-varlociraptor/workflows/Tests/badge.svg?branch=master)](https://github.com/snakemake-workflows/dna-seq-varlociraptor/actions?query=branch%3Amaster+workflow%3ATests)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4675661.svg)](https://doi.org/10.5281/zenodo.4675661)


A Snakemake workflow for calling small and structural variants under any kind of scenario (tumor/normal, tumor/normal/relapse, germline, pedigree, populations) via the unified statistical model of [Varlociraptor](https://varlociraptor.github.io).



## Usage

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=snakemake-workflows%2Fdna-seq-varlociraptor).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) repository and its DOI (see above).
