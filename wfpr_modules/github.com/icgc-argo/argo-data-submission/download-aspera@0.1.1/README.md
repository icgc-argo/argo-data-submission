# Package download-aspera

Wrapper for Aspera to download files


## Inputs

See contents of `param-file`


## Outputs

Supplied file to be downloaded


## Usage

#### Contents of Param-file
```
{
    "target_file" : "/aspera-test-dir-large/100MB", ### File to be download 
    "EGAF" : "EGAF000001", ### Associated EGAF id
    "ASCP_SCP_HOST" : "demo.asperasoft.com", ### Host server address
    "ASCP_SCP_USER" : "aspera", ### Host provided username
    "ASPERA_SCP_PASS" : "demoaspera" ### Host provided password
}
```

#### Test run
`nextflow run checker.nf -params-file test-job-aspera.json`

#### IRL run
```
nextflow run ../main.nf -params-file test-job-aspera.json
```

### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo/argo-data-submission/download-aspera/main.nf -r download-aspera.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/icgc-argo/argo-data-submission/download-aspera@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo/argo-data-submission/download-aspera@0.1.0/main.nf`
