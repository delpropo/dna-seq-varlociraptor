rule get_sra:
    output:
        "sra/{accession}_1.fastq.gz",
        "sra/{accession}_2.fastq.gz",
    log:
        "logs/get-sra/{accession}.log",
    threads: 1
    wrapper:
        "v1.2.0/bio/sra-tools/fasterq-dump"


rule cutadapt_pipe:
    input:
        get_cutadapt_pipe_input,
    output:
        pipe("pipe/cutadapt/{sample}/{unit}.{fq}.{ext}"),
    log:
        "logs/pipe-fastqs/catadapt/{sample}-{unit}.{fq}.{ext}.log",
    wildcard_constraints:
        ext=r"fastq|fastq\.gz",
    threads: 0  # this does not need CPU
    shell:
        "cat {input} > {output} 2> {log}"


rule cutadapt_pe:
    input:
        get_cutadapt_input,
    output:
        fastq1="results/trimmed/{sample}/{unit}_R1.fastq.gz",
        fastq2="results/trimmed/{sample}/{unit}_R2.fastq.gz",
        qc="results/trimmed/{sample}/{unit}.paired.qc.txt",
    log:
        "logs/cutadapt/{sample}-{unit}.log",
    params:
        extra=config["params"]["cutadapt"],
        adapters=get_cutadapt_adapters,
    threads: 8
    wrapper:
        "v1.12.0/bio/cutadapt/pe"


rule cutadapt_se:
    input:
        get_cutadapt_input,
    output:
        fastq="results/trimmed/{sample}/{unit}.single.fastq.gz",
        qc="results/trimmed/{sample}/{unit}.single.qc.txt",
    log:
        "logs/cutadapt/{sample}-{unit}.se.log",
    params:
        extra=config["params"]["cutadapt"],
        adapters=get_cutadapt_adapters,
    threads: 8
    wrapper:
        "v1.12.0/bio/cutadapt/se"


rule merge_fastqs:
    input:
        get_fastqs,
    output:
        "results/merged/{sample}_{read}.fastq.gz",
    log:
        "logs/merge-fastqs/{sample}_{read}.log",
    wildcard_constraints:
        read="single|R1|R2",
    threads: 1
    shell:
        "cat {input} > {output} 2> {log}"
