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
import re
import subprocess

def main():
    """
    Python implementation of tool: decrypt-aspera

    This is auto-differentiated Python code, please update as needed!
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
