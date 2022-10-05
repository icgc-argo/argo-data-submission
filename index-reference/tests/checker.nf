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

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo/argo-data-submission.index-reference'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.input_file = ""
params.expected_output = ""

include { indexReference } from '../main'

process download_required_files {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  output:
    path "hs37d5.fa.gz", emit: reference_file

  script:
    """
    curl ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz -o hs37d5.fa.gz
    """
}

process gunzip {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path compressed_file
  output:
    path "hs37d5.fa", emit: decompressed_file

  script:
    """
    cat ${compressed_file} | zcat > hs37d5.fa || true
    diff <(echo '12a0bed94078e2d9e8c00da793bbc84e  hs37d5.fa') <(md5sum hs37d5.fa) \
      && ( echo "DOWNLOAD OK" && exit 0 ) || ( echo "DOWNLOAD BAD" && exit 1 )
    """
}

process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_file
    val expected_file

  output:
    stdout emit : status

  script:
    """
    diff <(md5sum ${output_file} | cut -f1 -d' ') <(echo ${expected_file}) \
      && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}

process cleanup{
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path inputA
    path inputB
    val status

  script:
  def additional_delete = inputB.name != 'NO_FILE' ? "rm -rf \$(dirname \$(readlink -f ${inputB}))" : ''
  """
  dir_to_rm=\$(dirname \$(readlink -f ${inputA}))
  rm -rf \$dir_to_rm/*
  $additional_delete
  """
}

workflow checker {
  take:
    input_file
    expected_output

  main:

    download_required_files()

    if (input_file == 'hs37d5.fa'){
      gunzip(download_required_files.out.reference_file)
      reference_file=gunzip.out.decompressed_file
    } else {
      reference_file=download_required_files.out.reference_file
    }

    indexReference(
      reference_file
    )

    file_smart_diff(
      indexReference.out.fai_file,
      expected_output
    )

    if (input_file == 'hs37d5.fa'){
      cleanup(
      download_required_files.out.reference_file,
      gunzip.out.decompressed_file,
      file_smart_diff.out.status
      )
    } else {
      cleanup(
      download_required_files.out.reference_file,
      file("NO_FILE"),
      file_smart_diff.out.status
      )
    }
}


workflow {
  checker(
    params.input_file,
    params.expected_output
  )
}
