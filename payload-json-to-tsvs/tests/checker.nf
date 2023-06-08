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
version = '0.1.2'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo/argo-data-submission.payload-json-to-tsvs'
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

include { payloadJsonToTsvs } from '../main'


process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
      path experiment_tsv
      path file_tsv
      path read_group_tsv
      path expected_experiment_tsv
      path expected_file_tsv
      path expected_read_group_tsv

  output:
    stdout()

  script:
    """
    # Note: this is only for demo purpose, please write your own 'diff' according to your own needs.
    # in this example, we need to remove date field before comparison eg, <div id="header_filename">Tue 19 Jan 2021<br/>test_rg_3.bam</div>
    # sed -e 's#"header_filename">.*<br/>test_rg_3.bam#"header_filename"><br/>test_rg_3.bam</div>#'

    diff ${experiment_tsv} ${expected_experiment_tsv} \
      && (echo "Experiment TSVs match!") || ( echo "Experiment output file mismatch." && exit 1 )

    diff ${file_tsv} ${expected_file_tsv} \
      && (echo "File TSVs match!") || ( echo "File output file mismatch." && exit 1 )

    diff ${read_group_tsv} ${read_group_tsv} \
      && (echo "Read group TSVs match!") || ( echo "Read group output file mismatch." && exit 1 )

    exit 0
    """
}


workflow checker {
  take:
    json_file
    data_directory
    expected_experiment_tsv
    expected_file_tsv
    expected_read_group_tsv

  main:
    payloadJsonToTsvs(
      file(json_file),
      file(data_directory)
    )

    file_smart_diff(
      payloadJsonToTsvs.out.experiment_tsv,
      payloadJsonToTsvs.out.file_tsv,
      payloadJsonToTsvs.out.read_group_tsv,
      file(expected_experiment_tsv),
      file(expected_file_tsv),
      file(expected_read_group_tsv),
    )
}


workflow {
  checker(
    params.json_file,
    params.data_directory,
    params.expected_experiment_tsv,
    params.expected_file_tsv,
    params.expected_read_group_tsv
  )
}
