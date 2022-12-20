# Package download-pyega3


Wrapper to utilize PYEGA3 downloader to retrieve files from EGA-archive

## Inputs

See `param-file` list

## Outputs

EGAF file, Md5 sum and download logs


## Usage


#### Contents of Param-file
```
{
    "ega_id" : "EGAF00001770106",  ### EGAF id
    "pyega3_ega_user" : "ega-test-data@ebi.ac.uk", ### EGA email with approved EGA and DACO access
    "pyega3_ega_pass" : "egarocks" ### Password used to login on ega-archive.org
}
```

#### Test run
`nextflow run checker.nf -params-file test-job-decrypt.json`

#### IRL run
```
nextflow run main.nf -params-file tests/test-job-decrypt.json
```

### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo/argo-data-submission/download-pyega3/main.nf -r download-pyega3.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/icgc-argo/argo-data-submission/download-pyega3@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo/argo-data-submission/download-pyega3@0.1.0/main.nf`
