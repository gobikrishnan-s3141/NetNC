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

# install math::pari using cpanm; -std=gnu89 required for pari-2.3.5 K&R function pointers
RUN CFLAGS="-std=gnu89" cpanm --notest Math::Pari

# workspace
RUN git clone https://github.com/gobikrishnan-s3141/NetNC.git /opt/NetNC
WORKDIR $NETNC_HOME

# uv installation
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
RUN uv venv --python 3.13 .venv && uv pip install numpy networkx

# copy files into workspace
RUN cp -r /opt/NetNC /usr/local/bin/
RUN chmod +x /usr/local/bin/NetNC/FCS.pl

# Run NetNC with test dataset (Replace this line pointing to your own dataset & analysis modes either Pathway Identification or Functional Target Identification mode)
RUN perl NetNC_v2pt2.pl -n test/network/test_net.txt -i test/test_genelist.txt -o test/exampleOutput/PID/PID_NodeCent_z10 -z 100 -E -M -l test/test_background_genelist.txt
CMD ["/bin/bash"]
