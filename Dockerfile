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
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    NETNC_HOME=/opt/NetNC
ARG CONDA_VER=latest
ARG OS_TYPE=x86_64
ARG PY_VER=3.12
ARG NETWORKX_VER=3.4.2
ARG NUMPY_VER=2.2.5

# install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
	cpanminus \
        r-base \
        python3 \
        python3-dev \
        python3-pip \
        perl \
        pari-gp \
        libpari-dev \
        git \
	neovim \
        wget && rm -rf /var/lib/apt/lists/*

# install math::pari using cpanm
RUN cpanm Math::Pari

# Install miniforge to /opt/miniforge
RUN wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
RUN bash Miniforge3.sh -b -p /opt/conda
RUN rm Miniforge3.sh
ENV PATH="/opt/conda/bin:${PATH}"
RUN conda update -y conda
RUN conda init

# Install packages from conda 
RUN conda install -c conda-forge -y python=${PY_VER} \
    networkx=${NETWORKX_VER} \
    numpy=${NUMPY_VER}

# user
ARG USERNAME=mamba
RUN useradd -M -s /bin/bash -p '!' $USERNAME && usermod -a -G sudo $USERNAME

# workspace
RUN mkdir -p $NETNC_HOME && chown -R $USERNAME:$USERNAME $NETNC_HOME 
WORKDIR $NETNC_HOME
RUN git clone https://github.com/gobikrishnan-s3141/NetNC.git && cd NetNC

# copy files into workspace
# COPY . .
RUN cp -r /opt/NetNC /usr/local/bin/
RUN chmod +x /usr/local/bin/NetNC/FCS.pl

# Run NetNC with test dataset
RUN perl NetNC_v2pt2.pl -n test/network/test_net.txt -i test/test_genelist.txt -o test/exampleOutput/PID/PID_NodeCent_z10 -z 100 -E -M -l test/test_background_genelist.txt
CMD ["/bin/bash"]
