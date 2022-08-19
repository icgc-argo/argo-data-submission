# Package decrypt-aspera


Cryp4gh wrapper to decrypted files


## Inputs

File with the file suffix ".c4gh"


## Outputs

Decrypted file (same name without ".c4gh" suffix)
Decrypted file w/ md5sum (same name with ".md5" suffix)

## Usage

#### Contents of Param-file
```
{
	"file":"input/mystery_file.bam.c4gh", ### File to decrypt
	"c4gh_secret_key":"input/C4GH_SECRET_KEY.txt", ### Public secret key
	"c4gh_pass_phrase":"" ### Public secret key passphrase
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
nextflow run edsu7/argo-data-submission/decrypt-aspera/main.nf -r decrypt-aspera.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/edsu7/argo-data-submission/decrypt-aspera@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/edsu7/argo-data-submission/decrypt-aspera@0.1.0/main.nf`
