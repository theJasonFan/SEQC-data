import pandas as pd
import os

SEQC_meta = 'output/seqc_meta.tsv'
SEQC_meta = pd.read_csv(SEQC_meta, sep='\t')

# DEBUG remove block to download all data
MAX_LANES = 3
MAX_FC = 1
SEQC_meta = SEQC_meta[SEQC_meta['Lane'] <= MAX_LANES]
SEQC_meta = SEQC_meta[SEQC_meta['Flowcell_ID'] <=  MAX_FC]
# DEBUG remove block to download all data


output_1_fmt = 'output/by_lane/{sample_name}/{sample_name}_1.gz'
output_2_fmt = 'output/by_lane/{sample_name}/{sample_name}_2.gz'

sample_to_url_1 = {}
sample_to_url_2 = {}

for i, row in SEQC_meta.iterrows():
    fmt = '{site}_FC{fc_id}_{sample}_{rep}_L{lane}'
    name = fmt.format(site=row['Site'],
                      fc_id=row['Flowcell_ID'],
                      sample=row['Sample'],
                      rep=row['Replicate'],
                      lane=row['Lane'])
    sample_to_url_1[name] = row['URL_1']
    sample_to_url_2[name] = row['URL_2']

rule download:
    input:
        expand(output_1_fmt, sample_name=sample_to_url_1.keys()),
        expand(output_2_fmt, sample_name=sample_to_url_2.keys())


rule download_1:
    output:
        output_1_fmt
    params:
        url = lambda w: sample_to_url_1[w.sample_name]
    shell:
        '''
        wget -O {output} {params.url}
        '''
rule download_2:
    output:
        output_2_fmt
    params:
        url = lambda w: sample_to_url_2[w.sample_name]
    shell:
        '''
        wget -O {output} {params.url}
        '''

# Build a by_fc to lanes [list] dictionary
by_fc_name = 'output/by_fc/{site}_FC{fc_id}_{sample}_{rep}/{site}_FC{fc_id}_{sample}_{rep}_{end}.gz'
by_lane_input = 'output/lane/{site}_FC{fc_id}_{sample}_{rep}_L{lane}/{site}_FC{fc_id}_{sample}_{rep}_L{lane}_{{end}}.gz'

by_fc_df = SEQC_meta.groupby(['Site', 'Flowcell_ID', 'Sample', 'Replicate'])['Lane'].max()

by_fc_name_2_lanes = {}

for keys, n_lanes in by_fc_df.iteritems():
    _site, _fc_id, _sample, _rep = keys
    by_fc_name_1 = by_fc_name.format(site=_site, fc_id=_fc_id, sample=_sample, rep=_rep, end=1)
    by_fc_name_2 = by_fc_name.format(site=_site, fc_id=_fc_id, sample=_sample, rep=_rep, end=2)
    by_lane_input = 'output/by_lane/{site}_FC{fc_id}_{sample}_{rep}_L{{lane}}/{site}_FC{fc_id}_{sample}_{rep}_L{{lane}}_{{end}}.gz'.format(
        site=_site, fc_id=_fc_id, sample=_sample, rep=_rep,
    )
    by_fc_name_2_lanes[by_fc_name_1] = [by_lane_input.format(lane=l+1, end=1) for l in range(n_lanes)]
    by_fc_name_2_lanes[by_fc_name_2] = [by_lane_input.format(lane=l+1, end=2) for l in range(n_lanes)]

print(by_fc_name_2_lanes)

rule by_fc:
    input:
        sorted(list(by_fc_name_2_lanes.keys()))

rule _by_fc:
    output:
        'output/by_fc/{name}/{name}_{end}.gz'
    input:
        lambda w: by_fc_name_2_lanes['output/by_fc/{name}/{name}_{end}.gz'.format(name=w.name, end=w.end)]
    shell:
        '''
        cat {input} > {output}
        '''
