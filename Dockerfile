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
RUN apt update && apt-get install -y --no-install-recommends build-essential \
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
        curl && rm -rf /var/lib/apt/lists/*

# install math::pari using cpanm
RUN cpanm Math::Pari

# Use the above args 
ARG CONDA_VER
ARG OS_TYPE
# Install miniconda to /miniconda
RUN curl -LO "http://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh"
RUN bash Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh -p /miniconda -b
RUN rm Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda
RUN conda init

ARG PY_VER
ARG PANDAS_VER
# Install packages from conda 
RUN conda install -c anaconda -y python=${PY_VER}
RUN conda install -c anaconda -y \
    networkx=${NETWORKX_VER} \
    numpy=${NUMPY_VER}

# user
ARG USERNAME=mamba
RUN useradd -M -s /bin/bash -p '!' $USERNAME && usermod -a -G sudo $USERNAME

# workspace
RUN mkdir -p $NETNC_HOME && chown -R $USERNAME:$USERNAME $NETNC_HOME 
WORKDIR $NETNC_HOME

# copy files into workspace
COPY . .
RUN cp -r /opt/NetNC /usr/local/bin/

# Run NetNC with test dataset
RUN perl NetNC_v2pt2.pl -n test/network/test_net.txt -i test/test_genelist.txt -o test/exampleOutput/PID/PID_NodeCent_z10 -z 100 -E -M -l test/test_background_genelist.txt
CMD ["/bin/bash", "-c"]
