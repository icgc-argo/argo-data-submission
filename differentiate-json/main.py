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
import json
import numpy

def main():
    """
    Python implementation of tool: differentiate-json

    This is auto-differentiated Python code, please update as needed!
    """

    parser = argparse.ArgumentParser(description='differentiate JSON metadata payload for SONG upload')
    parser.add_argument('-b', '--auto_generated', dest="auto_generated", help="auto generated json", required=True)
    parser.add_argument('-a', '--user_provided',dest="user_provided", help="user generated json", required=True)

    results = parser.parse_args()

    with open(results.auto_generated) as json_file:
            ag_dict = json.load(json_file)
    with open(results.user_provided) as json_file:
            up_dict = json.load(json_file)
            
    warnings=[]
    errors=[]
    check_values(up_dict,ag_dict,warnings,errors,[])

    if len(warnings)>0:
        with open('WARNINGS.log', 'w') as f:
            for warning in warnings:
                f.write(warning+"\n")

    if len(errors)>0:
        with open('ERRORS.log', 'w') as f:
            for error in errors:
                f.write(error+"\n")
        raise ValueError(str(len(errors))+" errors detected. Please refer to ERRORS.log" )
        

                
def check_values(json_a,json_b,warnings:list,errors:list,nested_key=None,exceptions=[]):
    for key in json_b:
        nested_key.append(key)
        
        ###Check if key is an exception
        if key in exceptions:
            continue

        ###Check if key is missing from auto
        if key not in json_a:
            msg="'"+"/".join(nested_key)+"' not found in user generated JSON"
            errors.append(msg)
            nested_key.pop()
            continue
        
        ###If key object is dictionary result in recursion
        elif type(json_a[key])==dict:
            check_values(json_a[key],json_b[key],warnings,errors,nested_key)
        
        ###If key object is list :
        elif type(json_a[key])==list:

            ###Check list lenght User vs Auto
            if len(json_a[key])!=len(json_b[key]):
                msg="Differing "+"/".join(nested_key)+" list length found in ' : user - "+str(len(json_a[key]))+" vs auto_gen - "+str(len(json_b[key]))
                errors.append(msg)
                nested_key.pop()
                continue

            ###Check per ele entry in list
            for entry in enumerate(json_b[key]):

                ###If key object ele is dictionary result in recursion
                if type(entry[1])==dict:
                    check_values(json_a[key][entry[0]],json_b[key][entry[0]],warnings,errors,nested_key)
                else:
                    if json_a[key][entry[0]]!=json_b[key][entry[0]] and json_b[key][entry[0]] !=None:
                        msg="Differing values found when comparing'"+"/".join(nested_key)+"' : user - "+str(json_a[key][entry[0]])+" vs auto_gen - "+str(json_b[key][entry[0]])
                        errors.append(msg)
                        nested_key.pop(-1)
                        continue
                    
        
        if json_a[key]!=json_b[key] and json_b[key]!=None:
            msg="Differing values found when comparing '"+"/".join(nested_key)+"' : user - "+str(json_a[key])+" vs auto_gen - "+str(json_b[key])
            errors.append(msg)
            nested_key.pop()
            continue

        nested_key.pop()
    
    return(warnings,errors)

if __name__ == "__main__":
    main()
