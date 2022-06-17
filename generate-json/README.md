# Package decrypt-aspera


Generate SONG payload

## Inputs

See `param-file` contents

## Outputs

Metadata JSON payload for song

## Usage

#### Contents of Param-file
```
{
	"program_id":"TEST-PR",
	"submitter_donor_id":"TEST_DONOR",
	"gender":"Male",
	"submitter_specimen_id":"TEST_SPECIMEN",
	"specimen_tissue_source":"Blood derived",
	"tumour_normal_designation":"Normal",
	"specimen_type":"Normal",
	"submitter_sample_id":"TEST_SAMPLE",
	"sample_type":"Total DNA",
	"matched_normal_submitter_sample_id":"",
	"EGAX":"EGAX00000000001",
	"EGAN":"EGAN00000000001",
	"EGAR":"EGAR00000000001,EGAR00000000002,EGAR00000000003",
	"EGAF":"EGAF00000000001",
	"experimental_strategy":"WGS",
	"output_files":[
		"input/CC3D8AAWW_5_TATAAT_1.fastq.gz",
		"input/CC3D8AAWW_5_TATAAT_2.fastq.gz",
	],
	"md5_files":[
		"input/CC3D8AAWW_5_TATAAT_1.fastq.gz.md5",
		"input/CC3D8AAWW_5_TATAAT_2.fastq.gz.md5",
	]
}

```

#### Test run
`nextflow run checker.nf -params-file test-job-generate.json`

#### IRL run
```
nextflow run ../main.nf -params-file test-job-generate.json
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

1. add this package's URI `github.com/edsu7/argo-data-submission/generate-json@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/edsu7/argo-data-submission/generate-json@0.1.0/main.nf`
