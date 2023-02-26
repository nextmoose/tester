{ pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) {} , token } :
  pkgs.mkShell
    {
      buildInputs =
        let
	  sleep = "150s" ;
	  auto-merge = true ;
	  constants =
	    {
	      on = "6ef4ab1f-e39a-4184-a7b1-03ef39c05786" ;
	      push = "7f685616-ce05-4275-8630-a9bcc8d7cd09" ;
	      _with = "921d70d5-1dbe-4427-99dd-e4138d4b17fe" ;
	      jobs = "93e9beb9-c316-4c18-bcf7-b9e42a573b9f" ;
	      check = "0898c9f0-741d-4702-bf35-464e239e3320" ;
	    } ;
          dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
	  execute-init-tester =
	    pkgs.writeShellScriptBin
	      "execute-init-tester"
	      ''
                  IMPLEMENTATION=${ dollar 1 } &&
                  TEST=${ dollar 2 } &&
                  TESTER=${ dollar 3 } &&
		  LOCAL_IMPLEMENTATION=${ dollar 4 } &&
		  LOCAL_TEST=${ dollar 5 } &&
		  LOCAL_TESTER=${ dollar "LOCAL_IMPLEMENTATION" } &&
		  ${ pkgs.coreutils }/bin/echo TEST PHASE 1 &&
		  cd ${ dollar "LOCAL_TEST" } &&
		  ${ pkgs.coreutils }/bin/echo ${ token } | ${ pkgs.gh }/bin/gh auth login --with-token &&
		  ${ write-init-test }/bin/write-init-test ${ dollar "IMPLEMENTATION" } ${ dollar "TEST" } ${ dollar "TESTER" } &&
		  ${ pkgs.git }/bin/git checkout -b scratch/$( ${ pkgs.util-linux }/bin/uuidgen ) &&
		  ${ pkgs.git }/bin/git fetch origin main &&
		  ${ pkgs.git }/bin/git reset --soft origin/main &&
		  ${ pkgs.git }/bin/git commit --allow-empty --message "Initializing test" &&
		  ${ pkgs.git }/bin/git push origin HEAD &&
		  ${ pkgs.gh }/bin/gh pr create --base main --fill &&
		  ${ if auto-merge then "${ pkgs.gh }/bin/gh pr merge --auto --rebase --delete-branch" else "${ pkgs.coreutils }/bin/echo auto-merge is false" } &&
		  # ${ pkgs.gh }/bin/gh pr status &&
		  ${ pkgs.coreutils }/bin/sleep ${ sleep } &&
		  # ${ pkgs.gh }/bin/gh pr status &&
		  ${ pkgs.coreutils }/bin/echo  Y | ${ pkgs.gh }/bin/gh auth logout --hostname github.com &&
		  ${ pkgs.coreutils }/bin/echo IMPLEMENTATION PHASE 1 &&
		  cd ${ dollar "LOCAL_IMPLEMENTATION" } &&
		  ${ pkgs.coreutils }/bin/echo ${ token } | ${ pkgs.gh }/bin/gh auth login --with-token &&
		  ${ write-init-tester }/bin/write-init-tester ${ dollar "IMPLEMENTATION" } ${ dollar "TEST" } ${ dollar "TESTER" } &&
		  ${ pkgs.git }/bin/git checkout -b scratch/$( ${ pkgs.util-linux }/bin/uuidgen ) &&
		  ${ pkgs.git }/bin/git fetch origin main &&
		  ${ pkgs.git }/bin/git reset --soft origin/main &&
		  ${ pkgs.git }/bin/git commit --allow-empty --message "Initializing implementation which happens to also be tester" &&
		  ${ pkgs.git }/bin/git push origin HEAD &&
		  ${ pkgs.gh }/bin/gh pr create --base main --fill &&
		  ${ if auto-merge then "${ pkgs.gh }/bin/gh pr merge --auto --rebase --delete-branch" else "${ pkgs.coreutils }/bin/echo auto-merge is false" } &&
		  # ${ pkgs.gh }/bin/gh pr status &&
		  ${ pkgs.coreutils }/bin/sleep ${ sleep } &&
		  # ${ pkgs.gh }/bin/gh pr status &&
		  ${ pkgs.coreutils }/bin/echo Y | ${ pkgs.gh }/bin/gh auth logout --hostname github.com &&
		  ${ pkgs.coreutils }/bin/echo TEST PHASE 2 &&
		  cd ${ dollar "LOCAL_TEST" } &&
		  ${ pkgs.coreutils }/bin/echo ${ token } | ${ pkgs.gh }/bin/gh auth login --with-token &&
		  ${ write-happy-test }/bin/write-happy-test &&
		  ${ pkgs.git }/bin/git checkout -b scratch/$( ${ pkgs.util-linux }/bin/uuidgen ) &&
		  ${ pkgs.git }/bin/git fetch origin main &&
		  ${ pkgs.git }/bin/git reset --soft origin/main &&
		  ${ pkgs.git }/bin/git commit --allow-empty --message "Re-establishing test" &&
		  ${ pkgs.git }/bin/git push origin HEAD &&
		  ${ pkgs.gh }/bin/gh pr create --base main --fill &&
		  ${ if auto-merge then "${ pkgs.gh }/bin/gh pr merge --auto --rebase --delete-branch" else "${ pkgs.coreutils }/bin/echo auto-merge is false" } &&
		  # ${ pkgs.gh }/bin/gh pr status &&
		  ${ pkgs.coreutils }/bin/sleep ${ sleep } &&
		  # ${ pkgs.gh }/bin/gh pr status &&
		  ${ pkgs.coreutils }/bin/echo  Y | ${ pkgs.gh }/bin/gh auth logout --hostname github.com &&
		  ${ pkgs.coreutils }/bin/echo IMPLEMENTATION PHASE 2 &&
		  cd ${ dollar "LOCAL_IMPLEMENTATION" } &&
		  ${ pkgs.coreutils }/bin/echo ${ token } | ${ pkgs.gh }/bin/gh auth login --with-token &&
		  ${ write-happy-tester }/bin/write-happy-tester &&
		  ${ pkgs.git }/bin/git checkout -b scratch/$( ${ pkgs.util-linux }/bin/uuidgen ) &&
		  ${ pkgs.git }/bin/git fetch origin main &&
		  ${ pkgs.git }/bin/git reset --soft origin/main &&
		  ${ pkgs.git }/bin/git commit --allow-empty --message "Reestablishing implementation which happens to also be tester" &&
		  ${ pkgs.git }/bin/git push origin HEAD &&
		  ${ pkgs.gh }/bin/gh pr create --base main --fill &&
		  ${ if auto-merge then "${ pkgs.gh }/bin/gh pr merge --auto --rebase --delete-branch" else "${ pkgs.coreutils }/bin/echo auto-merge is false" } &&
		  # ${ pkgs.gh }/bin/gh pr status &&
		  ${ pkgs.coreutils }/bin/sleep ${ sleep } &&
		  # ${ pkgs.gh }/bin/gh pr status &&
		  ${ pkgs.coreutils }/bin/echo  Y | ${ pkgs.gh }/bin/gh auth logout --hostname github.com
	      '' ;
          jq =
            {
	      happy =
	        {
		  test = ''del(.true) + { "${ constants.on }" : { push : "${ constants.push }" } , jobs : ( .jobs + { "pre-check" : [ { uses : "cachix/install-nix-action@v17" , with : { extra_nix_config : "access-tokens = github.com = ${ dollar "{ secrets.TOKEN }" }" } } , { run : "nix-shell .github/workflows/check/shell.nix --command check" } ] , check :  [ { uses : "cachix/install-nix-action@v17" , with : { extra_nix_config : "access-tokens = github.com = ${ dollar "{ secrets.TOKEN "}" } } , { run : "nix-shell .github/workflows/check/shell.nix --arg test-home true --command check" } ] } ) }'' ;
		  tester = ''del(.true) + { "${ constants.on }" : { push : "${ constants.push }" } , jobs : ( .jobs + { "pre-check" : [ { uses : "cachix/install-nix-action@v17" , with : { extra_nix_config : "access-tokens = github.com = ${ dollar "{ secrets.TOKEN }" }" } } , { run : "nix-shell .github/workflows/check/shell.nix --command check" } ] , check :  [ { uses : "cachix/install-nix-action@v17" , with : { extra_nix_config : "access-tokens = github.com = ${ dollar "{ secrets.TOKEN }" }" } } , { run : "nix-shell .github/workflows/check/shell.nix --arg implementation-home true --arg tester-home true --command check" } ] } ) }'' ;
		} ;
              init =
                {
                  test =
                    {
                      name = "test" ;
                      "${ constants.on }" =
                        {
                          push = constants.push ;
                        } ;
                      jobs =
                        {
                          check = { runs-on = "ubuntu-latest" ; steps = [ { run = true ; } ] ; } ;
                        } ;
                    } ;
                  tester =
                    {
                      name = "test" ;
                      "${ constants.on }" =
                        {
                          push = constants.push ;
                        } ;
                      jobs =
                        {
                          check =
                            {
                              runs-on = "ubuntu-latest" ;
                              steps =
                                [
                                  { uses = "actions/checkout@v3" ; }
                                  { uses = "cachix/install-nix-action@v17" ; "${ constants._with }" = { extra_nix_config = "access-tokens = github.com = ${ dollar "{ secrets.TOKEN }" }" ; } ; }
                                  { run = "nix-shell .github/workflows/check/shell.nix --arg implementation-home true --arg tester-home true --command check" ; }
                                ] ;
                            } ;
                        } ;
                    } ;
                  init-to-main =
                    {
                      test =
                        {
                          
                        } ;
                    } ;
                } ;
            } ;
            sed =
	      pkgs.writeShellScript
                "sed"
                ''
                  ${ pkgs.gnused }/bin/sed \
                  -e "s#${ constants.on }#on#" \
                  -e "s#${ constants.push }##" \
                  -e "s#${ constants._with }#with#" \
                  -e "w${ dollar "1" }"
                 '' ;
	    write-happy-test =
	      pkgs.writeShellScriptBin
	      "write-happy-test"
	      ''
	        TEMP=$( ${ pkgs.mktemp }/bin/mktemp ) &&
	        ${ pkgs.coreutils }/bin/cat .github/workflows/test.yaml | ${ pkgs.yq }/bin/yq --yaml-output '${ jq.happy.test }' | ${ sed } ${ dollar "TEMP" } &&
		${ pkgs.coreutils }/bin/chmod 0600 .github/workflows/test.yaml &&
		${ pkgs.coreutils }/bin/cat ${ dollar "TEMP" } > .github/workflows/test.yaml &&
		${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/test.yaml &&
		${ pkgs.coreutils }/bin/git add .github/workflows/test.yaml &&
		${ pkgs.coreutils }/bin/rm ${ dollar "TEMP" }
	      '' ;
	    write-happy-tester =
	      pkgs.writeShellScriptBin
	      "write-happy-tester"
	      ''
	        TEMP=$( ${ pkgs.mktemp }/bin/mktemp ) &&
	        ${ pkgs.coreutils }/bin/cat .github/workflows/test.yaml | ${ pkgs.yq }/bin/yq --yaml-output '${ jq.happy.tester }' | ${ sed } ${ dollar "TEMP" } &&
		${ pkgs.coreutils }/bin/chmod 0600 .github/workflows/test.yaml &&
		${ pkgs.coreutils }/bin/cat ${ dollar "TEMP" } > .github/workflows/test.yaml &&
		${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/test.yaml &&
		${ pkgs.coreutils }/bin/git add .github/workflows/test.yaml &&
		${ pkgs.coreutils }/bin/rm ${ dollar "TEMP" }
	      '' ;
            write-init-test =
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
                  ${ pkgs.yq }/bin/yq -n --yaml-output '${ builtins.toJSON jq.init.test }' | ${ sed } .github/workflows/test.yaml &&
                  ${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/test.yaml &&
                  ${ pkgs.git }/bin/git add .github/workflows/test.yaml &&
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
                  ${ pkgs.git }/bin/git commit --allow-empty --allow-empty-message --message ""
                '' ;
	    write-init-tester =
              pkgs.writeShellScriptBin
                "write-init-tester"
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
                  ${ pkgs.yq }/bin/yq -n --yaml-output '${ builtins.toJSON jq.init.tester }' | ${ sed } .github/workflows/test.yaml &&
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
                  ${ pkgs.git }/bin/git commit --allow-empty --allow-empty-message --message ""
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
		  "write-jq"
		  ''
		    TEMP=$( ${ pkgs.mktemp }/bin/mktemp ) &&
		    ${ pkgs.coreutils }/bin/echo &&
		    ${ pkgs.coreutils }/bin/cat .github/workflows/test.yaml &&
		    ${ pkgs.coreutils }/bin/echo &&
		    ${ pkgs.coreutils }/bin/echo '${ jq.happy.test }' &&
		    ${ pkgs.coreutils }/bin/echo &&
		    ${ pkgs.coreutils }/bin/cat .github/workflows/test.yaml | ${ pkgs.yq }/bin/yq --yaml-output '${ jq.happy.test }' | ${ sed } ${ dollar "TEMP" } &&
		    ${ pkgs.coreutils }/bin/rm ${ dollar "TEMP" }
		  ''
	      )
	      execute-init-tester
	      write-happy-test
	      write-happy-tester
              write-init-test
	      write-init-tester
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
