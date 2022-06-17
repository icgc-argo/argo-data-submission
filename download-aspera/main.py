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
import errno
import shutil
import random
import string


def main():
    """
    Python implementation of tool: download-aspera

    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Download files from EGA aspera server')
    parser.add_argument('-f', '--file_name', dest="file_name", help="EGA file name", required=True)
    parser.add_argument('-o', '--output', dest='output', help="Output file name", required=True)
    results = parser.parse_args()

    file_list = randomword(60)+".txt"

    try:
        try:
            # Check if ASCP_EGA_HOST environment variable exists: ega host
            os.environ['ASCP_SCP_HOST']

            # Check if ASCP_EGA_USER environment variable exists: ega username
            os.environ['ASCP_SCP_USER']

            # Check if ASPERA_SCP_PASS environment variable exists: ascpera password
            os.environ['ASPERA_SCP_PASS']
        except KeyError:
            raise KeyError("Global Variable: ASCP_SCP_HOST, ASCP_SCP_USER and ASPERA_SCP_PASS must exist in the environment.")

        # Raise an error if the output file exists
        if os.path.isfile(results.output+"/"+results.file_name):
            raise ValueError("Output file already exists")

        # Write the file to be downloaded to the temporary file
        with open(file_list, 'w') as f:
            f.write(results.file_name)
            f.write('\n')

        # Download process
        result=subprocess.run(['/home/ubuntu/.aspera/connect/bin/ascp','-k','1','-QTl','100m','--file-list='+file_list,'--partial-file-suffix=PART','--ignore-host-key','--mode=recv','--host='+os.environ['ASCP_SCP_HOST'],'--user='+os.environ['ASCP_SCP_USER'],results.output])
        
        if result.returncode==0:
            subprocess.run("touch "+results.output+"/DOWNLOAD.SUCCESS",shell=True)
        else:
            subprocess.run("touch "+results.output+"/DOWNLOAD.FAILURE",shell=True)
        
        # Deletion of temporary elements
        os.remove(file_list)
    except Exception as err:
        print(str(err))
        if os.path.isfile(file_list):
            os.remove(file_list)
        exit(1)



def randomword(length):
   return(''.join(random.choice(string.ascii_lowercase) for i in range(length)))

def mkdir_p(path,file):
    try:
        os.makedirs(path,mode=0o755, exist_ok=True )
        os.makedirs(path+"/"+file,mode=0o755, exist_ok=True )
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


if __name__ == "__main__":
    main()
