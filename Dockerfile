# ubuntu base image - Ubuntu LTS
FROM ubuntu:24.04

# metadata
LABEL base_image="Ubuntu 24.04 LTS"
LABEL version="1"
LABEL about.summary="Network Neighbourhood Clustering"
LABEL about.home="https://github.com/overton-group/NetNC"
LABEL about.documentation="https://doi.org/10.3390/cancers12102823"
LABEL about.license_file="https://github.com/overton-group/NetNC/blob/master/LICENSE.txt"
LABEL about.license="GNU general public license (GPL) version 3"
LABEL about.tags="Network biology,transcriptomics"

# Environmental variables - NetNC home and build home
ENV NETNC_HOME=/opt/NetNC \
    BUILD_HOME=/build

# install system dependencies
RUN apt update && apt-get install -y --no-install-recommends build-essential \
        cpanminus \
        r-base \
        python3 \
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-networkx \
        perl \
        pari-gp \
        libpari-dev \
        git \
        wget && rm -rf /var/lib/apt/lists/*

# install math::pari using cpanm
RUN cpan Math::Pari

# workspace
RUN mkdir -p $NETNC_HOME 
WORKDIR $NETNC_HOME

# copy files into workspace
COPY . .
RUN cp -r /opt/NetNC /usr/local/bin/

# Run NetNC with test dataset
RUN perl NetNC_v2pt2.pl -n test/network/test_net.txt -i test/test_genelist.txt -o test/exampleOutput/PID/PID_NodeCent_z10 -z 100 -E -M -l test/test_background_genelist.txt
