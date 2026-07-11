# install.sh for NetNC

#!/usr/bin/env bash

set -euo pipefail

perl --version

CFLAGS="-std=gnu89" cpan --notest Math::Pari

R --version

python3 --version

python3 -m "pip3 install networkx numpy" # (or use -r requirements.txt)
