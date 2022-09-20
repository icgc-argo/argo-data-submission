# Package ega-download-wf


Workflow wrapper for download data off EGA servers using Pyega3 or Aspera


## Inputs

### Pyega3
```
{
    "ids_to_download" : ["EGAF00001770106","EGAF00001770107","EGAF00001770108"], ### EGA File IDs
    "pyega3_ega_user" : "ega-test-data@ebi.ac.uk", ### EGA-archive Login
    "pyega3_ega_pass" : "egarocks", ### EGA-archive Password
    "download_mode" : "pyega3"
}
```

### Aspera
```
{
    "id_to_download" : "EGAF00004257597", ### EGAF File ID
    "file_to_download" : "EGAD00001007785/PART_09/EGAR00002324607_SLX-18928.UDP0002.bam.c4gh", ### Aspera file directory Path
    "ascp_scp_user" : "ega-test-data", ### EGA Aspera User
    "ascp_scp_host" : "ebi.ac.uk", ### EGA Aspera Server
    "aspera_scp_pass" : "egarocks", ### EGA Aspera password
    "c4gh_pass_phrase": "charlie", ### C4GH encryption passphrase
    "c4gh_secret_key" : "/home/ubuntu/testing/dbox_key",  ### local C4GH encryption key
    "download_mode" : "aspera"
}
```

## Outputs

See individual modules for output. Should be sequencing files i.e. `BAM`,`CRAM`,`fastq.gz`


## Usage

### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo/argo-data-submission/ega-download-wf/main.nf -r ega-download-wf.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/icgc-argo/argo-data-submission/ega-download-wf@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo/argo-data-submission/ega-download-wf@0.1.0/main.nf`
