import os
import glob


"""
default values for vembrane table

chromosome
position
reference allele
alternative allele
end position
event
id
symbol
gene
feature
impacthgvsp
hgvsg
consequence
canonical
revel
clinical significance
prob: het
prob: hom
prob: artifact
prob: absent
individual: allele frequency
individual: read depth
individual: short observations


"""

# get all files in folder ~/results/plugins and save them in a list
plugin_files = glob.glob(os.path.join(os.path.expanduser("~"), "results/plugins/*"))


# updated to allows for additional fields to be passed which will not have "ANN" added by default
def get_vembrane_config_expansion(wildcards, input):
    with open(input.scenario, "r") as scenario_file:
        scenario = yaml.load(scenario_file, Loader=yaml.SafeLoader)
    parts = ["CHROM, POS, REF, ALT, INFO['END'], INFO['EVENT'], ID"]
    header = [
        "chromosome, position, reference allele, alternative allele, end position, event, id"
    ]
    join_items = ", ".join

    config_output = config["tables"].get("output", {})

    def append_items(items, field_func, header_func):
        for item in items:
            parts.append(field_func(item))
            header.append(header_func(item))


    annotation_fields = [
        "SYMBOL",
        "Gene",
        "Feature",
        "IMPACT",
        "HGVSp",
        "HGVSg",
        "Consequence",
        "CANONICAL",
    ]

    # extend this out to include any additional fields that are passed in the config file which also have a vembrane custom type
    if "REVEL" in config["annotations"]["vep"]["plugins"]:
        annotation_fields.append("REVEL")
    if "LofTools" in config["annotations"]["vep"]["plugins"]:
        annotation_fields.append("LoFtool")

    annotation_fields.extend(
        [
            field
            for field in config_output.get("annotation_fields", [])
            if field not in annotation_fields
        ]
    )

    append_items(annotation_fields, "ANN['{}']".format, str.lower)
    append_items(["CLIN_SIG"], "ANN['{}']".format, lambda x: "clinical significance")

    samples = get_group_sample_aliases(wildcards)

    def append_format_field(field, name):
        append_items(
            samples, f"FORMAT['{field}']['{{}}']".format, f"{{}}: {name}".format
        )

    if config_output.get("event_prob", False):
        events = list(scenario["events"].keys())
        events += ["artifact", "absent"]
        append_items(events, lambda x: f"INFO['PROB_{x.upper()}']", "prob: {}".format)
    append_format_field("AF", "allele frequency")
    append_format_field("DP", "read depth")
    if config_output.get("short_observations", False):
        append_format_field("SOBS", "short observations")
    if config_output.get("observations", False):
        append_format_field("OBS", "observations")



    info_fields=
        [
            field
            for field in config_output.get("info_fields", [])
            if field not in info_fields and field not in annotation_fields
        ]

    # append_items(info_fields, "INFO['{}']".format, str)

    return {"expr": join_items(parts), "header": join_items(header)}













# vembrane table updated to allow for INFO fields ot be passed
rule vembrane_table:
    input:
        bcf="results/final-calls/{group}.{event}.fdr-controlled.normal-probs.bcf",
        scenario="results/scenarios/{group}.yaml",
    output:
        bcf="results/tables/{group}.{event}.fdr-controlled.tsv",
    conda:
        "../envs/vembrane.yaml"
    params:
        config=lambda wc, input: get_vembrane_config_expansion(wc, input),
    threads:
        1
    log:
        "logs/vembrane-table/{group}.{event}.log",
    shell:
        'vembrane table --header "{params.config[header]}" "{params.config[expr]}" '
        "{input.bcf} > {output.bcf} 2> {log}"


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
