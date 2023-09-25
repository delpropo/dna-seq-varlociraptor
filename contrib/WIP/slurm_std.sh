#!/bin/bash

# Test for gatk
# -s
# --rerun-incomplete \
# --use-envmodules \
# --keep-going
# --set-threads cutadapt_pipe=1
# -c all
# -c 1 and -c 2 causes error because of not enough resources
# sou rc   e /etc/profile.d/http_proxy.sh no impact
# removed --use-conda and latency-wait
# removed --set-threads cutadapt_pipe=1
# could add --mem {resources.mem_mb}
# testing out --get-user-env  did not have an impact
# testing removing --nodes=1 did not have an impact
# testing trade nodes=1 with --ntasks-per-node=1.  failed
# change to fewer threads for bwa mem = 2
# 12-7-22 might be able to add souce ~/.bashrc instead of sbatch --get-user-env
# could also try sbatch --export=NONE to remove all set/exported variables

# set-threads map_reads=4

# running this kills the bash shell
# source /home/delpropo/miniconda3/etc/profile.d/conda.sh

# export PATH="/home/delpropo/miniconda3/etc/profile.d/conda.sh"
source /home/delpropo/.bashrc

#export PATH="/home/delpropo/miniconda3/etc/profile.d/mamba.sh"
# conda activate v2_env
export TMPDIR=/scratch/margit_root/margit0
# s ource /etc/profile.d/http_proxy.sh
# can also try --set-resources mark_duplicates:mem-per-cpu=20g
# might need to do both mem_mb and disk_mb?  both were added but no impact
# testing threads since samtools uses them
# test 2 threads then 1 thread set-threads mark_duplicates=1
# --set-resources mark_duplicates:mem_mb=50000 mark_duplicates:disk_mb=50000
# reducing the resources worked.  --set-resources mark_duplicates:mem_mb=4000 mark_duplicates:disk_mb=4000
# standard storage is 480 gB SSD + 4TB HDD.  Large mem is 4TB HDD.  might be necessary to switch node type with very large files.
# --set-resources mark_duplicates:mem_mb=5000 mark_duplicates:disk_mb=5000 bam_index:mem_mb=5000 bam_index:disk_mb=5000 \

# issues with bam_index
#  use-conda-env didn't work
# defining threads, set resources mem_mb, bam_index, tmp_dir didnt work
# --detailed-summary didn't help much
#  Worked with removing out and error for this specific rule  bam_index


# varlociraptor_alignment_properties out of memory
# uses javea and defined memory of 200gb
# --set-resources varlociraptor_alignment_properties:mem_mb=4000 varlociraptor_alignment_properties:disk_mb=4000
# increased varlociraptor_alignment_properties disk_mb to varlociraptor_alignment_properties:disk_mb=50000
# remove disk_mb
# nothing wrong with the memory.  The command works file when not in slurm.  It has to do with running slurm with a > redirect.  possibly instead of >>?
#  add back --output which was removed with --error for samtools index issues which is a wrapper whereas varlociraptor_alignment_properties uses a shell directly
# samtools index is wrapper to shell
# varlociraptor_alignment_properties is a rule which uses shell
# adding --output to logs/{rule}.wildcards}.o didn't work
# try --output=/dev/null --error=/dev/null didn't work either
# try . /home/delpropo/miniconda/etc/profile.d/conda.sh      This didn't work
#. /home/delpropo/miniconda3/etc/profile.d/conda.sh
# try running source /home/delpropo/.bashrc instead of ~/.bashrc .  This also failed
# try set -e since this would not be executed
#  attempted to run without tmux but still had issue
#  changing memory per cpu to 7gb even though there is no indication that memory is the issue.
#  This solved the issue.  Discussed this with HITS

# varlociraptor_call failures
# --set-resources varlociraptor_call:mem_mb=4000 varlociraptor_call:disk_mb=4000
# set resources didn't have an impact
# removed -output logs/{rule}.{wildcards}.o and  --error logs/{rule}.{wildcards}.e which caused an issue with bam_index

# to overcome mark_duplicate failures, manually changing cpus-per-task from {threads} to 5 or more may be necessary  
# This is because mark_duplicates doesn't call threads so set-threads mark_duplicates=5 does appear not work.  Calls through shell.
# This is more of a memory issue than a cpu issue since it is single threaded 

# modified so that max threads are 20 rather than having specific rules be set-threads

# --cores all \
#  --rerun-triggers mtime



snakemake \
    --cores all \
    --rerun-triggers mtime \
    --latency-wait 60 \
    --dry-run \
    --jobs 10 \
    --use-conda \
    --set-resources mark_duplicates:mem_mb=4000 mark_duplicates:disk_mb=4000       \
    --set-resources varlociraptor_call:mem_mb=4000 varlociraptor_call:disk_mb=4000 \
    --set-threads vembrane_table=3 \
    --set-threads datavzrd_variants_calls=2 \
    --max-threads 20 \
    --printshellcmds \
    --verbose   \
    --rerun-incomplete \
    --cluster '
        sbatch \
        --account=margit0 \
        --partition=standard \
        --cpus-per-task {threads} \
        --nodes=1         \
        --mem-per-cpu=7g \
        --verbose \
        --time=72:00:00 '
        # --output logs/{rule}.{wildcards}.o \
        # --error logs/{rule}.{wildcards}.e '
        # --time=48:00:00
	#--output logs/
	    #--output logs/{rule}.{wildcards}.o \
        #  --error logs/{rule}.{wildcards}.e '
 	  # --mail-type=begin \
	  # --mail-type=end \
    	  # --mail-type=fail \
          # --mail-user=delpropo@umich.edu ' \
