 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { } ,
    implementation-base ,
    implementation-rev ? null ,
    implementation-home ? false ,
    test-base ,
    test-rev ? null ,
    test-home ? false ,
    tester-base ,
    tester-rev ? null ,
    tester-home ? false ,
    defect ? ""
  } :
    pkgs.mkShell
      {
        buildInputs =
          let
            dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
                      _implementation = mix implementation-base implementation-rev implementation-home ;
                      _test = mix test-base test-rev test-home ;
                      _tester = mix tester-base tester-rev tester-home ;
                      mix =
                        base : rev : home :
                          let
                            separator = if builtins.typeOf rev == "string" then "?" else "" ;
                            suffix = if builtins.typeOf rev == "string" then rev else "" ;
                            in if home then "${ dollar "GITHUB_WORKSPACE" }" else builtins.concatStringsSep "" [ base separator suffix ] ;
            in
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
