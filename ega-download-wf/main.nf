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
params.input_file = ""
params.cleanup = true

params.download_mode=""
params.files_to_download=""
params.ids_to_download=""

params.ascp_scp_host=""
params.ascp_scp_user=""
params.aspera_scp_pass=""

params.c4gh_secret_key="NO_FILE"
params.c4gh_pass_phrase=""

params.pyega3_ega_user=""
params.pyega3_ega_pass=""

include { downloadPyega3 } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/download-pyega3@0.1.0/main.nf' params([*:params, 'cleanup': false])
include { downloadAspera } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/download-aspera@0.1.0/main.nf' params([*:params, 'cleanup': false])
include { decryptAspera } from './wfpr_modules/github.com/icgc-argo/argo-data-submission/decrypt-aspera@0.1.0/main.nf' params([*:params, 'cleanup': false])


// please update workflow code as needed
workflow EgaDownloadWf {
  take:  // update as needed
    download_mode
    file_to_download
    id_to_download
    ascp_scp_host
    ascp_scp_user
    aspera_scp_pass
    pyega3_ega_user
    pyega3_ega_pass
    c4gh_secret_key
    c4gh_pass_phrase
  main:  // update as needed

    if ( download_mode=='aspera' ){

      downloadAspera(
        file_to_download,
        id_to_download,
        ascp_scp_host,
        ascp_scp_user,
        aspera_scp_pass)

      decryptAspera(
        downloadAspera.out.output_file,
        file(c4gh_secret_key),
        c4gh_pass_phrase
        )

      sequence_files=decryptAspera.out.output_files.collect()
    } else if (download_mode=='pyega3'){

      downloadPyega3(
        id_to_download,
        pyega3_ega_user,
        pyega3_ega_pass
        )
      
      sequence_files=downloadPyega3.out.output_files.collect()
    } else {
      println "Invalid download mode. Please specify 'pyega3' or 'aspera'"
      exit 1
    }


  emit:  // update as needed
    sequence_files
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  EgaDownloadWf(
    params.download_mode,
    params.files_to_download,
    params.ids_to_download,
    params.ascp_scp_host,
    params.ascp_scp_user,
    params.aspera_scp_pass,
    params.pyega3_ega_user,
    params.pyega3_ega_pass,
    params.c4gh_secret_key
    params.c4gh_pass_phrase
  )
}