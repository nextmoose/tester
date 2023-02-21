{ pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) {} } :
  pkgs.mkShell
    {
      buildInputs =
        let
         dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
          in
            [
              pkgs.chromium
              pkgs.coreutils
              pkgs.emacs
              pkgs.gh
              pkgs.github-runner
              pkgs.inetutils
              pkgs.jq
              pkgs.mktemp
              pkgs.yq
              pkgs.moreutils
              (
                pkgs.writeShellScriptBin
                 "cleanup"
                 ''
                    ${ pkgs.coreutils }/bin/date &&
                    ${ pkgs.coreutils }/bin/df -h &&
                    ${ pkgs.nix }/bin/nix-collect-garbage > /dev/null 2>&1 &&
                    ${ pkgs.coreutils }/bin/df -h &&
                    ${ pkgs.coreutils }/bin/date &&
                    TEMP=$( ${ pkgs.mktemp }/bin/mktemp --dry-run ) &&
                    ${ pkgs.findutils }/bin/find $( ${ pkgs.coreutils }/bin/dirname ${ builtins.concatStringsSep "" [ "$" "{" "TEMP" "}" ] } ) -name "tmp.*" -exec ${ pkgs.coreutils }/bin/rm --recursive --force {} \;
                    ${ pkgs.coreutils }/bin/df -h &&
                    ${ pkgs.coreutils }/bin/date
                  ''
              )
            ] ;
      shellHook =
        ''
          export ARGUE_HOME=/home/emory/projects/h9QAx8XE &&
          export APPLY_HOME=/home/emory/projects/L5bpxC6n &&
          export BASH_VARIABLE_HOME=/home/emory/projects/5juNXfpb &&
          export PERSONAL_HOME=/home/emory/projects/71tspv3q &&
          export SHELL_HOME=/home/emory/projects/4GBaUR7F &&
          export SCRIPT_HOME=/home/emory/projects/NQTf0d1m &&
          export STRIP_HOME=/home/emory/projects/0TFnR2fJ &&
          export TRY_HOME=/home/emory/projects/0gG3HgHu &&
          export UTILS_HOME=/home/emory/projects/MGWfXwul &&
          export VISIT_HOME=/home/emory/projects/wHpYNJk8 &&
          ${ pkgs.coreutils }/bin/echo STRUCTURE FLAKE DEVELOPMENT ENVIRONMENT
        '' ;
    }
