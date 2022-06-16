# Package decrypt-aspera


Cryp4gh wrapper to decrypted files


## Inputs

File with the file suffix ".c4gh"


## Outputs

Decrypted file (same name without ".c4gh" suffix)
Decrypted file w/ md5sum (same name with ".md5" suffix)

## Usage

### Test run
`nextflow run tests/checker.nf -params-file tests/test-job-generate.json`

### IRL run
```
export C4GH_PASSPHRASE=''
nextflow run main.nf -params-file tests/test-job-generate.json
```
### Run the package directly


With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run edsu7/argo-data-submission/decrypt-aspera/main.nf -r decrypt-aspera.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/edsu7/argo-data-submission/decrypt-aspera@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/edsu7/argo-data-submission/decrypt-aspera@0.1.0/main.nf`
