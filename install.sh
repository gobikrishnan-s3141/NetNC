# install.sh for NetNC

#!/usr/bin/env bash

set -euo pipefail

perl --version

CFLAGS="-std=gnu89" cpanm --notest Math::Pari

R --version

python3 --version

pip install networkx==3.5 numpy
