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


def main():
    """
    Python implementation of tool: validate-seqtools

    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Tool: validate-seqtools')
    parser.add_argument('-j', '--json-file', dest='json_file', type=str,
                        help='JSON file containing molecular data to be validated', required=True)
    parser.add_argument('-k', '--skip_md5sum_check', dest='skip_md5sum', action='store_true',
                        help='JSON file containing molecular data to be validated')
    args = parser.parse_args()

    # Check if successful
    if args.skip_md5sum :
        cmd="seq-tools validate "+args.json_file+" --skip_md5sum_check"
    else:
        cmd="seq-tools validate "+args.json_file
    result=subprocess.run(cmd,shell=True)


if __name__ == "__main__":
    main()

