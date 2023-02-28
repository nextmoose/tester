{ pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) {} , token } :
  pkgs.mkShell
    {
      buildInputs =
        let
          dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
	  yq =
	    expressions :
	      let
	        constants = inner-constants // outer-constants ;
	        inner-constants =
		  {
		    delete = "67fe9630-a4ae-4a39-9dbf-a790a5575f1b" ;
		    period = "6ff1b0c2-75bf-46cc-b0e9-7e75d687f8e4" ;
		  } ;
	        outer-constants =
		  {
		    on = "df5d8dd4-a49f-4c1f-b6e6-9ca45ee30494" ;
		    push = "9ab16531-3d37-4c87-b293-cfc55370a934" ;
		  } ;
		worder = expression : expression constants ;
		enquote = expression : builtins.concatStringsSep "" [ "\"" ( builtins.toString expression ) "\"" ] ;
		decoder = builtins.replaceStrings [ ( enquote inner-constants.delete ) ( enquote inner-constants.period ) ] [ "del(.true)" "." ] ;
		phrase = builtins.concatStringsSep " + " ( builtins.map decoder ( builtins.map builtins.toJSON ( builtins.map worder expressions ) ) ) ;
	        program =
		  pkgs.writeShellScript
		    "yq"
		    ''
		      ${ pkgs.coreutils }/bin/echo '${ phrase }' &&
		      ${ pkgs.coreutils }/bin/tee | ${ pkgs.yq }/bin/yq --yaml-output '${ phrase }' | ${ pkgs.gnused }/bin/sed -e "s#${ outer-constants.on }#on#" -e "s#${ outer-constants.push }##"
		    '' ;
		in program ;
          in
            [
	      (
	        pkgs.writeShellScriptBin
		  "mine"
		  ''
		    ${ pkgs.coreutils }/bin/cat .github/workflows/test.yaml | ${ yq [ ( constants : constants.delete ) ( constants : { name = "feed" ; "${ constants.on }" = { push = constants.push ; } ; } ) ] }
		  ''
	      )
	      pkgs.cowsay
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
                  "manual-check-test"
                  ''
                    IMPLEMENTATION="${ dollar 1 }" &&
                    TESTER="${ dollar 2 }" &&
                    DEFECT="${ dollar 3 }" &&
                    ${ pkgs.nix }/bin/nix-shell \
                      .github/workflows/check/shell.nix \
                      --argstr implementation-base "${ dollar "IMPLEMENTATION" }" \
                      --argstr test-base "$( ${ pkgs.coreutils }/bin/pwd )" \
                      --argstr tester-base "${ dollar "TESTER" }" \
                      --argstr defect "${ dollar "DEFECT" }" \
                      --command check
                  ''
              )
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
          echo ${ token } | ${ pkgs.gh }/bin/gh auth login --with-token &&
          ${ pkgs.coreutils }/bin/echo STRUCTURE FLAKE DEVELOPMENT ENVIRONMENT
        '' ;
    }
