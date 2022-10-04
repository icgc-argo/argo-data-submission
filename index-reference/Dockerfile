FROM python:3.7.5-slim-buster

RUN apt-get update && apt-get install -y procps

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/data-processing-utility-tools
RUN apt-get update && \
    apt-get install -y python3-pip python3-dev software-properties-common curl && \
    apt-get install -y libz-dev pkg-config libtool m4 autotools-dev automake libncurses5-dev libbz2-dev liblzma-dev

RUN cd /tmp &&\
	curl -sSL -o samtools-1.15.1.tar.bz2 --retry 10 https://github.com/samtools/samtools/releases/download/1.15.1/samtools-1.15.1.tar.bz2 &&\
	tar xf samtools-1.15.1.tar.bz2 &&\
	cd samtools-1.15.1 &&\
	./configure &&\
	make &&\
	make install

RUN groupadd -g 1000 ubuntu &&\
    useradd -l -u 1000 -g ubuntu ubuntu &&\
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

USER ubuntu

CMD ["/bin/bash"]