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
    Python implementation of tool: cram-to-bam

    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Tool: cram-to-bam')
    parser.add_argument('-i', '--input-file', dest='input_file', type=str,
                        help='Input CRAM file', required=True)
    parser.add_argument('-r', '--reference-file', dest='reference_file', type=str,
                        help='Reference CRAM file needed for conversion', required=True)
    parser.add_argument('-t', '--threads', dest='threads', type=int,default=1,
                        help='# of threads to be used in the operation', required=False)
    args = parser.parse_args()

    for provided_file,parameter in zip(
        [args.input_file,args.reference_file,args.reference_file+".fai"],
        ["input file","reference genome","reference genome"]):
            if not os.path.isfile(args.input_file):
                sys.exit('Error: %s %s does not exist or is not accessible!' % (parameter,provided_file))


    output_file=re.sub(".cram$|.CRAM$",".bam",args.input_file)
    subprocess.run(
        'samtools view --threads %s -bh %s -o %s -T %s' % (
            args.threads,
            args.input_file,
            output_file,
            args.reference_file),
        shell=True,
        check=True
        )


if __name__ == "__main__":
    main()
