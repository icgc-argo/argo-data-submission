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
version = '0.3.2'

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
params.song_container = ""
params.song_container_version = ""
params.score_container = ""
params.score_container_version = ""

// sanityChecks
params.song_url=""
params.score_url=""
params.clinical_url=""
params.api_token=""

// payloadJsonToTsvs
params.data_directory="NO_FILE1"
params.skip_duplicate_check=false

// payloadGenSeqExperiment
params.schema_url=""
params.experiment_info_tsv="NO_FILE2"
params.read_group_info_tsv="NO_FILE3"
params.file_info_tsv="NO_FILE4"
params.extra_info_tsv="NO_FILE5"
params.metadata_payload_json="NO_FILE6"
params.ref_genome_fa="NO_FILE7"
params.recalculate= false

//validate seq-tools
params.skip_tests = false
params.skipping_tests = ["c681","c683"]

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

// SubmissionReceipt
params.skip_submission_check=false

params.payloadGen = [:]
params.upload = [:]
params.validateSeq = [:]
params.egaDownload = [:]
params.cram2bam = [:]

payloadGen_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'schema_url': params.schema_url,
  'publish_dir': params.publish_dir,
  *:(params.payloadGen ?: [:])
]

cram2bam_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  *:(params.cram2bam ?: [:])
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
  'pyega3_ega_user': params.pyega3_ega_user,
  'pyega3_ega_pass': params.pyega3_ega_pass,
  'ascp_scp_host': params.ascp_scp_host,
  'ascp_scp_user': params.ascp_scp_user,
  'aspera_scp_pass': params.aspera_scp_pass,
  'c4gh_pass_phrase': params.c4gh_pass_phrase,
  'c4gh_secret_key': params.c4gh_secret_key,
  *:(params.egaDownload ?: [:]) 
]

upload_params = [
  'max_retries': params.max_retries,
  'first_retry_wait_time': params.first_retry_wait_time,
  'cpus': params.cpus,
  'mem': params.mem,
  'song_url': params.song_url,
  'song_container': params.song_container,
  'song_container_version': params.song_container_version,
  'score_url': params.score_url,
  'score_container': params.score_container,
  'score_container_version': params.score_container_version,
  'api_token': params.api_token,
  *:(params.upload ?: [:])
]

sanityCheck_params = [
  'cpus': params.cpus,
  'mem': params.mem,
]

payloadJsonToTsvs_params = [
  'cpus': params.cpus,
  'mem': params.mem,
]

submissionReceipt_params = [
  'cpus': params.cpus,
  'mem': params.mem, 
]

include { SongScoreUpload as uploadWf } from './wfpr_modules/github.com/icgc-argo-workflows/nextflow-data-processing-utility-tools/song-score-upload@2.9.2/main.nf' params(upload_params)
include { validateSeqtools as valSeq} from './wfpr_modules/github.com/icgc-argo/argo-data-submission/validate-seqtools@0.1.7/main.nf' params(validateSeq_params)
include { EgaDownloadWf as egaWf } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/ega-download-wf@0.1.6/main.nf' params(egaDownload_params)
include { payloadGenSeqExperiment as pGenExp} from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/payload-gen-seq-experiment@0.8.2/main.nf' params(payloadGen_params)
include { cleanupWorkdir as cleanup } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/cleanup-workdir@1.0.0.1/main.nf'
include { cram2bam } from './wfpr_modules/github.com/icgc-argo-workflows/dna-seq-processing-tools/cram2bam@0.1.0/main.nf' params(cram2bam_params)
include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main.nf' params([*:params, 'cleanup': false])
include { sanityCheck } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/sanity-check@0.1.1/main.nf' params(sanityCheck_params)
include { payloadJsonToTsvs } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/payload-json-to-tsvs@0.1.1/main.nf' params(payloadJsonToTsvs_params)
include { submissionReceipt } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/submission-receipt@0.1.0/main.nf' params(submissionReceipt_params)
// please update workflow code as needed

process checkCramReference{
  input:  // input, make update as needed
    path file_info_tsv
    path ref_genome_fa
    path experiment_info_tsv
  output:
    stdout emit: check_status
    path ref_genome_fa, emit : ref_genome_fa , optional: true

  script:
  """
    BAM_COUNT=\$(cat ${file_info_tsv} | grep -v 'CRAM' | wc -l)
    CRAM_COUNT=\$(cat ${file_info_tsv} | grep 'CRAM' | wc -l)

    if [ \$CRAM_COUNT -gt 0 ];then
      if [ -e ${ref_genome_fa} ];then
        exit 0
      else
        echo "Missing reference genome needed for cram2bam conversion. Re-run command with '--ref_genome_fa' with valid 'fasta' or 'fasta.gz'"
        exit 1
      fi
    elif [ \$BAM_COUNT -gt 0 ] && [ \$CRAM_COUNT -eq 0 ];then
      if [ -e ${ref_genome_fa} ];then
        echo "No CRAM files detected. Unnecessary usage of '--ref_genome_fa'. Re-run command without --ref_genome_fa"
        exit 1
      else
        exit 0
      fi
    else
      exit 0
    fi
  """
}

process printOut{
  input:  // 
      val json_file
      val output_analysis_id
      val receipt
  exec:
    println ""
    println "Payload JSON File : ${json_file}"
    println "Analysis ID : ${output_analysis_id}"
    println "Submission TSV Receipt: ${receipt}"
}

workflow ArgoDataSubmissionWf {
  take:
    study_id
    og_experiment_info_tsv
    og_read_group_info_tsv
    og_file_info_tsv
    extra_info_tsv
    metadata_payload_json
    ref_genome_fa
    data_directory
    api_token
    song_url
    clinical_url
  main:

    if (
      og_experiment_info_tsv.startsWith("NO_FILE") && \
      og_read_group_info_tsv.startsWith("NO_FILE") && \
      og_file_info_tsv.startsWith("NO_FILE") && \
      metadata_payload_json.startsWith("NO_FILE") && \
      data_directory.startsWith("NO_FILE")
    ){
      exit 1,"Not enough files to perform pipeline"
    } else if (
      og_experiment_info_tsv.startsWith("NO_FILE") && \
      og_read_group_info_tsv.startsWith("NO_FILE") && \
      og_file_info_tsv.startsWith("NO_FILE") && \
      (metadata_payload_json.startsWith("NO_FILE") || data_directory.startsWith("NO_FILE"))
    ){
      exit 1,"`metadata_payload_json` and `data_directory` must be invoked together."
    } else if (
      metadata_payload_json.startsWith("NO_FILE") && \
      data_directory.startsWith("NO_FILE") && \
      (og_experiment_info_tsv.startsWith("NO_FILE") || og_read_group_info_tsv.startsWith("NO_FILE") || og_file_info_tsv.startsWith("NO_FILE"))
    ){
      exit 1,"`experiment_info_tsv` , `read_group_info_tsv` , and `file_info_tsv` must be invoked together."
    } else if (
      !og_experiment_info_tsv.startsWith("NO_FILE") && \
      !og_read_group_info_tsv.startsWith("NO_FILE") && \
      !og_file_info_tsv.startsWith("NO_FILE") && \
      !metadata_payload_json.startsWith("NO_FILE") && \
      !data_directory.startsWith("NO_FILE")
    ) {
      exit 1,"Too many parameters invoked. Please re-submit with either of the following pairings: 1. `experiment_info_tsv` , `read_group_info_tsv` , and `file_info_tsv` 2. `metadata_payload_json` and `data_directory`"
    }

    if (
      og_experiment_info_tsv.startsWith("NO_FILE") && \
      og_read_group_info_tsv.startsWith("NO_FILE") && \
      og_file_info_tsv.startsWith("NO_FILE")
    ) {
      payloadJsonToTsvs(
        file(metadata_payload_json),
        file(data_directory)
        )

      sanityCheck(
        payloadJsonToTsvs.out.experiment_tsv,
        api_token,
        song_url,
        clinical_url,
        params.skip_duplicate_check
      )
      
      experiment_info_tsv=sanityCheck.out.updated_experiment_info_tsv
      read_group_info_tsv=payloadJsonToTsvs.out.read_group_tsv
      file_info_tsv=payloadJsonToTsvs.out.file_tsv
    } else {
      sanityCheck(
        file(og_experiment_info_tsv),
        api_token,
        song_url,
        clinical_url,
        params.skip_duplicate_check
      )
      
      experiment_info_tsv=sanityCheck.out.updated_experiment_info_tsv
      read_group_info_tsv=file(og_read_group_info_tsv)
      file_info_tsv=file(og_file_info_tsv)
    }

    checkCramReference(
      file_info_tsv,
      file(ref_genome_fa),
      experiment_info_tsv
      )


    // download from ega after payload is generated and valid according to the given schema
    if (params.download_mode!='local' ){
      egaWf(
        params.download_mode,
        file_info_tsv,
        checkCramReference.out.check_status
      )
      sequence_files=egaWf.out.sequence_files
    } else if (og_file_info_tsv.startsWith("NO_FILE")){
      sequence_files=file_info_tsv.splitCsv( header : true , sep:'\t').map( row -> file("${row.path}",checkIfExists : true)) 
    } else {
      sequence_files=Channel.fromPath(file_info_tsv).splitCsv( header : true , sep:'\t').map( row -> file("${row.path}",checkIfExists : true))
    }
    
    // Split files into CRAM and nonCRAM files accordingly
    cram_sequence_files=sequence_files.filter(row -> row =~ /cram$/)
    not_cram_sequence_files=sequence_files.filter(row -> row =~ /bam$|gz$|bz2$/)

    if (params.recalculate){
      recalculate_files=not_cram_sequence_files.collect()
    } else {
      recalculate_files=[file("NO_FILE4")]
    }

    if (params.skip_tests){
      skipping_tests=params.skipping_tests
    } else {
      skipping_tests=""
    }

    // If reference genome is not provided...
    if (checkCramReference.out.check_status && ref_genome_fa.startsWith("NO_FILE")){
      // Generate metadata payload per normal

      pGenExp(
        experiment_info_tsv,
        read_group_info_tsv,
        file_info_tsv,
        file(extra_info_tsv),
        file("NO_FILE1"),
        params.schema_url,
        [file("NO_FILE2")],
        file("NO_FILE3"),
        recalculate_files
      )
      // Validate payload
      valSeq(
        pGenExp.out.payload,
        sequence_files.collect(),
        skipping_tests
      )

      uploadWf(
        study_id,
        valSeq.out.validated_payload,
        sequence_files.collect(),
        ''
      )

      submissionReceipt(
          study_id,
          uploadWf.out.analysis_id,
          song_url,
          params.skip_submission_check,
          sequence_files.collect()
      )

    } else if (checkCramReference.out.check_status && !ref_genome_fa.startsWith("NO_FILE")){
      // If reference genome is provided...
      cram2bam(
      cram_sequence_files,
      checkCramReference.out.ref_genome_fa,
      Channel.fromPath(getSecondaryFiles(ref_genome_fa,['{fai,gzi}']),checkIfExists:true).collect()
      )

      // Generate metadata payload while recalulating md5sum and size for cram2bam files and move cram info
      pGenExp(
      experiment_info_tsv,
      read_group_info_tsv,
      file_info_tsv,
      file(extra_info_tsv),
      file("NO_FILE"),
      params.schema_url,
      cram2bam.out.output_bam.collect(),
      file(ref_genome_fa),
      recalculate_files
      )
      // Validate payload // To add md5sum + file check for cram files
      valSeq(
      pGenExp.out.payload,
      sequence_files.collect().concat(cram2bam.out.output_bam.collect()).collect(),
      skipping_tests
      )

      uploadWf(
        study_id,
        valSeq.out.validated_payload,
        not_cram_sequence_files.concat(cram2bam.out.output_bam.collect()).collect(),
        ''
      )

      submissionReceipt(
          study_id,
          uploadWf.out.analysis_id,
          song_url,
          params.skip_submission_check,
          not_cram_sequence_files.concat(cram2bam.out.output_bam.collect()).collect(),
      )
    }
    if (params.cleanup && params.download_mode!='local' && ref_genome_fa.startsWith("NO_FILE")) {
      // only cleanup the sequence files when they are not from local
      cleanup(
      sequence_files.collect(),
      submissionReceipt.out.receipt  // wait until upload is done
      )
    } else if (params.cleanup && params.download_mode!='local' && !ref_genome_fa.startsWith("NO_FILE")){
      // only cleanup the sequence files and cram2bam output when they are not from local
      cleanup(
      sequence_files.collect().concat(cram2bam.out.output_bam.collect()).collect(),
      submissionReceipt.out.receipt  // wait until upload is done
      )
    } else if (params.cleanup && params.download_mode=='local' && !ref_genome_fa.startsWith("NO_FILE")){
      // only cleanup output from cram2bam on local
      cleanup(
      cram2bam.out.output_bam.collect(),
       submissionReceipt.out.receipt // wait until upload is done
      )
    }

    printOut(
      pGenExp.out.payload,
      uploadWf.out.analysis_id,
      submissionReceipt.out.receipt
    )
    //Channel.from(pGenExp.out.payload).view()
    //Channel.of(pGenExp.out.payload).view()

    emit:
      json_file=pGenExp.out.payload
      output_analysis_id=uploadWf.out.analysis_id
      receipt=submissionReceipt.out.receipt
}

// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  ArgoDataSubmissionWf(
    params.study_id,
    params.experiment_info_tsv,
    params.read_group_info_tsv,
    params.file_info_tsv,
    params.extra_info_tsv,
    params.metadata_payload_json,
    params.ref_genome_fa,
    params.data_directory,
    params.api_token,
    params.song_url,
    params.clinical_url
  )
}