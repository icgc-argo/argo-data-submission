#!/usr/bin/env nextflow

/*
  Copyright (c) 2022, Your Organization Name

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    edsu7
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.0'  // package version

container = [
    'ghrc.io': 'ghrc.io/edsu7/argo-data-submission.generate-json'
]
default_container_registry = 'ghrc.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir


// tool specific parmas go here, add / change as needed
params.input_file = ""
params.output_pattern = "*"  // output file name pattern


process generateJson {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir
  errorStrategy 'terminate'
  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    val program_id
    val submitter_donor_id
    val gender
    val submitter_specimen_id
    val specimen_tissue_source
    val tumour_normal_designation
    val specimen_type
    val submitter_sample_id
    val sample_type
    val matchedNormalSubmitterSampleId
    val EGAX
    val EGAN
    val EGAR
    val EGAF
    path output_files
    path md5_files

  output:  // output, make update as needed
    path "*.json", emit: json_file

  script:
    """
    mkdir -p ${program_id}
    python3 /tools/main.py \\
    	--program_id '${program_id}' \\
    	--submitter_donor_id '${submitter_donor_id}' \\
        --gender '${gender}' \\
        --submitter_specimen_id '${submitter_specimen_id}' \\
        --specimen_tissue_source '${specimen_tissue_source}' \\
        --tumour_normal_designation '${tumour_normal_designation}' \\
        --specimen_type '${specimen_type}' \\
        --submitter_sample_id '${submitter_sample_id}' \\
        --sample_type '${sample_type}' \\
        --matchedNormalSubmitterSampleId '${matchedNormalSubmitterSampleId}' \\
        --EGAX '${EGAX}' \\
        --EGAN '${EGAN}' \\
        --EGAR '${EGAR}' \\
        --EGAF '${EGAF}' \\
        --EGAD '' \\
        --EGAD '' \\
        --output_files '${output_files}' \\
        --md5 '${md5_files}' \\
    	> generate_json.log 2>&1
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  generateJson(
    params.program_id,
    params.submitter_donor_id,
    params.gender,
    params.submitter_specimen_id,
    params.specimen_tissue_source,
    params.tumour_normal_designation,
    params.specimen_type,
    params.submitter_sample_id,
    params.sample_type,
    params.matchedNormalSubmitterSampleId,
    params.EGAX,
    params.EGAN,
    params.EGAR,
    params.EGAF,
    params.output_files,
    params.md5_files
  )
}

