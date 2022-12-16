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
version = '0.2.0'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo/argo-data-submission.download-pyega3'
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
params.ega_id=''
params.pyega3_ega_user=''
params.pyega3_ega_pass=''


process downloadPyega3 {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir ? true : false
  errorStrategy 'terminate'
  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    val ega_id
    val dependency

  output:  // output, make update as needed
    path "${ega_id}/*.md5", emit: md5_file
    path "${ega_id}/*.{bam,cram,fastq.gz,fq.gz,fastq.bz2,fq.bz2,txt.gz,txt.bz2,vcf,vcf.gz,bcf}", emit : output_files
  script:

    """
    export PYEGA3_EGA_USER=${params.pyega3_ega_user}
    export PYEGA3_EGA_PASS=${params.pyega3_ega_pass}
    mkdir -p ${ega_id}
    python3.6 /tools/main.py \\
    	-f ${ega_id} \\
    	-o \$PWD \\
    	> download.log 2>&1
    
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  downloadPyega3(
    params.ega_id,
    true
  )
}

