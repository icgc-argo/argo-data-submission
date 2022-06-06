#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
  Copyright (c) 2022, Your Organization Name

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    edsu7
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
    #Parsing of the input parameters using argparse
    parser = argparse.ArgumentParser(description='Download files from EGA aspera server')
    parser.add_argument('-p', '--project_name', dest="project_name", help="Name of the ICGC project", required=True)
    parser.add_argument('-f', '--file_name', dest="file_name", help="EGA file name", required=True)
    parser.add_argument('-o', '--output', dest='output', help="Output file name", required=True)

    results = parser.parse_args()

    # Generate random file name to output name of file to be downloaded
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
        if os.path.isfile(results.output):
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

