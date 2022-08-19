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
params.max_retries = 5  // set to 0 will disable retry
params.first_retry_wait_time = 1  // in seconds
params.cleanup = true

// ArgoDataSubmissionWf
params.study_id=""
params.download_mode="local"

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

params.song_url = ""
params.score_url = ""
params.api_token=""
params.payloadGen = [:]
params.upload = [:]
params.validateSeq = [:]
params.egaDownload = [:]

payloadGen_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'schema_url': params.schema_url,
  'publish_dir': params.publish_dir,
  *:(params.payloadGen ?: [:])
]

validateSeq_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  *:(params.validateSeq ?: [:]) 
]

egaDownload_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  *:(params.egaDownload ?: [:]) 
]

upload_params = [
  'max_retries': params.max_retries,
  'first_retry_wait_time': params.first_retry_wait_time,
  'cpus': params.cpus,
  'mem': params.mem,
  'song_url': params.song_url,
  'score_url': params.score_url,
  'api_token': params.api_token,
  *:(params.upload ?: [:])
]

include { SongScoreUpload as uploadWf } from './wfpr_modules/github.com/icgc-argo/nextflow-data-processing-utility-tools/song-score-upload@2.6.1/main.nf' params(upload_params)
include { validateSeqtools as valSeq} from './wfpr_modules/github.com/icgc-argo/argo-data-submission/validate-seqtools@0.1.3/main.nf' params(validateSeq_params)
include { EgaDownloadWf as egaWf } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/ega-download-wf@0.1.3/main.nf' params(egaDownload_params)
include { payloadGenSeqExperiment as pGenExp} from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/payload-gen-seq-experiment@0.7.0/main.nf' params(payloadGen_params)
include { cleanupWorkdir as cleanup } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/cleanup-workdir@1.0.0.1/main.nf'

// please update workflow code as needed
workflow ArgoDataSubmissionWf {
  take:
    study_id
    experiment_info_tsv
    read_group_info_tsv
    file_info_tsv
    extra_info_tsv
    
  main:

    if (experiment_info_tsv.startsWith("NO_FILE") || read_group_info_tsv.startsWith("NO_FILE") || file_info_tsv.startsWith("NO_FILE")){
      println "Not enough files to perform pipeline"
      exit 1
    }
    // generate payload
    pGenExp(
      file(experiment_info_tsv),
      file(read_group_info_tsv),
      file(file_info_tsv),
      file(extra_info_tsv),
      params.schema_url
    )

    // download from ega after payload is generated and valid according to the given schema
    if (params.download_mode!='local'){
      egaWf(
        params.download_mode,
        file_info_tsv,
        pGenExp.out.count()
      )
      sequence_files=egaWf.out.sequence_files
    } else {
      sequence_files=Channel.fromPath(file_info_tsv) | splitCsv( header : true , sep:'\t') | map( row -> file("${row.path}",checkIfExists : true))
    }
    
    // use seq-tools to validate payload and sequence data
    valSeq(
      pGenExp.out.payload,
      sequence_files.collect()
     )

    // upload to song/score after valSeq is PASS
    uploadWf(
      study_id,
      valSeq.out.validated_payload,
      sequence_files.collect()
    )
    
    // only cleanup the sequence files when they are not from local
    if (params.cleanup && params.download_mode!='local') {
     cleanup(
       sequence_files.collect(),
       uploadWf.out.analysis_id  // wait until upload is done
     )
    } 

    emit:
      json_file=pGenExp.out.payload
      output_analysis_id=uploadWf.out.analysis_id
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  ArgoDataSubmissionWf(
    params.study_id,
    params.experiment_info_tsv,
    params.read_group_info_tsv,
    params.file_info_tsv,
    params.extra_info_tsv 
  )
}