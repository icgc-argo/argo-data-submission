# Package submission-receipt


Please update this with a brief introduction of the package.


## Package development

The initial version of this package was created by the WorkFlow Package Manager CLI tool, please refer to
the [documentation](https://wfpm.readthedocs.io) for details on the development procedure including
versioning, updating, CI testing and releasing.


## Inputs

The following must be supplied in the `params-file`
E.g.
```
    "study_id":"DATA-CA",
    "analysis_id": "8f7d51a3-e7e3-487f-bd51-a3e7e3687777",
    "submission_song_url":"https://submission-song.rdpc-qa.cancercollaboratory.org",
    "files":[
        "TU63.0.R1.fastq.gz",
        "TU63.1.R1.fastq.gz",
        "TU63.2.R1.fastq.gz",
        "TU63.0.R2.fastq.gz",
        "TU63.1.R2.fastq.gz",
        "TU63.2.R2.fastq.gz"
    ]
```


## Outputs

If successful will generate a `submission_receipt.tsv` with the following contents:

```
analysisState   publishedAt     submitterSampleId       submitterSpecimenId     submitterDonorId        sampleId        specimenId      donorId     analysisId      studyId objectId        fileName        fileMd5sum
PUBLISHED   2022-11-22T19:51:05.708225      SL67    TU63    DN7     SA624561        SP224615        DO263184        8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f    DATA-CA e2a8cd91-578e-5851-80fd-5a607404eb0d        TU63.0.R1.fastq.gz      fadfd7e6d62f7847a273a8172b8b6c5b
PUBLISHED   2022-11-22T19:51:05.708225      SL67    TU63    DN7     SA624561        SP224615        DO263184        8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f    DATA-CA a44dda38-ec8f-5436-aa6e-f925f3beee69        TU63.1.R1.fastq.gz      35bbe4b45f46ac59794c397ded077c0a
PUBLISHED   2022-11-22T19:51:05.708225      SL67    TU63    DN7     SA624561        SP224615        DO263184        8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f    DATA-CA 64afbc99-0dec-5b44-961b-6f097e8ffb68        TU63.2.R1.fastq.gz      38daca9509ae9ff8172780489332ec35
PUBLISHED   2022-11-22T19:51:05.708225      SL67    TU63    DN7     SA624561        SP224615        DO263184        8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f    DATA-CA 50c85593-bae3-55aa-af76-dd8d605a0dd8        TU63.0.R2.fastq.gz      e14f248dea6d3b3c149620c204321d97
PUBLISHED   2022-11-22T19:51:05.708225      SL67    TU63    DN7     SA624561        SP224615        DO263184        8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f    DATA-CA 46f20a55-4425-59e0-b715-f865bb6911b3        TU63.1.R2.fastq.gz      1f31503aad97ca24712cf1c44e19cb44
PUBLISHED   2022-11-22T19:51:05.708225      SL67    TU63    DN7     SA624561        SP224615        DO263184        8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f    DATA-CA 2495fd0f-0c5f-55cc-91ac-2c54d2ae4dca        TU63.2.R2.fastq.gz      31e8d713e0c36dcf1c45bc6792248261
```

Examples of errors:
- Bad URL or connection failure
```
Error executing process > 'submissionReceipt'

Caused by:
  Process `submissionReceipt` terminated with an error exit status (1)

Command executed:

  mkdir -p output_dir
  
  main.py       -s DATA-CA       -a 8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f       -u https://submission-song.rdpc-za.cancercollaboratory.org       -f TU63.0.R1.fastq.gz TU63.1.R1.fastq.gz TU63.2.R1.fastq.gz TU63.0.R2.fastq.gz TU63.1.R2.fastq.gz TU63.2.R2.fastq.gz       -o 8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f_submission_receipt.tsv

Command exit status:
  1

Command output:
  Unable to establish connection

Command error:
  HTTPSConnectionPool(host='submission-song.rdpc-za.cancercollaboratory.org', port=443): Max retries exceeded with url: /studies/DATA-CA/analysis/8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f (Caused by NewConnectionError('<urllib3.connection.HTTPSConnection object at 0x7fe35ca77c50>: Failed to establish a new connection: [Errno -2] Name or service not known'))

Work dir:
  /Users/esu/Desktop/GitHub/icgc-argo/argo-data-submission/submission-receipt/tests/work/06/411bfb5eee55ddce608358dcc760a4

Tip: you can try to figure out what's wrong by changing to the process work dir and showing the script file named `.command.sh`
```
- Incorrect `analysis_id`
```
Error executing process > 'submissionReceipt'
Caused by:
  Process `submissionReceipt` terminated with an error exit status (1)

Command executed:

  mkdir -p output_dir
  
  main.py       -s DATA-CA       -a 8f7d51a3-e7e3-487f-bd51-a3e7e3687777       -u https://submission-song.rdpc-qa.cancercollaboratory.org       -f TU63.0.R1.fastq.gz TU63.1.R1.fastq.gz TU63.2.R1.fastq.gz TU63.0.R2.fastq.gz TU63.1.R2.fastq.gz TU63.2.R2.fastq.gz       -o 8f7d51a3-e7e3-487f-bd51-a3e7e3687777_submission_receipt.tsv

Command exit status:
  1

Command output:
  (empty)

Command error:
  analysis 8f7d51a3-e7e3-487f-bd51-a3e7e3687777 in study DATA-CA could not be found

Work dir:
  /Users/esu/Desktop/GitHub/icgc-argo/argo-data-submission/submission-receipt/tests/work/57/e061a6d8f4f3697f892561fc076281

Tip: you can replicate the issue by changing to the process work dir and entering the command `bash .command.run`
```
- Submitted file not found in analysis
```
Error executing process > 'submissionReceipt'
Caused by:
  Process `submissionReceipt` terminated with an error exit status (1)

Command executed:

  mkdir -p output_dir
  
  main.py       -s DATA-CA       -a 8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f       -u https://submission-song.rdpc-qa.cancercollaboratory.org       -f TU63.1.R1.fastq.gz TU63.2.R1.fastq.gz TU63.0.R2.fastq.gz TU63.1.R2.fastq.gz TU63.2.R2.fastq.gz       -o 8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f_submission_receipt.tsv

Command exit status:
  1

Command output:
  (empty)

Command error:
  Specified file TU63.0.R1.fastq.gz was not found in analysis 8f7d51a3-e7e3-487f-bd51-a3e7e3687f7f

Work dir:
  /Users/esu/Desktop/GitHub/icgc-argo/argo-data-submission/submission-receipt/tests/work/12/c4c7403c8480df918f083a3a9a4bd6

Tip: you can try to figure out what's wrong by changing to the process work dir and showing the script file named `.command.sh`
```

## Usage

### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo/argo-data-submission/submission-receipt/main.nf -r submission-receipt.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/icgc-argo/argo-data-submission/submission-receipt@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo/argo-data-submission/submission-receipt@0.1.0/main.nf`
