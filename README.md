# Argo data submission packages

Workflow for interacting with EGA and download files off their servers using Pyega3 or Aspera.

Given a CSV file of: 
1. Registered samples
2. EGA ids (minimum EGAFs) 
3. metadata json payloads (Optional. If provided will verify elements otherwise will auto generate)

Run generate_params_json.py for nextflow params file specific to one sample:
```
python3 generate_params_json.py -o ${working_directory} -c ${input_csv} -s {sample_of_interest}
```

[For output see example_config.json ](https://github.com/edsu7/argo-data-submission#:~:text=10%20days%20ago-,example_config.json,-update%20to%20workflow)

To run as aspera
```
export ASCP_SCP_HOST=''
export ASCP_SCP_USER=''
export ASPERA_SCP_PASS=''
export C4GH_PASSPHRASE=''
export ICGC_ARGO_API_TOKEN=''

nextflow \\
argo-data-submission/main.nf \\
-params-file example.json \\
-profile aspera \\
--api_token ${ICGC_ARGO_API_TOKEN}

```
To run as pyega3
```
export PYEGA3_EGA_USER=""
export PYEGA3_EGA_PASS=""
export ICGC_ARGO_API_TOKEN=''

nextflow \\
argo-data-submission/main.nf \\
-params-file example.json \\
-profile pyega3 \\
--api_token ${ICGC_ARGO_API_TOKEN}
```
(Profiles to be added to avoid populating variables related to unused method)

