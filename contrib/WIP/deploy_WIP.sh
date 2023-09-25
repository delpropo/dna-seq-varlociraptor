# Author: Jim Delproposto
# Date: 2023-01-16
# WIP for deploying workflow

# check if conda is installed
if ! command -v conda &> /dev/null
then
    echo "conda could not be found"
    exit
fi

# exit if the conda environment already exists
if conda env list | grep -q varloc_env; then
    echo "Conda environment already exists."
    
fi

# check to see if the conda environment exists
if ! conda env list | grep -q varloc_env; then
    echo "Creating conda environment"
    conda create -n varloc_env
    conda activate varloc_env

fi

# install mamba, snakedeploy and snakemake
conda install -c conda-forge mamba
mamba install -c bioconda snakedeploy snakemake


# check if a directory exists and exit if it does
if [ -d "varlociraptor" ]; then
    echo "Directory varlociraptor already exists. Exiting."
    exit 1
fi

# make a directory for the workflow if it doesn't exist
mkdir -p varlociraptor
cd varlociraptor

# download the workflow
# snakedeploy deploy-workflow https://github.com/snakemake-workflows/dna-seq-varlociraptor . --tag v3.19.3
snakedeploy deploy-workflow https://github.com/delpropo/dna-seq-varlociraptor . --tag master


# download bash script https://github.com/delpropo/Umich_HPC/blob/main/snakemake_on_the_cluster/scripts/nonslurm_dryrun.sh
wget https://raw.githubusercontent.com/delpropo/Umich_HPC/main/snakemake_on_the_cluster/scripts/nonslurm_dryrun.sh

