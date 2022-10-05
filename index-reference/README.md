# Package index-reference


The following package generates indices from `.fasta`,`.fa`,`.fna`,`.fasta.gz`,`.fa.gz` or `.fna.gz`

Note for `.fasta.gz`,`.fa.gz` or `.fna.gz` must be compressed by `gzip` or `bgzip`. Certain older files may use `RAZF` format [which has since been deprecated](https://github.com/samtools/samtools/issues/1387). This step will fail when encountering said formatting and it is recommended to `gunzip` the file and re-run on the output (note the `gunzip` step will throw warnings).
## Package development

The initial version of this package was created by the WorkFlow Package Manager CLI tool, please refer to
the [documentation](https://wfpm.readthedocs.io) for details on the development procedure including
versioning, updating, CI testing and releasing.


## Inputs

If reference file is compressed
```
../main.nf \
--reference_file hs37d5.fa.gz
```
Otherwise
```
nextflow \
../main.nf \
--reference_file hs37d5.fa
```

## Outputs

See working directory.
If reference file was compressed
```
hs37d5.fa.gz
hs37d5.fa.gz.gzi
hs37d5.fa.gz.fai
```
Otherwise
```
hs37d5.fa
hs37d5.fa.fai
```


## Usage

### Run the package directly

With inputs prepared, you should be able to run the package directly using the following command.
Please replace the params file with a real one (with all required parameters and input files). Example
params file(s) can be found in the `tests` folder.

```
nextflow run icgc-argo/argo-data-submission/index-reference/main.nf -r index-reference.v0.1.0 -params-file <your-params-json-file>
```

### Import the package as a dependency

To import this package into another package as a dependency, please follow these steps at the
importing package side:

1. add this package's URI `github.com/icgc-argo/argo-data-submission/index-reference@0.1.0` in the `dependencies` list of the `pkg.json` file
2. run `wfpm install` to install the dependency
3. add the `include` statement in the main Nextflow script to import the dependent package from this path: `./wfpr_modules/github.com/icgc-argo/argo-data-submission/index-reference@0.1.0/main.nf`
