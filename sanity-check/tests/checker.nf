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
version = '0.1.3'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo/argo-data-submission.sanity-check'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.song_url="https://submission-song.rdpc-qa.cancercollaboratory.org/"
params.clinical_url="https://clinical.qa.argo.cancercollaboratory.org"
params.api_token=""
params.experiment_info_tsv="NO_FILE1"
params.skip_sanity_check="NO_FILE2"
params.expected_output="NO_FILE3"

include { sanityCheck } from '../main'


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

    diff ${output_file} ${output_file} \
      && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}


workflow checker {
  take:
    experiment_info_tsv
    api_token
    song_url
    clinical_url
    skip_sanity_check
    expected_output

  main:
  sanityCheck(
    file(experiment_info_tsv),
    api_token,
    song_url,
    clinical_url,
    skip_sanity_check
  )

    file_smart_diff(
      sanityCheck.out.updated_experiment_info_tsv,
      file(expected_output)
    )
}


workflow {
  checker(
    params.experiment_info_tsv,
    params.api_token,
    params.song_url,
    params.clinical_url,
    params.skip_sanity_check,
    params.expected_output
  )
}
