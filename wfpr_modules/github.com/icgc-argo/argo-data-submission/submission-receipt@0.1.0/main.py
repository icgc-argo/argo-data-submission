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

import argparse
import requests
import json
import csv
import sys
import json

def main():
    """
    Python implementation of tool: sanity-check
    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Tool: sanity-check')
    parser.add_argument('-s', '--study_id', dest='study_id',type=str,
                        help='Study ID used for querying', required=True)
    parser.add_argument('-a', '--analysis_id', dest='analysis_id',type=str,
                        help='Analysis ID (UUID) to query', required=True)
    parser.add_argument('-u', '--submission_song_url', dest='submission_song_url',type=str,
                        help='Submission SONG API URL', required=True)
    parser.add_argument('-f', '--files', dest='files',nargs='+',type=str,
                        help='List of files to verify against analysis ID', required=True)
    parser.add_argument('-o', '--output_file', dest='output_file',type=str,
                        help='Destination/Name of output', required=True)
    parser.add_argument('-k', '--skip_check', dest='skip_check',action='store_true',
                        help='Skip check of provided files against submitted analysis')
    args = parser.parse_args()

    header={"accept":"*/*"}
    url=args.submission_song_url+"/studies/%s/analysis/%s" % (args.study_id,args.analysis_id)
    try:
        response=requests.get(url,headers=header)
    except requests.exceptions.RequestException as e:  # This is the correct syntax
        print("Unable to establish connection")
        raise SystemExit(e)

    if response.status_code==200:
        with open(args.output_file, 'w', newline='') as csvfile:
            metadata={
                "analysisState":None,
                'publishedAt':None,
                'submitterSampleId':None,
                'submitterSpecimenId':None,
                'submitterDonorId':None,
                'sampleId':None,
                'specimenId':None,
                "donorId":None,
                "analysisId":None,
                "studyId":None,
                "objectId":None,
                "fileName":None,
                "fileMd5sum":None,
                "fileSize":None
                }

            for file in response.json()['files']:
                if file['info'].get("original_cram_info"):
                    metadata["original_fileName"]=None
                    metadata["original_fileMd5sum"]=None
                    metadata["original_fileSize"]=None
    
            fieldnames = metadata.keys()
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames,delimiter='\t')
            writer.writeheader()

            if not args.skip_check:
                for file in args.files:
                    if file not in [z['fileName'] for z in response.json()['files']]:
                        sys.exit("Supplied file %s was not found in the analysis." % (file))
                for file in response.json()['files']:
                    if file['fileName'] not in args.files:
                        sys.exit("The file %s from %s was not found in supplied files." % (file['fileName'],args.analysis_id))

            for file in response.json()['files']:              
                metadata={
                "analysisState":response.json()['analysisState'],
                'publishedAt':response.json()['publishedAt'],
                'submitterSampleId':response.json()['samples'][0]['submitterSampleId'],
                'submitterSpecimenId':response.json()['samples'][0]['specimen']['submitterSpecimenId'],
                'submitterDonorId':response.json()['samples'][0]['donor']['submitterDonorId'],
                'sampleId':response.json()['samples'][0]['sampleId'],
                'specimenId':response.json()['samples'][0]['specimen']['specimenId'],
                "donorId":response.json()['samples'][0]['donor']['donorId'],
                "analysisId":args.analysis_id,
                "studyId":args.study_id,
                "objectId":file['objectId'],
                "fileName":file['fileName'],
                "fileMd5sum":file['fileMd5sum'],
                "fileSize":file['fileSize']
                }

                if file['info'].get("original_cram_info"):
                    metadata["original_fileName"]=file['info']['original_cram_info']['fileName']
                    metadata["original_fileMd5sum"]=file['info']['original_cram_info']['fileMd5sum']
                    metadata["original_fileSize"]=file['info']['original_cram_info']['fileSize']

                writer.writerow(metadata)
    else:
        sys.exit("analysis %s in study %s could not be found" % (args.analysis_id,args.study_id))

if __name__ == "__main__":
    main()

