#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
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
"""

import os
import sys
import argparse
import subprocess
import re


def main():
    """
    Python implementation of tool: index-reference
    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Tool: index-reference')
    parser.add_argument('-r', '--reference-file', dest='reference_file', type=str,
                        help='Reference CRAM file needed for conversion', required=True)
    args = parser.parse_args()


    if not os.path.isfile(args.reference_file):
        sys.exit('Error: %s does not exist or is not accessible!' % (args.reference_file))

    if not re.findall(r'.fasta$|.fa$|.fna$|.fasta.gz$|.fa.gz$|.fna.gz$',args.reference_file):
        sys.exit('Error: %s reference file follows an inappropriate format. Please re-submit' % (args.reference_file))

    if os.path.isfile(args.reference_file + ".fai"):
        sys.exit('%s exists already!' % (args.reference_file+".fai"))

    subprocess.run(
        'samtools faidx %s '% (
            args.reference_file),
        shell=True,
        check=True
        )


if __name__ == "__main__":
    main()
