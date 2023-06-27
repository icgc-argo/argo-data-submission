#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
  Copyright (C) 2022,  icgc-argo

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  Authors:
    Edmund Su
"""

import os
import sys
import argparse
import csv
import json
import re


def main():
    """
    Python implementation of tool: payload-json-to-tsvs

    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Tool: payload-json-to-tsvs')
    parser.add_argument('-j', '--json', dest='json_file', type=str,
                        help='JSON file', required=True)
    parser.add_argument('-d', '--data', dest='data_directory', type=str,
                        help='Data directory', required=True)
    args = parser.parse_args()

    if not os.path.isfile(args.json_file):
        sys.exit('Error: Specified input file %s does not exist or is not accessible!' % args.json_file)

    if not os.path.isdir(args.data_directory):
        sys.exit('Error: Specified data directory %s does not exist or is not accessible!' % args.data_directory)

    metadata=read_json(args.json_file)
    make_experiment_tsv(metadata)
    make_file_tsv(metadata,args.data_directory)
    make_read_group_tsv(metadata)

def read_json(json_file):
    with open(json_file, 'r') as file:
        metadata=json.load(file)
    
    return metadata

def make_experiment_tsv(metadata):
    if metadata.get("samples") and metadata.get("experiment"):
        return_metadata={}
        return_metadata['type']='sequencing_experiment'
        ### Donor
        for field in [ 'submitter_donor_id', 'gender']:
            return_metadata[field]=metadata['samples'][0]['donor'].get(re.sub(r'_[a-z]', lambda x : x[0].upper().replace("_",""), field)) if \
                metadata['samples'][0]['donor'].get(re.sub(r'_[a-z]', lambda x : x[0].upper().replace("_",""), field))  \
                else None
        ### Specimen
        for field in ['submitter_specimen_id', 'tumour_normal_designation', 'specimen_type', 'specimen_tissue_source']:
            return_metadata[field]=metadata['samples'][0]['specimen'].get(re.sub(r'_[a-z]', lambda x : x[0].upper().replace("_",""), field)) if \
                metadata['samples'][0]['specimen'].get(re.sub(r'_[a-z]', lambda x : x[0].upper().replace("_",""), field))  \
                else None
        ### Sample
        for field in ['submitter_sample_id','sample_type', 'submitter_matched_normal_sample_id']:
            return_metadata[field]=metadata['samples'][0].get(re.sub(r'_[a-z]', lambda x : x[0].upper().replace("_",""), field)) if \
                metadata['samples'][0].get(re.sub(r'_[a-z]', lambda x : x[0].upper().replace("_",""), field)) \
                else None
        ### Experiment

        for field in [
            'submitter_sequencing_experiment_id','sequencing_center',
            'platform', 'platform_model','experimental_strategy', 'sequencing_date',
            "library_preparation_kit","library_strandedness","rin","dv200",
            "primary_target_regions","capture_target_regions","number_of_genes",
            "gene_padding","coverage","target_capture_kit"]:
                return_metadata[field]=metadata['experiment'].get(field) if metadata['experiment'].get(field) else None  
        
        return_metadata['program_id']=metadata.get("studyId")
        return_metadata['read_group_count']=metadata.get("read_group_count")
        with open("experiment.tsv", 'w', newline='') as csvfile:
            fieldnames = return_metadata.keys()
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames,delimiter='\t')
            writer.writeheader()   
            writer.writerow(return_metadata)
    else:
        sys.exit("Error payload does not contain experiments.")

def make_file_tsv(metadata,data_directory):
    fields=['name', 'size', 'md5sum']
    ega_fields=[
    "ega_file_id",
    "ega_dataset_id",
    "ega_experiment_id",
    "ega_sample_id",
    "ega_study_id",
    "ega_run_id",
    "ega_policy_id",
    "ega_analysis_id",
    "ega_submission_id",
    "ega_dac_id"]

    total_fields=fields+ega_fields+['path','type',"format"]

    if metadata.get("files"):
        return_metadata={}
        return_metadata['type']='sequencing_experiment'
        ### Donor
        for field in [ 'submitter_donor_id', 'gender']:
            if metadata['samples'][0]['donor'].get("field"):
                return_metadata[field]=metadata['samples'][0]['donor'].get("field") 
 
        with open("files.tsv", 'w', newline='') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=total_fields,delimiter='\t')
            writer.writeheader()

            for file in metadata['files']:
                return_metadata={}
                return_metadata['type']='file'
                return_metadata['format']=file.get("fileType") if file.get("fileType") else None
                for field in fields:
                    return_metadata[field]=file.get("file"+field.capitalize()) if file.get("file"+field.capitalize()) else None
                if file['info'].get('ega'):
                    for field in ega_fields:
                        return_metadata[field]=file['info']['ega'].get(field) if file['info']['ega'].get(field) else None

                return_metadata['path']=data_directory+"/"+return_metadata['name']
                writer.writerow(return_metadata)
    else:
        sys.exit("Error payload does not contain files.")


def make_read_group_tsv(metadata):

    fields=['submitter_read_group_id', 'read_group_id_in_bam', 'submitter_sequencing_experiment_id', 'platform_unit',
    'is_paired_end', 'file_r1', 'file_r2', 'read_length_r1', 'read_length_r2', 'insert_size', 'sample_barcode', 'library_name'
    ]

    if metadata.get("read_groups"):
        with open("read_groups.tsv", 'w', newline='') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fields+['type'],delimiter='\t')
            writer.writeheader()

            for read_group in metadata['read_groups']:
                return_metadata={}
                return_metadata['type']='read_group'
                for field in fields:
                    return_metadata[field]=read_group.get(field) if read_group.get(field) else None

                writer.writerow(return_metadata)
    else:
        sys.exit("Error payload does not contain read groups.")

if __name__ == "__main__":
    main()

