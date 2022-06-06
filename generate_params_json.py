#!/usr/bin/env python3

import pandas as pd
import argparse
import json

def main():
    parser = argparse.ArgumentParser(description='Download files from EGA pyega3 server')
    parser.add_argument('-s', '--submitter_sample_id', dest="submitter_sample_id", help="Name of the ICGC project", required=True)
    parser.add_argument('-c', '--csv_file', dest="csv_file", help="EGA file name", required=True)
    parser.add_argument('-o', '--output_dir', dest='output_dir', help="Output file name", required=True)

    results = parser.parse_args()


    csv_df=pd.read_csv(results.csv_file,sep='\t')
    ind=csv_df[csv_df['submitter_sample_id']==results.submitter_sample_id].index.item()
    output_dict={}
    for col in [
    "program_id",
    "submitter_donor_id",
    "gender",
    "submitter_specimen_id",
    "specimen_tissue_source",
    "tumour_normal_designation",
    "specimen_type",
    "submitter_sample_id",
    "sample_type",
    "matchedNormalSubmitterSampleId",
    "EGAX",
    "EGAN",
    "EGAR",
    "EGAF",
    "json"]:
        if col in csv_df.columns.values.tolist():
            output_dict[col]=csv_df.loc[ind,col]
        else:
            output_dict[col]=""

    ###default values
    output_dict["method"]="Aspera"
    output_dict["download"]= {
    "song_url": "https://song.rdpc-qa.cancercollaboratory.org",
    "song_cpus": 2,
    "song_mem": 2,
    "score_url": "https://score.rdpc-qa.cancercollaboratory.org",
    "score_cpus": 3,
    "score_mem": 8
    }
    ###
    with open(results.output_dir+"/"+results.submitter_sample_id+".json", "w") as out_json:
        json.dump(output_dict,out_json,indent=2)
    
    print("Ensure the following environment variables to set or \"\":")
    print("ASCP_SCP_HOST\nASCP_SCP_USER\nASPERA_SCP_PASS\nPYEGA3_EGA_USER\nPYEGA3_EGA_PASS\n")
    print("To run:")
    print(
        "nextflow "+\
        "main.nf "+\
        "-params-file "+results.output_dir+"/"+results.submitter_sample_id+".json"
    )

if __name__ == '__main__':
    main()
