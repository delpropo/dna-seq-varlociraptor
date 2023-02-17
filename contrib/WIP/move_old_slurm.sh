# script to move old slurm logs and save the job id
mkdir -p ./out_slurm
ls | grep -P slurm.*.out$ | grep -Po '([0-9]{7,10})' >> job_id_list.txt
ls | grep -P slurm.*.out$ | xargs -I {} mv {} ./out_slurm

