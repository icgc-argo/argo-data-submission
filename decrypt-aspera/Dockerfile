FROM ubuntu:18.04

LABEL org.opencontainers.image.source https://github.com/icgc-argo/argo-data-submission

LABEL org.opencontainers.image.authors Edmund Su (edmund.su@oicr.on.ca)
LABEL org.opencontainers.image.title ICGC ARGO Data Decrypt files

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev software-properties-common curl python3-setuptools && \
    apt-get install -y libz-dev pkg-config libtool m4 autotools-dev automake libncurses5-dev libbz2-dev liblzma-dev

RUN pip3 install --upgrade pip &&\
	pip3 install numpy crypt4gh

RUN mkdir /tools

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

RUN groupadd -g 1000 ubuntu &&\
    useradd -l -u 1000 -g ubuntu ubuntu &&\
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

USER ubuntu

RUN groupadd -g 1000 ubuntu &&\
    useradd -l -u 1000 -g ubuntu ubuntu &&\
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

CMD ["/bin/bash"]
