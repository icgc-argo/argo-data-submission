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
version = '0.1.4'

// universal params go here, change default value as needed
params.container = ""
params.container_registry = ""
params.container_version = ""
params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir

// tool specific parmas go here, add / change as needed
params.cleanup = true

params.download_mode=""
params.file_info_tsv="NO_FILE1"

params.ascp_scp_host=""
params.ascp_scp_user=""
params.aspera_scp_pass=""

params.c4gh_secret_key="NO_FILE2"
params.c4gh_pass_phrase=""

params.pyega3_ega_user=""
params.pyega3_ega_pass=""

params.downloadPyega3=[:]
params.downloadAspera=[:]
params.decryptAspera=[:]

downloadPyega3_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  'pyega3_ega_user': params.pyega3_ega_user,
  'pyega3_ega_pass': params.pyega3_ega_pass,
  *:(params.downloadPyega3 ?: [:]) 
]

downloadAspera_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'ascp_scp_host': params.ascp_scp_host,
  'ascp_scp_user': params.ascp_scp_user,
  'aspera_scp_pass': params.aspera_scp_pass,
  *:(params.downloadAspera ?: [:]) 
]

decryptAspera_params = [
  'c4gh_pass_phrase': params.c4gh_pass_phrase,
  'c4gh_secret_key': params.c4gh_secret_key,
  *:(params.decryptAspera ?: [:]) 
]


include { downloadPyega3 } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/download-pyega3@0.1.3/main.nf' params(downloadPyega3_params)
include { downloadAspera } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/download-aspera@0.1.2/main.nf' params(downloadAspera_params)
include { decryptAspera } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/decrypt-aspera@0.1.1/main.nf' params(decryptAspera_params)
include { cleanupWorkdir as cleanup } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/cleanup-workdir@1.0.0.1/main.nf'

// please update workflow code as needed
workflow EgaDownloadWf {
  take:  // update as needed
    download_mode
    file_info_tsv
    dependency

  main:  // update as needed
    Channel.fromPath(file_info_tsv).splitCsv(sep:'\t',header:true).map( row -> row.path).set{file_ch}
    Channel.fromPath(file_info_tsv).splitCsv(sep:'\t',header:true).map( row -> row.ega_file_id).set{id_ch}

    if ( download_mode=='aspera' ){
      Channel
      .fromPath(file_info_tsv)
      .splitCsv(sep:'\t',header:true)
      .map(
        row -> [
          name : row.name,
          ega_file_id : row.ega_file_id, 
          path : row.path,
        ]
      )
      .branch {
        errorAB: it.path.size()==0 & it.ega_file_id.size()==0
          exit 1, "Insufficient # of file `ega_file_ids` and `path` provided"
        errorA: it.ega_file_id.size()==0
          exit 1,"Insufficient # of `ega_file_ids` provided"
        errorB: it.path.size()==0
          exit 1, "Insufficient # of file `path` provided"
        other: true
          return 0
      }

      downloadAspera(
        file_ch,
        id_ch,
        dependency)

      decryptAspera(
        downloadAspera.out.output_file,
        file(params.c4gh_secret_key)
        )

      sequence_files=decryptAspera.out.output_files.collect()
      if (params.cleanup) {
        cleanup(
          downloadAspera.out.output_file.collect(),
          sequence_files //depedency
          )
      }
    } else if (download_mode=='pyega3'){
      Channel
      .fromPath(file_info_tsv)
      .splitCsv(sep:'\t',header:true)
      .map(
        row -> [
          name : row.name,
          ega_file_id : row.ega_file_id, 
          path : row.path,
        ]
      )
      .branch {
        errorA: it.ega_file_id.size()==0
          exit 1,"Insufficient # of `ega_file_ids` provided"
        other: true
          return 0
      }

      downloadPyega3(
        id_ch,
        dependency
        )
      
      sequence_files=downloadPyega3.out.output_files.collect()
    } else {
      exit 1,"Invalid download mode. Please specify 'pyega3' or 'aspera'"
    }

  emit:  // update as needed
    sequence_files

}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  EgaDownloadWf(
    params.download_mode,
    params.file_info_tsv,
    true
  )
}