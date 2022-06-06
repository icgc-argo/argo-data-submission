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
    Edmund Su
"""

import os
import sys
import argparse
import subprocess
import random, string
import json
import errno
import shutil

def main():
    #Parsing of the input parameters using argparse
    parser = argparse.ArgumentParser(description='Download files from EGA pyega3 server')
    parser.add_argument('-p', '--project_name', dest="project_name", help="Name of the ICGC project", required=True)
    parser.add_argument('-f', '--file_name', dest="file_name", help="EGA file name", required=True)
    parser.add_argument('-o', '--output', dest='output', help="Output file name", required=True)

    results = parser.parse_args()

    # Generate random file name to output name of file to be downloaded
    cred_file = "."+randomword(60)+".json"

    try:
        try:
            # Check if ASCP_EGA_HOST environment variable exists: ega host
            os.environ['PYEGA3_EGA_USER']

            # Check if ASCP_EGA_USER environment variable exists: ega username
            os.environ['PYEGA3_EGA_PASS']

        except KeyError:
            raise KeyError("Global Variable: PYEGA3_EGA_USER and PYEGA3_EGA_PASS must exist in the environment.")
            
        # Write credentials to temporary json file
        with open(cred_file, 'w') as f: 
            json.dump(
                {
                    "username":os.environ['PYEGA3_EGA_USER'],
                    "password":os.environ['PYEGA3_EGA_PASS']
                },
                f)
            f.close()        

        # Raise an error if the output file exists
        if os.path.isfile(results.output):
            raise ValueError("Output file already exists")
        
        # Check Directory
        mkdir_p(os.path.dirname(results.output))
        
        # Download process
        subprocess.call(
            ["pyega3","-cf",cred_file,"fetch",results.file_name,"--output-dir",results.output,"--delete-temp-files"]
        )
        
        # Move pyega3 log into new download directory
        result=subprocess.run("grep 'Download complete' "+os.getcwd()+"/pyega3_output.log"+" || false",shell=True)
        
        # check if download successful
        if result.returncode==0:
            subprocess.run("touch "+results.output+"/"+results.file_name+"/DOWNLOAD.SUCCESS",shell=True)
        else:
            subprocess.run("touch "+results.output+"/"+results.file_name+"/DOWNLOAD.FAILURE",shell=True)
        

        # Deletion of temporary elements
        os.remove(cred_file)
    except Exception as err:
        print(str(err))
        if os.path.isfile(cred_file):
            os.remove(cred_file)
        exit(1)

def randomword(length):
    return(''.join(random.choice(string.ascii_lowercase) for i in range(length)))

def mkdir_p(path):
    try:
        os.makedirs(path,0o755, True )
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

if __name__ == "__main__":
    main()

