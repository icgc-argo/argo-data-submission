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
    Edmund Su
*/

nextflow.enable.dsl = 2
version = '0.1.0'  // package version

// universal params go here, change default value as needed
params.container = ""
params.container_registry = ""
params.container_version = ""
params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir

// tool specific parmas go here, add / change as needed
params.cleanup = true

params.registered_samples=''
params.method=''
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
params.json=''
params.c4gh_secret_key='NO_FILE'
params.aspera_file='NO_FILE'
params.song_url= ''
params.score_url=''
params.analysis_id = ""

params.max_retries = 5  // set to 0 will disable retry
params.first_retry_wait_time = 1  // in seconds

params.api_token=''
params.song_cpus = 1
params.song_mem = 1  // GB
params.song_url = "https://song.rdpc-qa.cancercollaboratory.org"
params.song_api_token = ""
params.song_container_version = "4.2.1"

params.score_cpus = 1
params.score_mem = 1  // GB
params.score_transport_mem = 1  // GB
params.score_url = "https://score.rdpc-qa.cancercollaboratory.org"
params.score_api_token = ""
params.score_container_version = "5.0.0"

SongScoreUpload_params = [
    'max_retries': params.max_retries,
    'first_retry_wait_time': params.first_retry_wait_time,
    'cpus': params.cpus,
    'mem': params.mem,
    'song_url': params.song_url,
    'score_url': params.score_url,
    'api_token': params.api_token,
    *:(params.SongScoreUpload ?: [:])
]

include { SongScoreUpload } from "./wfpr_modules/nextflow-data-processing-utility-tools/song-score-upload@2.6.1/main.nf" params(SongScoreUpload_params)
include { downloadAspera } from "./wfpr_modules/download-aspera/main.nf"
include { downloadPyega3 } from "./wfpr_modules/download-pyega3/main.nf"
include { generateJson } from "./wfpr_modules/generate-json/main.nf"
include { decryptAspera } from "./wfpr_modules/decrypt-aspera/main.nf"
include { differentiateJson } from "./wfpr_modules/differentiate-json/main.nf"

workflow ArgoDataSubmissionWf {
  take:
    method
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
    json
    aspera_file
    c4gh_secret_key
    
  main:
    EGAF_list=Channel.from(EGAF.split(","))
    if (method.toLowerCase() == 'aspera') {
      aspera_file_list = Channel.from(aspera_file.split(","))
      downloadAspera(aspera_file_list,EGAF_list,program_id)
      decryptAspera(downloadAspera.out.output_files,c4gh_secret_key)
      output_files=decryptAspera.out.output_files.collect()
      output_md5=decryptAspera.out.md5_file.collect()
    } else {
      downloadPyega3(EGAF_list,program_id)
      output_files=downloadPyega3.out.output_files.collect()
      output_md5=downloadPyega3.out.md5_file.collect()
    }    
    
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
      output_files,
      output_md5
    )

    if (json){
      differentiateJson(json,generateJson.out.json_file)
      output_json=json
    } else {
      output_json=generateJson.out.json_file
    }


    SongScoreUpload(
      program_id,
      output_json,
      output_files
    )
  
    emit:
      json_file=output_json
      output_files
      output_analysis_id=SongScoreUpload.out.analysis_id
}

// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  ArgoDataSubmissionWf(
    params.method,
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
    params.json,
    params.aspera_file,
    params.c4gh_secret_key
  )
}
