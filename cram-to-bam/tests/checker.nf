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
    'ghcr.io': 'ghcr.io/icgc-argo/argo-data-submission.cram-to-bam'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.input_file = "NO_FILE1"
params.expected_output = "NO_FILE2"
params.fai_file = "NO_FILE3"
params.gzi_file = "NO_FILE4"

include { cramToBam } from '../main'


process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_file
    path reference_file
    path fai_file
    path expected_file

  output:
    stdout emit : status

  script:
    """
    ### Compare header information
    diff \
      <(samtools view -H ${output_file} | grep '^@RG') \
      <(samtools view -H ${expected_file} | grep '^@RG') \
      || ( echo "Test FAILED, output file mismatch." && exit 1 )

    ## Compare body information. Command also reorientates TAGS to match original
    diff \
      <(samtools view ${output_file} | grep -v 'SA:' | awk -v OFS='\\t' '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$11,\$15,\$14,\$12,\$13,\$16}') \
      <(samtools view ${expected_file} -T ${reference_file} | grep -v 'SA:') \
      || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}

process download_required_files{
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  output:
    path "hs37d5.fa", emit: reference_file

  script:
    """
    curl ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz -o hs37d5.fa.gz
    
    ### Legacy RAZF gzip compression? this is a workaround
    gunzip hs37d5.fa.gz || true

    diff <(echo '12a0bed94078e2d9e8c00da793bbc84e  hs37d5.fa') <(md5sum hs37d5.fa) \
      && ( echo "DOWNLOAD OK" && exit 0 ) || ( echo "DOWNLOAD BAD" && exit 1 )
    """
}

process cleanup{
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path inputA
    path inputB
    val status

  script:
    """
    dir_to_rm=\$(dirname \$(readlink -f ${inputA}))
    rm -rf \$dir_to_rm/*

    dir_to_rm=\$(dirname \$(readlink -f ${inputB}))
    rm -rf \$dir_to_rm/*
    """
}
workflow checker {
  take:
    input_file
    fai_file
    gzi_file
    expected_file

  main:
  download_required_files()

  cramToBam(
    input_file,
    download_required_files.out.reference_file,
    fai_file,
    gzi_file
  )

  file_smart_diff(
    cramToBam.out.output_file,
    download_required_files.out.reference_file,
    fai_file,
    expected_file
  )

  cleanup(
    cramToBam.out.output_file,
    download_required_files.out.reference_file,
    file_smart_diff.out.status
  )
}


workflow {
  checker(
    file(params.input_file),
    file(params.fai_file),
    file(params.gzi_file),
    file(params.expected_file)
  )
}
