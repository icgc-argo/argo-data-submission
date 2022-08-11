# Package validate-seqtools


Wrapper for Seq-tools used to validate molecular data for ICGC-ARGO submission.
See https://github.com/icgc-argo/seq-tools for more info.


## Inputs

See contents of `param-file`

## Outputs
One of the following validation logs:
```
validation_report.PASS-with-WARNING.jsonl
validation_report.PASS-with-WARNING-and-SKIPPED-check.jsonl
validation_report.PASS.jsonl
validation_report.INVALID.jsonl
```

## Usage

#### Contents of Param-file
```
{
    "json_file": "input/anon_chr1_complete.json", ### Metadata JSON. Output from icgc-argo-workflows/data-processing-utility-tools/payload-gen-seq-experiment
    "files": ["input/anon_chr1_complete.bam"], ### List of files to be submitted. Lane level
}
```


#### Test run
`nextflow run checker.nf -params-file test-job-bam.json`

#### IRL run
`nextflow run ../main.nf -params-file test-job-bam.json`

### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo/argo-data-submission/validate-seqtools/main.nf -r validate-seqtools.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/icgc-argo/argo-data-submission/validate-seqtools@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo/argo-data-submission/validate-seqtools@0.1.0/main.nf`
