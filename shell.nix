{ pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) {} , token } :
  pkgs.mkShell
    {
      buildInputs =
        let
	  constants =
	    {
	      on = "b0980023-1d94-4330-9115-5a38a20088c5" ;
	      push = "68eb0e41-0b86-40ea-a11f-85be4e43ac4d" ;
	      _with = "c1f17318-5d0a-4afb-8c0e-1d046e834104" ;
	    } ;
          dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
	  objects =
	    {
	      init =
	        {
		  name = "test" ;
		  "${ constants.on }" =
		    {
		      push = constants.on ;
		    } ;
		  env =
		    {
		      implementation-base = "${ dollar "IMPLEMENTATION_BASE" }" ;
		      test-base = "${ dollar "TEST_BASE" }" ;
		      tester-base = "${ dollar "TESTER_BASE" }" ;
		    } ;
		  jobs =
		    {
		      pre-check =
		        {
			} ;
		      check =
		        {
		          runs-on = "ubuntu-latest" ;
			  needs = [ "pre-check" ] ;
			  steps =
			    [
			      { uses = "actions/checkout@v3" ; }
			      { uses = "cachix/install-nix-action@v18" ; "${ constants._with }" = { extra_nix_config = "access-tokens = github.com = ${ dollar "{ github.TOKEN }" }" ; } ; }
			      {
			        uses = "workflow/nix-shell-action@v3" ;
				"${ constants._with }" =
				  {
				    flakes = "tester#check" ;
				    script =
				      ''
				      '' ;
				  } ;
			      }
			    ] ;
			} ;
		    } ;
		} ;
	    } ;
          in
            [
              (
                pkgs.writeShellScriptBin
                  "write-init"
                  ''
		    if [ -d .github ]
		    then
		      ${ pkgs.coreutils }/bin/mkdir .github
		    fi &&
		    if [ -d .github/workflows ]
		    then
		      ${ pkgs.coreutils }/bin/mkdir .github/workflows
		    fi &&
		    ${ pkgs.coreutils }/bin/true
                  ''
              )
              (
                pkgs.writeShellScriptBin
                  "pigsay"
                  ''
                    ${ pkgs.gnused }/bin/sed -e "s#MESSAGE#${ dollar "@" }#" ${ ./pig.ascii }
                  ''
              )
              pkgs.cowsay
              pkgs.chromium
              pkgs.coreutils
	      pkgs.docker
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
          export ARGUE_HOME=/home/emory/projects/h9QAxXE &&
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
