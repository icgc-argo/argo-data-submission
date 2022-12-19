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
import random, string
import json
import errno
import shutil


def main():
    """
    Python implementation of tool: download-pyega3

    This is auto-generated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='Download files from EGA pyega3 server')
    parser.add_argument('-f', '--file_name', dest="file_name", help="EGA file name", required=True)
    parser.add_argument('-o', '--output', dest='output', help="Output file directory", required=True)
    parser.add_argument('-c', '--connections', dest='connections', help="Number of connections to use", required=True)

    results = parser.parse_args()


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
        
        # Download process
        subprocess.call(
            ["pyega3","--connections",results.connections,"-cf",cred_file,"fetch",results.file_name,"--delete-temp-files"]
        )
        
        # Check if successful
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

if __name__ == "__main__":
    main()