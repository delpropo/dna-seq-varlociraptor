rule vembrane_table:
    input:
        bcf="results/final-calls/{group}.{event}.{calling_type}.fdr-controlled.normal-probs.bcf",
        scenario="results/scenarios/{group}.yaml",
    output:
        bcf="results/tables/{group}.{event}.{calling_type}.fdr-controlled.tsv",
    conda:
        "../envs/vembrane.yaml"
    params:
        config=lambda wc, input: get_vembrane_config(wc, input),
    threads:
        1
    log:
        "logs/vembrane-table/{group}.{event}.{calling_type}.log",
    shell:
        'vembrane table --header "{params.config[header_presort]}" "{params.config[expr_presort]}" '
        '{input.bcf} > {output.bcf} 2> {log} '
        # Modified params.config to use header_presort.




rule tsv_to_excel:
    input:
        tsv="results/{x}.tsv",
    output:
        xlsx="results/{x}.xlsx",
    conda:
        "../envs/excel.yaml"
    threads:
        1
    log:
        "logs/tsv_to_xlsx/{x}.log",
    script:
        "../scripts/tsv_to_xlsx.py"
