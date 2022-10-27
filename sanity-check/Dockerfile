FROM pegi3s/fastqc:0.11.9

LABEL org.opencontainers.image.source https://github.com/icgc-argo/argo-data-submission

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
