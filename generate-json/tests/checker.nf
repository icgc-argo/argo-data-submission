#!/usr/bin/env nextflow

/*
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
*/

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo/argo-data-submission.generate-json'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.input_file = ""
params.expected_output = ""

include { generateJson } from '../main'

params.program_id=''
params.submitter_donor_id=''
params.gender=''
params.submitter_specimen_id=''
params.specimen_tissue_source=''
params.tumour_normal_designation=''
params.specimen_type=''
params.submitter_sample_id=''
params.sample_type=''
params.matched_normal_submitter_sample_id=''
params.EGAX=''
params.EGAN=''
params.EGAR=''
params.EGAF=''
params.experimental_strategy=''
params.EGAD=''
params.EGAS=''
params.output_files=''
params.md5_files=''

process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_file
    path expected_file

  output:
    stdout()

  script:
    """
    # Note: this is only for demo purpose, please write your own 'diff' according to your own needs.
    # in this example, we need to remove date field before comparison eg, <div id="header_filename">Tue 19 Jan 2021<br/>test_rg_3.bam</div>
    # sed -e 's#"header_filename">.*<br/>test_rg_3.bam#"header_filename"><br/>test_rg_3.bam</div>#'
    diff ${output_file} ${expected_file} \
      && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}


workflow checker {
  take:
    program_id
    submitter_donor_id
    gender
    submitter_specimen_id
    specimen_tissue_source
    tumour_normal_designation
    specimen_type
    submitter_sample_id
    sample_type
    matched_normal_submitter_sample_id
    EGAX
    EGAN
    EGAR
    EGAF
    experimental_strategy
    EGAD
    EGAS
    output_files
    md5_files
    expected_output

  main:
    generateJson(
      program_id,
      submitter_donor_id,
      gender,
      submitter_specimen_id,
      specimen_tissue_source,
      tumour_normal_designation,
      specimen_type,
      submitter_sample_id,
      sample_type,
      matched_normal_submitter_sample_id,
      EGAX,
      EGAN,
      EGAR,
      EGAF,
      experimental_strategy,
      EGAD,
      EGAS,
      Channel.fromPath(output_files).collect(),
      Channel.fromPath(md5_files).collect()
    )

    file_smart_diff(
      generateJson.out.json_file,
      file(expected_output)
    )
}


workflow {
  checker(
    params.program_id,
    params.submitter_donor_id,
    params.gender,
    params.submitter_specimen_id,
    params.specimen_tissue_source,
    params.tumour_normal_designation,
    params.specimen_type,
    params.submitter_sample_id,
    params.sample_type,
    params.matched_normal_submitter_sample_id,
    params.EGAX,
    params.EGAN,
    params.EGAR,
    params.EGAF,
    params.experimental_strategy,
    params.EGAD,
    params.EGAS,
    params.output_files,
    params.md5_files,
    params.expected_output
  )
}
