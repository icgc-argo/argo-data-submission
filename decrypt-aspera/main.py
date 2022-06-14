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
    Python implementation of tool: decrypt-aspera

    This is auto-generated Python code, please update as needed!
    """
    parser = argparse.ArgumentParser(description='differentiate JSON metadata payload for SONG upload')
    parser.add_argument('-f', '--file', dest="file", help="auto generated json", required=True)

    results = parser.parse_args()
    

    cmd="cat "+results.file+" | crypt4gh decrypt > "+re.sub('.c4gh$','',results.file)
    result=subprocess.run(cmd,stdout=subprocess.PIPE,shell=True)

    if result.returncode!=0:
        subprocess.run("touch DECRYPT.FAILURE",stdout=subprocess.PIPE,shell=True)
        subprocess.run("touch MD5SUM.FAILURE",stdout=subprocess.PIPE,shell=True)
        raise ValueError("Unable to decrypt  "+results.file)
    else:
        subprocess.run("touch DECRYPT.SUCCESS",stdout=subprocess.PIPE,shell=True)

    cmd="md5sum "+re.sub('.c4gh$','',results.file)+" | egrep -o '^[0-9a-f]{32}'  > "+re.sub('.c4gh$','.md5',results.file)
    result=subprocess.run(cmd,stdout=subprocess.PIPE,shell=True)
    if result.returncode!=0:
        subprocess.run("touch MD5SUM.FAILURE",stdout=subprocess.PIPE,shell=True)
        raise ValueError("Md5sum not generated "+results.file)
    else:
        subprocess.run("touch MD5SUM.SUCCESS",stdout=subprocess.PIPE,shell=True)
        
    
    
if __name__ == "__main__":
    main()
