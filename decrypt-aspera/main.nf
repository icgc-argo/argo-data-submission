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
version = '0.1.2'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo/argo-data-submission.decrypt-aspera'
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
params.file = ""
params.download_file = ""
params.c4gh_secret_key = ""
params.c4gh_pass_phrase = ""


process decryptAspera {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir ? true : false
  errorStrategy 'terminate'
  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path download_file
    val file
    path c4gh_secret_key

  output:  // output, make update as needed
    path "*.md5", emit: md5_file
    path "*.{bam,cram,fastq.gz,fq.gz}", emit: output_files

  script:
    // add and initialize variables here as needed

    """
    export C4GH_SECRET_KEY=${c4gh_secret_key}
    export C4GH_PASSPHRASE=${params.c4gh_pass_phrase} 
    python3.6 /tools/main.py \\
      -f ${download_file} \\
      > decrypt.log 2>&1
    mv ${download_file.getBaseName()} ${file}
    """
}

// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  decryptAspera(
    file(params.download_file),
    params.file,
    file(params.c4gh_secret_key)
  )
}
