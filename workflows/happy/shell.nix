 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { } ,
  } :
    pkgs.mkShell
      {
        buildInputs =
          [
            (
              pkgs.writeShellScriptBin
                "check"
                    ''
                      ${ pkgs.coreutils }/bin/echo IMPLEMENTATION=${ _implementation } &&
                      ${ pkgs.coreutils }/bin/echo TEST=${ _test } &&
                      ${ pkgs.coreutils }/bin/echo TESTER=${ _tester } &&
                      cd $( ${ pkgs.mktemp }/bin/mktemp --directory ) &&
                      ${ pkgs.git }/bin/git init &&
                      ${ pkgs.git }/bin/git config user.name "No User" &&
                      ${ pkgs.git }/bin/git config user.email "noone@nothing" &&
                      ${ pkgs.gnused }/bin/sed \
                        -e "s#\${ dollar "IMPLEMENTATION" }#${ _implementation }#" \
                        -e "s#\${ dollar "TEST" }#${ _test }#" \
                        -e "s#\${ dollar "TESTER" }#${ _tester }#" \
                        -e "wflake.nix" \
                        ${ ./flake.nix }&&
                      ${ pkgs.coreutils }/bin/chmod 0400 flake.nix &&
                      ${ pkgs.git }/bin/git add flake.nix &&
                      ${ pkgs.git }/bin/git commit --allow-empty-message --message "" &&
                      DEFECT=$( ${ pkgs.nix }/bin/nix develop --command check ) &&
                      ${ pkgs.coreutils }/bin/echo OBSERVED DEFECT=${ dollar "DEFECT" } &&
                      ${ pkgs.coreutils }/bin/echo EXPECTED DEFECT=${ defect } &&
                      if [ "${ dollar "DEFECT" }" == "${ defect }" ]
                      then
                        ${ pkgs.coreutils }/bin/echo DEFECT IS GOOD
                      else
                        ${ pkgs.coreutils }/bin/echo DEFECT IS BAD &&
                        exit 64
                      fi &&
                      ${ pkgs.coreutils }/bin/true
                    ''
            )
          ] ;
      }
