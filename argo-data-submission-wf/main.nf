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
version = '0.2.0'

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
params.metadata_payload_json="NO_FILE6"
params.ref_genome_fa="NO_FILE7"
//validate seq-tools
params.skip_md5sum_check = false

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
params.convert_cram = false
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
  'skip_md5sum_check': params.skip_md5sum_check,
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
  'score_url': params.score_url,
  'api_token': params.api_token,
  *:(params.upload ?: [:])
]

include { SongScoreUpload as uploadWf } from './wfpr_modules/github.com/icgc-argo/nextflow-data-processing-utility-tools/song-score-upload@2.6.1/main.nf' params(upload_params)
include { validateSeqtools as valSeq} from './wfpr_modules/github.com/icgc-argo/argo-data-submission/validate-seqtools@0.1.5/main.nf' params(validateSeq_params)
include { EgaDownloadWf as egaWf } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/ega-download-wf@0.1.4/main.nf' params(egaDownload_params)
include { payloadGenSeqExperiment as pGenExp} from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/payload-gen-seq-experiment@0.8.0/main.nf' params(payloadGen_params)
include { cleanupWorkdir as cleanup } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/cleanup-workdir@1.0.0.1/main.nf'
include { cram2bam } from './wfpr_modules/github.com/icgc-argo-workflows/dna-seq-processing-tools/cram2bam@0.1.0/main.nf' params(cram2bam_params)
include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main.nf' params([*:params, 'cleanup': false])

// please update workflow code as needed
workflow ArgoDataSubmissionWf {
  take:
    study_id
    experiment_info_tsv
    read_group_info_tsv
    file_info_tsv
    extra_info_tsv
    metadata_payload_json
    ref_genome_fa
    convert_cram
  main:

    if (
      (experiment_info_tsv.startsWith("NO_FILE") && read_group_info_tsv.startsWith("NO_FILE") && file_info_tsv.startsWith("NO_FILE")) ||
      (metadata_payload_json.startsWith("NO_FILE") && file_info_tsv.startsWith("NO_FILE")) ||
      file_info_tsv.startsWith("NO_FILE")
      ){
      exit 1,"Not enough files to perform pipeline"
    }
    // Check if 
    if (convert_cram && ref_genome_fa.startsWith("NO_FILE")){
        exit 1,"cram2bam function specified but no reference genome provided. Please include flag '--ref_genome_fa'"
    } else if (!convert_cram && !ref_genome_fa.startsWith("NO_FILE")){
      exit 1,"Unnecessary usage of '--ref_genome_fa'. Please include '--cram2bam' only if CRAM files are being submitted"
    }

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
    
    // Split files into CRAM and nonCRAM files accordingly
    cram_sequence_files=sequence_files.filter(row -> row =~ /cram$/)
    not_cram_sequence_files=sequence_files.filter(row -> row =~ /bam$|gz$|bz2$/)

    // If reference genome is not provided...
    if (ref_genome_fa.startsWith("NO_FILE")){
      // Generate metadata payload per normal
      pGenExp(
        file(experiment_info_tsv),
        file(read_group_info_tsv),
        file(file_info_tsv),
        file(extra_info_tsv),
        file(metadata_payload_json),
        params.schema_url,
        [file("NO_FILE1")],
        file("NO_FILE2")
      )
      // Validate payload
      valSeq(
        pGenExp.out.payload,
        sequence_files.collect()
      )

      uploadWf(
        study_id,
        valSeq.out.validated_payload,
        sequence_files.collect()
      )
    } else {
      // If reference genome is provided...
      cram2bam(
      cram_sequence_files,
      ref_genome_fa,
      Channel.fromPath(getSecondaryFiles(ref_genome_fa,['.gz.fai','.gz.gzi']))
      )
      // Generate metadata payload while recalulating md5sum and size for cram2bam files and move cram info
      pGenExp(
      file(experiment_info_tsv),
      file(read_group_info_tsv),
      file(file_info_tsv),
      file(extra_info_tsv),
      file(metadata_payload_json),
      params.schema_url,
      cram2bam.out.output_bam.collect(),
      file(ref_genome_fa)
      )
      // Validate payload // To add md5sum + file check for cram files
      valSeq(
      pGenExp.out.payload,
      sequence_files.collect().concat(cram2bam.out.output_bam.collect()).collect()
      )

      uploadWf(
        study_id,
        valSeq.out.validated_payload,
        not_cram_sequence_files.concat(cram2bam.out.output_bam.collect()).collect()
      )
    }
    if (params.cleanup && params.download_mode!='local' && ref_genome_fa.startsWith("NO_FILE")) {
      // only cleanup the sequence files when they are not from local
      cleanup(
      sequence_files.collect(),
      uploadWf.out.analysis_id  // wait until upload is done
      )
    } else if (params.cleanup && params.download_mode!='local' && !ref_genome_fa.startsWith("NO_FILE")){
      // only cleanup the sequence files and cram2bam output when they are not from local
      cleanup(
      sequence_files.collect().concat(cram2bam.out.output_bam.collect()).collect(),
      uploadWf.out.analysis_id  // wait until upload is done
      )
    } else if (params.cleanup && params.download_mode=='local' && !ref_genome_fa.startsWith("NO_FILE")){
      // only cleanup output from cram2bam on local
      cleanup(
      cram2bam.out.output_bam.collect(),
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
    params.extra_info_tsv,
    params.metadata_payload_json,
    params.ref_genome_fa,
    params.convert_cram
  )
}