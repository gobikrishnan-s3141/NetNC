FROM ubuntu:latest

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

RUN cpanm Math::Pari

RUN mkdir ~/NetNC
WORKDIR ~/NetNC

COPY . .
RUN cp -r /~/NetNC /usr/local/bin/
RUN wget https://staging2.inetbio.org/humannetv3/networks/HumanNet-FN.tsv

RUN ls && pwd

RUN  perl /usr/local/bin/NetNC/NetNC_v2pt2.pl -n HumanNet-FN.tsv -i test/test_genelist.txt -o test/exampleOutput/testrun-z 10 -F -M -l test/test_background_genelist.txt

