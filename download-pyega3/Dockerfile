FROM ubuntu:18.04

LABEL org.opencontainers.image.source https://github.com/edsu7/argo-data-submission
LABEL org.opencontainers.image.authors Edmund Su (edmund.su@oicr.on.ca)
LABEL org.opencontainers.image.title ICGC ARGO Data download image

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev software-properties-common curl && \
    apt-get install -y libz-dev pkg-config libtool m4 autotools-dev automake libncurses5-dev libbz2-dev liblzma-dev

RUN mkdir /tools

# Install Pyega3

RUN cd /tmp &&\
	curl -sSL -o ega-download-client-4.0.3.tar.gz --retry 10 https://github.com/EGA-archive/ega-download-client/archive/refs/tags/v4.0.3.tar.gz  &&\
	tar xf ega-download-client-4.0.3.tar.gz &&\
	cd ega-download-client-4.0.3 && \
	pip3 install .
ENV PATH="/tools:${PATH}"

COPY *.py /tools/

RUN groupadd -g 1000 ubuntu &&\
    useradd -l -u 1000 -g ubuntu ubuntu &&\
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

USER ubuntu

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
