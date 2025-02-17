# Fedora base image - Fedora-41
FROM fedora:41

# metadata
LABEL base_image="Fedora 41"
LABEL version="1"
LABEL about.summary="Network Neighbourhood Clustering"
LABEL about.home="https://github.com/overton-group/NetNC"
LABEL about.documentation="https://doi.org/10.3390/cancers12102823"
LABEL about.license_file="https://github.com/overton-group/NetNC/blob/master/LICENSE.txt"
LABEL about.license="GNU general public license (GPL) version 3"
LABEL about.tags="Network biology,transcriptomics"

# Environmental variables - NetNC home and build home
ENV NETNC_HOME=~/NetNC \
    BUILD_HOME=/build

# install system dependencies
RUN dnf -y update && dnf -y upgrade && dnf install -y --setopt=install_weak_deps=False \
    @development-tools \
    wget \
    curl \
    zip \
    R-core \
    python3 \
    python3-devel \
    python3-pip \
    python3-numpy \
    python3-networkx \
    perl \
    pari \
    pari-devel \
    git \
    zlib-devel && \
    dnf clean all

# install math::pari using cpanm
RUN cpan Math::Pari

# workspace
RUN mkdir -p $NETNC_HOME 
WORKDIR $NETNC_HOME

# copy files into workspace
COPY . .
RUN cp -r /~/NetNC /usr/local/bin/

# Run NetNC with test dataset
RUN perl NetNC_v2pt2.pl -n test/network/test_net.txt -i test/test_genelist.txt -o test/exampleOutput/PID/PID_NodeCent_z10 -z 100 -E -M -l test/test_background_genelist.txt
