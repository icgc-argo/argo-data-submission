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

// ArgoDataSubmissionWf
params.download_mode="local"
params.study_id="TEST-PR"

// payloadGenSeqExperiment
params.schema_url="https://submission-song.rdpc.cancercollaboratory.org/schemas/sequencing_experiment"
params.experiment_info_tsv="NO_FILE1"
params.read_group_info_tsv="NO_FILE2"
params.file_info_tsv="NO_FILE3"
params.extra_info_tsv="NO_FILE4"

// downloadPyega3
params.pyega3_ega_user=""
params.pyega3_ega_pass=""

// downloadAspera
params.ascp_scp_host=""
params.ascp_scp_user=""
params.aspera_scp_pass=""

// DecryptAspera
params.c4gh_pass_phrase=""
params.c4gh_secret_key="NO_FILE5"

// SongScoreUpload
params.SongScoreUpload = [:]
params.max_retries = 5  // set to 0 will disable retry
params.first_retry_wait_time = 1  // in seconds
// SONG
params.api_token=''
params.song_cpus = 1
params.song_mem = 1  // GB
params.song_url = "https://song.rdpc-qa.cancercollaboratory.org"
params.song_api_token = ""
params.song_container_version = "4.2.1"
// SCORE
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

include { SongScoreUpload } from './wfpr_modules/github.com/icgc-argo/nextflow-data-processing-utility-tools/song-score-upload@2.6.1/main.nf' params(SongScoreUpload_params)
include { downloadPyega3 } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/download-pyega3@0.1.2/main.nf' params([*:params, 'cleanup': false])
include { decryptAspera } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/decrypt-aspera@0.1.0/main.nf' params([*:params, 'cleanup': false])
include { validateSeqtools } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/validate-seqtools@0.1.2/main.nf' params([*:params, 'cleanup': false])
include { downloadAspera } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/download-aspera@0.1.0/main.nf' params([*:params, 'cleanup': false])
include { EgaDownloadWf } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/ega-download-wf@0.1.2/main.nf'
include { payloadGenSeqExperiment } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/payload-gen-seq-experiment@0.6.0.2/main.nf'

// please update workflow code as needed
workflow ArgoDataSubmissionWf {
  take:
    download_mode
    experiment_info_tsv
    read_group_info_tsv
    file_info_tsv
    extra_info_tsv
    ascp_scp_host
    ascp_scp_user
    aspera_scp_pass
    c4gh_secret_key
    c4gh_pass_phrase
    pyega3_ega_user
    pyega3_ega_pass
    study_id
  main:

    if (experiment_info_tsv.startsWith("NO_FILE") || read_group_info_tsv.startsWith("NO_FILE") || file_info_tsv.startsWith("NO_FILE")){
      println "Not enough files to perform pipeline"
      exit 1
    }
    payloadGenSeqExperiment(
      file(experiment_info_tsv),
      file(read_group_info_tsv),
      file(file_info_tsv),
      file(extra_info_tsv),
      params.schema_url
    )

    if (download_mode!='local'){
      EgaDownloadWf(
      download_mode,
      file_info_tsv,
      ascp_scp_host,
      ascp_scp_user,
      aspera_scp_pass,
      pyega3_ega_user,
      pyega3_ega_pass,
      c4gh_secret_key,
      c4gh_pass_phrase
      )
    } else {
      local_files=Channel.fromPath(file_info_tsv) | splitCsv( header : true , sep:'\t') | map( row -> file("${row.path}",checkIfExists : true))
      sequence_files=local_files.collect()
    }
    
    validateSeqtools(
      payloadGenSeqExperiment.out.payload,
      sequence_files
     )

    SongScoreUpload(
      study_id,
      payloadGenSeqExperiment.out.payload,
      sequence_files
    )
    

    //if (params.cleanup && download_mode=='aspera') {
    //  cleanup(
    //    sequence_files.concat(downloadAspera.out.output_file.collect()).collect(),
    //  )
    //} else if (params.cleanup && download_mode=='pyega3'){
    //  cleanup(
    //    sequence_files,
    //  )
    //}

    emit:
      json_file=payloadGenSeqExperiment.out.payload
      output_analysis_id=SongScoreUpload.out.analysis_id
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  ArgoDataSubmissionWf(
    params.download_mode,
    params.experiment_info_tsv,
    params.read_group_info_tsv,
    params.file_info_tsv,
    params.extra_info_tsv,
    params.ascp_scp_host,
    params.ascp_scp_user,
    params.aspera_scp_pass,
    params.c4gh_secret_key,
    params.c4gh_pass_phrase,
    params.pyega3_ega_user,
    params.pyega3_ega_pass,
    params.study_id
  )
}