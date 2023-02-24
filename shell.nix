{ pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) {} } :
  pkgs.mkShell
    {
      buildInputs =
        let
          dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
          init =
            {
              test =
                {
                  name = "test" ;
                  "61232b8e-1df9-4f7e-8ec5-538cb9b21aaa" =
                    {
                      push = "e7d90318-28cf-4b6f-81de-cd975c20bc03" ;
                    } ;
                  env = { implementation = "$IMPLEMENTATION" ; test = "$TEST" ; tester = "$TESTER" ; } ;
                  jobs =
		    {
		      branch =
		        {
			  runs-on "ubuntu-latest" ;
			  steps =
			    [
                              { uses = "actions/checkout@v3" ; }
                              { uses = "cachix/install-nix-action@v17" ; "b200830c-8d41-4c5d-964c-5ecaaba35204" = { extra_nix_config = "access-tokens = github.com = ${ dollar "{ secrets.TOKEN }" }" ; } ; }
                              { run = "nix-shell .github/workflows/branch/shell.nix --argstr target "^test/.*\$" --command branch" ; }
			    ] ;
		      check = { runs-on = "ubuntu-latest" ; needs = [ "branch" ] ; steps = [ { run = true ; } ] ; } ;
		    } ;
                } ;
              tester =
                {
                  name = "test" ;
                  "61232b8e-1df9-4f7e-8ec5-538cb9b21aaa" =
                    {
                      push = "e7d90318-28cf-4b6f-81de-cd975c20bc03" ;
                    } ;
                  jobs =
                    {
                      pre-check =
                        {
                          runs-on = "ubuntu-latest" ;
                          steps =
                            [
                              { uses = "actions/checkout@v3" ; }
                              { uses = "cachix/install-nix-action@v17" ; "b200830c-8d41-4c5d-964c-5ecaaba35204" = { extra_nix_config = "access-tokens = github.com = ${ dollar "{ secrets.TOKEN }" }" ; } ; }
                              { run = "nix-shell .github/workflows/check/shell.nix --command check" ; }
                            ] ;
                        } ;
                      check =
                        {
                          runs-on = "ubuntu-latest" ;
			  needs = [ "pre-check" ] ;
                          steps =
                            [
                              { uses = "actions/checkout@v3" ; }
                              { uses = "cachix/install-nix-action@v17" ; "b200830c-8d41-4c5d-964c-5ecaaba35204" = { extra_nix_config = "access-tokens = github.com = ${ dollar "{ secrets.TOKEN }" }" ; } ; }
                              { run = "nix-shell .github/workflows/check/shell.nix --arg implementation-home true --arg tester-home true --command check" ; }
                            ] ;
                        } ;
                    } ;
                } ;
            } ;
            sed =
              pkgs.writeShellScript
              "sed"
              ''
                ${ pkgs.gnused }/bin/sed \
		  -e "s#61232b8e-1df9-4f7e-8ec5-538cb9b21aaa#on#" \
		  -e "s#e7d90318-28cf-4b6f-81de-cd975c20bc03##" \
		  -e "s#b200830c-8d41-4c5d-964c-5ecaaba35204#with#" \
		  -e "w${ dollar "1" }"
              '' ;
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
                  "write-init-test"
                  ''
		    ${ pkgs.git }/bin/git checkout -b init/$( ${ pkgs.util-linux }/bin/uuidgen ) &&
                    ${ pkgs.git }/bin/git commit --allow-empty --allow-empty-message --all --message "" &&
                    ${ pkgs.git }/bin/git fetch origin main &&
                    ${ pkgs.git }/bin/git rebase origin/main &&             
                    IMPLEMENTATION=${ dollar 1 } &&
                    TEST=${ dollar 2 } &&
                    TESTER=${ dollar 3 } &&
                    if ${ pkgs.git }/bin/git rm -r .github
                    then
                      ${ pkgs.coreutils }/bin/rm --recursive --force .github
                    else
                      ${ pkgs.coreutils }/bin/rm --recursive --force .github
                    fi &&
                    ${ pkgs.coreutils }/bin/mkdir .github &&
                    ${ pkgs.coreutils }/bin/mkdir .github/workflows &&
                    ${ pkgs.yq }/bin/yq -n --yaml-output '${ builtins.toJSON init.test }' | ${ sed } .github/workflows/test.yaml &&
                    ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/test.yaml &&
                    ${ pkgs.git }/bin/git add .github/ workflows/test.yaml &&
		    ${ pkgs.coreutils }/bin/mkdir .github/workflows/branch &&
		    ${ pkgs.coreutils }/bin/cp ${ ./workflows/shell.nix } .github/workflows/shell.nix &&
		    ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/shell.nix &&
		    ${ pkgs.git }/bin/git add .github/workflows/shell.nix &&
		    ${ pkgs.coreutils }/bin/cp ${ ./workflows/flake.nix } .github/workflows/flake.nix &&
		    ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/flake.nix &&
		    ${ pkgs.git }/bin/git add .github/workflows/flake.nix &&
                    ${ pkgs.coreutils }/bin/mkdir .github/workflows/check &&
                    ${ pkgs.gnused }/bin/sed \
                      -e "s#^    implementation-base ,\$#    implementation-base ? \"${ dollar "IMPLEMENTATION" }\" ,#" \
                      -e "s#    test-base ,#    test-base ? \"${ dollar "TEST" }\" ,#" \
                      -e "s#    tester-base ,#    tester-base ? \"${ dollar "TESTER" }\" ,#" \
                      -e "w.github/workflows/check/shell.nix" \
                      ${ ./workflows/check/shell.nix } &&
                    ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/check/shell.nix &&
                    ${ pkgs.git }/bin/git add .github/workflows/check/shell.nix &&
                    ${ pkgs.coreutils }/bin/cat ${ ./workflows/check/flake.nix } > .github/workflows/check/flake.nix &&
                    ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/check/flake.nix &&
                    ${ pkgs.git }/bin/git add .github/workflows/check/flake.nix &&
                    ${ pkgs.git }/bin/git commit --allow-empty-message --message ""
                  ''
              )
              (
                pkgs.writeShellScriptBin
                  "write-init-tester"
                  ''
		    ${ pkgs.git }/bin/git checkout -b init/$( ${ util-linux }/bin/uuidgen ) &&
                    ${ pkgs.git }/bin/git commit --allow-empty --allow-empty-message --all --message "" &&
                    ${ pkgs.git }/bin/git fetch origin main &&
                    ${ pkgs.git }/bin/git rebase origin/main &&             
                    IMPLEMENTATION=${ dollar 1 } &&
                    TEST=${ dollar 2 } &&
                    TESTER=${ dollar 3 } &&
                    if ${ pkgs.git }/bin/git rm -r .github
                    then
                      ${ pkgs.coreutils }/bin/rm --recursive --force .github
                    else
                      ${ pkgs.coreutils }/bin/rm --recursive --force .github
                    fi &&
                    ${ pkgs.coreutils }/bin/mkdir .github &&
                    ${ pkgs.coreutils }/bin/mkdir .github/workflows &&
                    ${ pkgs.yq }/bin/yq -n --yaml-output '${ builtins.toJSON init.tester }' | ${ sed } .github/workflows/test.yaml &&
                    ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/test.yaml &&
                    ${ pkgs.git }/bin/git add .github/workflows/test.yaml &&
                    ${ pkgs.coreutils }/bin/mkdir .github/workflows/check &&
                    ${ pkgs.gnused }/bin/sed \
                      -e "s#^    implementation-base ,\$#    implementation-base ? \"${ dollar "IMPLEMENTATION" }\" ,#" \
                      -e "s#^    test-base ,\$#    test-base ? \"${ dollar "TEST" }\" ,#" \
                      -e "s#^    tester-base ,\$#    tester-base ? \"${ dollar "TESTER" }\" ,#" \
                      -e "w.github/workflows/check/shell.nix" \
                      ${ ./workflows/check/shell.nix } &&
                    ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/check/shell.nix &&
                    ${ pkgs.git }/bin/git add .github/workflows/check/shell.nix &&
                    ${ pkgs.coreutils }/bin/cat ${ ./workflows/check/flake.nix } > .github/workflows/check/flake.nix &&
                    ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/check/flake.nix &&
                    ${ pkgs.git }/bin/git add .github/workflows/check/flake.nix &&
                    ${ pkgs.git }/bin/git commit --allow-empty-message --message ""
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
          ${ pkgs.coreutils }/bin/echo STRUCTURE FLAKE DEVELOPMENT ENVIRONMENT
        '' ;
    }
