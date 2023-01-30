# Try this
( IMPLEMENTATION=/home/emory/projects/U2LgC3oQ && TEST=/home/emory/projects/Ruo71RvT && TESTER=/home/emory/projects/U2LgC3oQ && cd $(mktemp -d) && nix flake init && sed -e "s#\${IMPLEMENTATION}#${IMPLEMENTATION}#" -e "s#\${TEST}#${TEST}#" -e "s#\${TESTER}#${TESTER}#" -e "wflake.nix" ${TESTER}/original.nix flake.nix && nix develop --command check )

