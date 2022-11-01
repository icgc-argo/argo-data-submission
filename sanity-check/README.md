# Package differentiate-json

Updates provided `file_info_tsv` with additional fields from Clinical. This step is to avoid mismatching info for the same field between Clinical.SONG and Submission.SONG.

## Inputs

`File_info_tsv` - See argo-data-submission-wf
'api_token' - Valid API token retrievable from Platform 
'song_url' - Valid Song URL
'clinical_url' - Valid Clinical URL

## Outputs
`updated_file_info.tsv`
#### Successful instance

An `updated_file_info.tsv` is generated

#### Example of Errors

Unregistered Project
```
Project LUNCHTIME does not exist or no samples have been registered
```
Unregistered donor
```
submitter_donor_id:'BATMAN' was not found in project:'TEST-PR'. Verify sample has been registered.
```
Project registered but not in SONG
```
Program TEST-JP does not exist. Please verify program code is correct. Otherwise contact DCC-admin for help to troubleshoot.
```
Sample with existing analysis
```
Sample 'TEST_SUBMITTER_SAMPLE_ID_ujolwwdsmgN1'/'SA623974' has an existing published analysis '15e3ffd2-16a2-465d-a3ff-d216a2765d4f' for experiment_strategy 'WGS.'
```
Mismatched valid IDs
```
ID Mismatch detected. Specimen_id:'TEST_SUBMITTER_SPECIMEN_ID_ujolwwdsmgN1'/'SP223585' was not found within Donor:'DN108'/'DO263239' 's specimens
```

#### Test run
`nextflow run checker.nf -params-file local_good_copy.json --api_token ${token}`

#### IRL run
```
nextflow run main.nf -params-file local_good_copy.json --api_token ${token}
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
