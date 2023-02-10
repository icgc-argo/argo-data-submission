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
    Linda Xiang
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.7'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo/argo-data-submission.validate-seqtools'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir


// tool specific parmas go here, add / change as needed
params.json_file = ""
params.skippable_tests = []
params.files = ""


process validateSeqtools {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir ? true : false
 
  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path json_file
    path files
    val skippable_tests

  output:  // output, make update as needed
    path "validation_report.*.jsonl", emit: validation_log
    path "local_copy", emit: validated_payload

  script:
    // add and initialize variables here as needed

    """
    cp ${json_file} local_copy
    python3 /tools/main.py \
      -j local_copy \
      -k ${skippable_tests.join(" ")} \
      -t ${params.cpus} \
      > seq-tools.log 2>&1

    if ls validation_report.*.jsonl 1> /dev/null 2>&1; then
      if ls validation_report.INVALID*.jsonl 1> /dev/null 2>&1; then     
        echo "Payload is INVALID. Please check out details in validation report under: "
        pwd
        exit 1
      elif ls validation_report.UNKNOWN*.jsonl 1> /dev/null 2>&1;
      then
        echo "Payload is UNKNOWN. Please check out details in validation report under: "
        pwd
        exit 1
      else
        echo 0
      fi
    else
      cat seq-tools.log && exit 1
    fi
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  validateSeqtools(
    file(params.json_file),
    Channel.fromPath(params.files).collect(),
    params.skippable_tests
  )
}
