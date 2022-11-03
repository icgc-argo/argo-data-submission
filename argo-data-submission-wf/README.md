# Package download-aspera

Wrapper for convert ICGC ARGO Metadata JSON Payloads into TSVs (Experiment,file and read_groups)


## Inputs

A JSON metadata payload and data directory


## Outputs

`Experiment.tsv` according to [dictionary](https://github.com/icgc-argo/argo-data-submission/blob/main/metadata_dictionary/experiment_dict.tsv)

`File.tsv` according to [dictionary](https://github.com/icgc-argo/argo-data-submission/blob/main/metadata_dictionary/files_dict.tsv)

`Read_group.tsv` according to [dictionary](https://github.com/icgc-argo/argo-data-submission/blob/main/metadata_dictionary/read_groups_dict.tsv)


## Usage

#### Test run
```
nextflow run checker.nf -params-file test.json
```

#### IRL run
```
nextflow run ../main.nf -params-file test.json
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
