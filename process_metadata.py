import pandas as pd
import argparse

import yaml

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', nargs='+', required=True)
    parser.add_argument('-o', '--output', required=True)
    parser.add_argument('-s', '--summary', required=True)
    return parser.parse_args()

def process_meta_tsv(fp):
    raw_df = pd.read_csv(fp, sep='\t')
    one, two = None, None

    df = pd.DataFrame()
    for i, row in raw_df.iterrows():

        if i % 2 == 0:
            one = row
        else:
            two = row

        if i % 2 == 1:
            # Flush the buffer and write the sample to new DF
            df = df.append(extract_rows_info(one, two), ignore_index=True)

    # insert flowcell IDs
    unique_fc_barcodes = sorted(df['Flowcell_barcode'].unique())
    fc_to_id = dict((n, i+1) for i, n in enumerate(unique_fc_barcodes))
    fc_ids = df['Flowcell_barcode'].map(fc_to_id)
    df['Flowcell_ID'] = fc_ids

    return df

def extract_rows_info(one, two):
    assert(one['Accession'] == two['Accession'])

    # fmt = '{GSM}: SEQC_{Platform}_{Site}_{Condition}_{replicate}_L{lane}_{FC_barcode}'

    fields = one['SRA nice filename'].split('_')

    acc = one['Accession']
    platform = fields[3]
    site = fields[4]
    sample = fields[5]
    replicate = int(fields[6])
    lane = int(fields[7][1:])
    tag = fields[8]
    fc_barcode = fields[9]

    url1 = one['FastQ URL']
    url2 = two['FastQ URL']

    meta = {
        'Accession': acc,
        'Platform': platform,
        'Site': site,
        'Replicate': replicate,
        'Sample': sample,
        'Lane': lane,
        'Tag': tag,
        'Flowcell_barcode': fc_barcode,
        'URL_1': url1,
        'URL_2': url2,
    } 

    return meta


def summarize(df):

    df = df.groupby('Site').nunique()
    return df

def main():
    args = parse_args()

    meta_files = args.input

    dfs = [process_meta_tsv(f) for f in meta_files]
    df = pd.concat(dfs)

    df['Replicate'] = df['Replicate'].astype(int)
    df['Lane'] = df['Lane'].astype(int)

    cols_ordered = [
        'Site',
        'Sample',
        'Flowcell_ID',
        'Replicate',
        'Lane',
        'Platform',
        'Tag',
        'Flowcell_barcode',
        'URL_1',
        'URL_2']

    df = df[cols_ordered]
    df = df.sort_values(cols_ordered)
    df.to_csv(args.output, index=False, sep='\t')
    
    summary = summarize(df)
    summary.to_csv(args.summary, index=True, sep='\t')


if __name__ == "__main__":
    main()