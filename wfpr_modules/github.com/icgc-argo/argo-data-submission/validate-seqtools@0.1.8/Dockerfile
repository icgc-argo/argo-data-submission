FROM ubuntu:18.04

LABEL org.opencontainers.image.source https://github.com/icgc-argo/argo-data-submission
LABEL org.opencontainers.image.authors Edmund Su (edmund.su@oicr.on.ca)
LABEL org.opencontainers.image.title ICGC ARGO Data Submission Validation image

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev software-properties-common curl && \
    apt-get install -y libz-dev pkg-config libtool m4 autotools-dev automake libncurses5-dev libbz2-dev liblzma-dev && \
    apt-get install -y git-all && \
    apt-get install -y jq && \
    apt-get install -y locales pigz pbzip2

# Set local

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

RUN mkdir /tools

RUN pip3 install --upgrade pip

# Install samtools

RUN cd /tmp &&\
	curl -sSL -o samtools-1.15.1.tar.bz2 --retry 10 https://github.com/samtools/samtools/releases/download/1.15.1/samtools-1.15.1.tar.bz2 &&\
	tar xf samtools-1.15.1.tar.bz2 &&\
	cd samtools-1.15.1 &&\
	./configure &&\
	make &&\
	make install

# Install seq-tools

RUN pip install git+https://github.com/icgc-argo/seq-tools.git@1.2.5
#RUN git clone https://github.com/icgc-argo/seq-tools.git@1.1.0 &&\
#    git clone https://github.com/icgc-argo/seq-tools.git@1.1.0
#    cd seq-tools &&\
#    pip3 install -r requirements.txt  &&\
#    pip3 install .
    
ENV PATH="/tools:${PATH}"

COPY *.py /tools/

RUN groupadd -g 1000 ubuntu &&\
    useradd -l -u 1000 -g ubuntu ubuntu &&\
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

USER ubuntu

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
