FROM ubuntu:18.04

LABEL org.opencontainers.image.source https://github.com/edsu7/argo-data-submission
LABEL org.opencontainers.image.authors Edmund Su (edmund.su@oicr.on.ca)
LABEL org.opencontainers.image.title ICGC ARGO Data download image

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev software-properties-common curl && \
    apt-get install -y libz-dev pkg-config libtool m4 autotools-dev automake libncurses5-dev libbz2-dev liblzma-dev

RUN pip3 install numpy

RUN mkdir /tools

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

RUN groupadd -g 1000 ubuntu &&\
    useradd -l -u 1000 -g ubuntu ubuntu &&\
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

USER ubuntu

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
