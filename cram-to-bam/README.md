# Package cram-to-bam


Converts CRAM files to BAM files for data submission.


## Package development

The initial version of this package was created by the WorkFlow Package Manager CLI tool, please refer to
the [documentation](https://wfpm.readthedocs.io) for details on the development procedure including
versioning, updating, CI testing and releasing.


## Inputs
If reference file is compressed
```
nextflow \
../main.nf \
--reference_file hs37d5.fa.gz \
--fai_file hs37d5.fa.gz.fai \
--gzi_file hs37d5.fa.gz.gzi \
--input_file input/test_rg_3.cram
```
Otherwise
```
nextflow \
../main.nf \
--reference_file hs37d5.fa \
--fai_file hs37d5.fa.fai \
--input_file input/test_rg_3.cram
```

## Outputs

See working directory for bam file


## Usage

### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo/argo-data-submission/cram-to-bam/main.nf -r cram-to-bam.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/icgc-argo/argo-data-submission/cram-to-bam@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo/argo-data-submission/cram-to-bam@0.1.0/main.nf`
