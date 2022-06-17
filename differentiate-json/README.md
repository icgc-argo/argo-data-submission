# Package differentiate-json


Compares User provided JSON against Pipeline's generate JSON denoting differences. Uses the `auto_generated.json`'s expected fields to compare in user provided

## Inputs

Two JSON files.


## Outputs

#### Successful instance
Step succeeds and no `ERRORS.log` is generated

#### Example of ERRORS.log
```
Differing values found when comparing 'samples/donor/submitterDonorId' : user - EVIL_TEST_DONOR vs auto_gen - TEST_DONOR
Differing values found when comparing 'read_groups/read_group_id_in_bam' : user - QCMG:22f321c6-ff3f-11e4-8e8b-f8a0800c69f0:130711_7001243_0176_BD2B86ACXX.lane_7.GCACAG.1 vs auto_gen - QCMG:22f321c6-ff3f-11e4-8e8b-f8a0800c69f0:130711_7001243_0176_BD2B86ACXX.lane_7.CTTGTA.1
'read_groups/read_length_r1' not found in user generated JSON
'read_groups/read_length_r2' not found in user generated JSON
```

#### Test run
`nextflow run checker.nf -params-file test-job-decrypt.json`

#### IRL run
```
nextflow run main.nf -params-file tests/test-job-decrypt.json
```


## Usage

### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo/argo-data-submission/differentiate-json/main.nf -r differentiate-json.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/icgc-argo/argo-data-submission/differentiate-json@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo/argo-data-submission/differentiate-json@0.1.0/main.nf`
