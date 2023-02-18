{ pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) {} , implementation , test } :
  pkgs.mkShell
    {
      buildInputs =
        let
          apply-commit = dollar "APPLY_COMMIT" ;
          argue-commit = dollar "ARGUE_COMMIT" ;
          apply-dir = dollar "1" ;
          argue-dir = dollar "2" ;
          bin-time = dollar "BIN_TIME" ;
          dollar = expression : builtins.concatStringsSep "" [ "$" "{" expression "}" ] ;
          shell-commit = dollar "SHELL_COMMIT" ;
          utils-commit = dollar "UTILS_COMMIT" ;
          utils-dir = dollar "3" ;
          work-dir = dollar "WORK_DIR" ;
          in
            let
              dollar = expression : builtins.concatStringsSep "" [ "$" "{" expression "}" ] ;
              in
                [
		  (
		    pkgs.writeShellScriptBin
		      "write-workflow-init"
		      ''
		        NAME=${ dollar "1" } &&
		        IMPLEMENTATION=${ dollar "2" } &&
			TEST=${ dollar "3" } &&
			TESTER=${ dollar "4" } &&
			TYPE=${ dollar "5" } &&
		        if [ -d .github ] && ! ${ pkgs.git }/bin/git rm -r .github
			then
			  ${ pkgs.coreutils }/bin/rm --recursive --force .github
			fi &&
			${ pkgs.coreutils }/bin/mkdir .github &&
			${ pkgs.coreutils }/bin/mkdir .github/workflows &&
			${ pkgs.coreutils }/bin/cp ${ ./workflows/versions.txt } .github/workflows/versions.txt &&
			${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/versions.txt &&
			${ pkgs.git }/bin/git add .github/workflows/versions.txt &&
			${ pkgs.coreutils }/bin/mkdir .github/workflows/pre-check &&
			${ pkgs.gnused }/bin/sed -e "s#\${ dollar "IMPLEMENTATION" }#${ dollar "IMPLEMENTATION" }#" -e "s#\${ dollar "TEST" }#${ dollar "TEST" }#" -e "s#\${ dollar "TESTER" }#${ dollar "TESTER" }#" -e "w.github/workflows/pre-check/flake.nix" ${ ./workflows/check.nix } &&
			${ pkgs.git }/bin/git add .github/workflows/pre-check/flake.nix &&
			${ pkgs.coreutils }/bin/mkdir .github/workflows/check &&
			if [ "${ dollar "TYPE" }" == "implementation" ]
			then
			  ${ pkgs.gnused }/bin/sed -e "s#\${ dollar "IMPLEMENTATION" }#/home/runner/work/${ dollar "NAME" }/${ dollar "NAME" }#" -e "s#\${ dollar "TEST" }#${ dollar "TEST" }#" -e "s#\${ dollar "TESTER" }#${ dollar "TESTER" }#" -e "w.github/workflows/check/flake.nix" ${ ./workflows/check.nix }
			elif [ "${ dollar "TYPE" }" == "test" ]
			then
			  ${ pkgs.gnused }/bin/sed -e "s#\${ dollar "IMPLEMENTATION" }#${ dollar "IMPLEMENTATION" }#" -e "s#\${ dollar "TEST" }#/home/runner/work/${ dollar "NAME" }/${ dollar "NAME" }#" -e "s#\${ dollar "TESTER" }#${ dollar "TESTER" }#" -e "w.github/workflows/check/flake.nix" ${ ./workflows/check.nix }
			elif [ "${ dollar "TYPE" }" == "tester" ]
			then
			  ${ pkgs.gnused }/bin/sed -e "s#\${ dollar "IMPLEMENTATION" }#\/home/runner/work/${ dollar "NAME" }/${ dollar "NAME" }#" -e "s#\${ dollar "TEST" }#${ dollar "TEST" }#" -e "s#\${ dollar "TESTER" }#/home/runner/work/${ dollar "NAME" }/${ dollar "NAME" }#" -e "w.github/workflows/check/flake.nix" ${ ./workflows/check.nix }
			else
			  ${ pkgs.coreutils }/bin/echo Unknown Type ${ dollar "TYPE" } &&
			  exit 64
			fi &&
			${ pkgs.git }/bin/git add .github/workflows/check/flake.nix &&
			${ pkgs.yq }/bin/yq -n --yaml-output '{ name : "test" , "f24675a1-d5e7-4dc6-b731-d1505a8bd447" : { push : "01758bd7-6632-4c2e-b23e-c092d2188838" } , jobs : { versions : { "runs-on" : "ubuntu-latest" , steps : [ { uses : "actions/checkout@v3" } ] } , "pre-check" : { "runs-on" : "ubuntu-latest" , steps : [ { run : true } ] } , check : { "runs-on" : "ubuntu-latest" , steps : [ { uses : "actions/checkout@v3" } , { uses : "cachix/install-nix-action@v17" , with : { extra_nix_configs : "access-tokens = github.com=${ dollar "{ secrets.token }" }" } } , { run : "cd .github/workflows/check && nix develop --command check"  } ] } } } ' | ${ pkgs.gnused }/bin/sed -e "s#f24675a1-d5e7-4dc6-b731-d1505a8bd447#on#" -e "s#01758bd7-6632-4c2e-b23e-c092d2188838##" > .github/workflows/test.yaml &&
			${ pkgs.coreutils }/bin/chmod 0400 .github/workflows/test.yaml &&
			${ pkgs.git }/bin/git add .github/workflows/test.yaml &&
			${ pkgs.git }/bin/git commit --allow-empty --allow-empty-message --message ""
		      ''
		  )
                  pkgs.chromium
                  pkgs.coreutils
                  pkgs.emacs
                  pkgs.gh
                  pkgs.github-runner
                  pkgs.inetutils
                  pkgs.jq
                  pkgs.mktemp
                  pkgs.yq
                  pkgs.cowsay
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
                  (
                    pkgs.writeShellScriptBin
                      "cleanup-tmp"
                      ''
                        ${ pkgs.findutils }/bin/find $( ${ pkgs.mktemp }/bin/mktemp --directory )/.. -maxdepth 3 -mmin +60 -exec ${ pkgs.coreutils }/bin/shred --force --remove {} \;
                      ''
                  )
                  (
                    pkgs.writeShellScriptBin
                      "commit"
                      ''
                        ${ pkgs.git }/bin/git -C ${ dollar "APPLY_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "ARGUE_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "BASH_VARIABLE_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "PERSONAL_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "SCRIPT_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "SHELL_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "STRIP_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "TRY_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "VISIT_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }" &&
                        ${ pkgs.git }/bin/git -C ${ dollar "UTILS_HOME" } commit --all --allow-empty --allow-empty-message --message "${ dollar "@" }"
                      ''
                  )
                  (
                    pkgs.writeShellScriptBin
                      "edit"
                      ''
                        ${ pkgs.emacs }/bin/emacs \
                          shell.nix \
                          ${ dollar "APPLY_HOME" }/flake.nix \
                          ${ dollar "ARGUE_HOME" }/flake.nix \
                          ${ dollar "BASH_VARIABLE_HOME" }/flake.nix \
                          ${ dollar "PERSONAL_HOME" }/flake.nix \
                          ${ dollar "SCRIPT_HOME" }/flake.nix \
                          ${ dollar "SHELL_HOME" }/flake.nix \
                          ${ dollar "STRIP_HOME" }/flake.nix \
                          ${ dollar "TRY_HOME" }/flake.nix \
                          ${ dollar "UTILS_HOME" }/flake.nix \
                          ${ dollar "VISIT_HOME" }/flake.nix \
                          &
                      ''
                  )
                  (
                    pkgs.writeShellScriptBin
                      "initiate"
                      ''
                        WORK_DIR=$( ${ pkgs.mktemp }/bin/mktemp --directory ) &&
                        function cleanup ( )
                        {
                          if [ ${ dollar "?" } -eq 0 ]
                            then
                              ${ pkgs.git }/bin/git -C ${ dollar "APPLY_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git -C ${ dollar "ARGUE_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git -C ${ dollar "BASH_VARIABLE_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git -C ${ dollar "PERSONAL_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git -C ${ dollar "SCRIPT_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git -C ${ dollar "SHELL_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git -C ${ dollar "TRY_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git -C ${ dollar "UTILS_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git -C ${ dollar "VISIT_HOME" } commit --all --allow-empty --message "TESTED" &&
                              ${ pkgs.git }/bin/git commit --all --allow-empty --message "TESTED"
                              ${ pkgs.coreutils }/bin/rm --recursive --force ${ work-dir }
                              ( ${ pkgs.coreutils }/bin/cat > bin/${ bin-time }.sh <<EOF
                                #!/bin/sh
                          
                                export ARGUE_COMMIT=${ dollar "ARGUE_COMMIT" } &&
                                export APPLY_COMMIT=${ dollar "APPLY_COMMIT" } &&
                                export BASH_VARIABLE_COMMIT=${ dollar "BASH_VARIABLE_COMMIT" } &&
                                export PERSONAL_COMMIT=${ dollar "PERSONAL_COMMIT" } &&
                                export SCRIPT_COMMIT=${ dollar "SCRIPT_COMMIT" } &&
                                export SHELL_COMMIT=${ dollar "SHELL_COMMIT" } &&
                                export TRY_COMMIT=${ dollar "TRY_COMMIT" } &&
                                export UTILS_COMMIT=${ dollar "UTILS_COMMIT" } &&
                                export VISIT_COMMIT=${ dollar "VISIT_COMMIT" } &&
                                
                                initiate
                        EOF
                              ) &&
                              ${ pkgs.coreutils }/bin/chmod 0500 bin/${ bin-time }.sh
                            else
                              ${ pkgs.coreutils }/bin/echo There was a problem with ${ work-dir } - ${ dollar "?" }
                            fi
                        } &&
                        trap cleanup EXIT &&
                        ${ pkgs.coreutils }/bin/echo APPLY &&
                        ${ pkgs.git }/bin/git -C ${ dollar "APPLY_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        APPLY_COMMIT=${ dollar "APPLY_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "APPLY_HOME" } rev-parse HEAD )" } &&
                        ${ pkgs.coreutils }/bin/echo ARUE &&
                        ${ pkgs.git }/bin/git -C ${ dollar "ARGUE_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        ARGUE_COMMIT=${ dollar "ARGUE_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "ARGUE_HOME" } rev-parse HEAD )" } &&
                        ${ pkgs.coreutils }/bin/echo BASH_VARIABLE &&
                        ${ pkgs.git }/bin/git -C ${ dollar "BASH_VARIABLE_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        BASH_VARIABLE_COMMIT=${ dollar "BASH_VARIABLE_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "BASH_VARIABLE_HOME" } rev-parse HEAD )" } &&
                        ${ pkgs.coreutils }/bin/echo PERSONAL &&
                        ${ pkgs.git }/bin/git -C ${ dollar "PERSONAL_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        PERSONAL_COMMIT=${ dollar "PERSONAL_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "PERSONAL_HOME" } rev-parse HEAD )" } &&
                        ${ pkgs.coreutils }/bin/echo SCRIPT &&
                        ${ pkgs.git }/bin/git -C ${ dollar "SCRIPT_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        SCRIPT_COMMIT=${ dollar "SCRIPT_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "SCRIPT_HOME" } rev-parse HEAD )" } &&
                        ${ pkgs.coreutils }/bin/echo SHELL &&
                        ${ pkgs.git }/bin/git -C ${ dollar "SHELL_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        SHELL_COMMIT=${ dollar "SHELL_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "SHELL_HOME" } rev-parse HEAD )" } &&
                        ${ pkgs.coreutils }/bin/echo STRIP &&
                        ${ pkgs.git }/bin/git -C ${ dollar "STRIP_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        STRIP_COMMIT=${ dollar "STRIP_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "STRIP_HOME" } rev-parse HEAD )" } &&
                        ${ pkgs.coreutils }/bin/echo TRY &&
                        ${ pkgs.git }/bin/git -C ${ dollar "TRY_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        TRY_COMMIT=${ dollar "TRY_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "TRY_HOME" } rev-parse HEAD )" } &&             
                        ${ pkgs.coreutils }/bin/echo UTILS &&
                        ${ pkgs.git }/bin/git -C ${ dollar "UTILS_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        UTILS_COMMIT=${ dollar "UTILS_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "UTILS_HOME" } rev-parse HEAD )" } &&
                        ${ pkgs.coreutils }/bin/echo VISIT &&
                        ${ pkgs.git }/bin/git -C ${ dollar "VISIT_HOME" } commit --all --allow-empty --allow-empty-message --message "" &&
                        VISIT_COMMIT=${ dollar "VISIT_COMMIT:=$( ${ pkgs.git }/bin/git -C ${ dollar "VISIT_HOME" } rev-parse HEAD )" } &&
                        BIN_TIME=$( ${ pkgs.coreutils }/bin/date +%Y-%m-%d-%H-%S ) &&
                        function checkout ( )
                        {
                          NAME=${ dollar "1" } &&
                          DIR=${ dollar "2" } &&
                          COMMIT=${ dollar "3" } &&
                          ${ pkgs.coreutils }/bin/mkdir ${ work-dir }/${ dollar "NAME" } &&
                          ${ pkgs.git }/bin/git -C ${ work-dir }/${ dollar "NAME" } init &&
                          ${ pkgs.git }/bin/git -C ${ work-dir }/${ dollar "NAME" } config user.name "No One" &&
                          ${ pkgs.git }/bin/git -C ${ work-dir }/${ dollar "NAME" } config user.email "no@one" &&
                          ${ pkgs.git }/bin/git -C ${ work-dir }/${ dollar "NAME" } remote add origin ${ dollar "DIR" } &&
                          ${ pkgs.git }/bin/git -C ${ work-dir }/${ dollar "NAME" } fetch origin ${ dollar "COMMIT" } &&
                          ${ pkgs.git }/bin/git -C ${ work-dir }/${ dollar "NAME" } checkout ${ dollar "COMMIT" } &&
                          ${ pkgs.gnused }/bin/sed \
                            -e "s#github:nextmoose/apply#${ work-dir }/apply#" \
                            -e "s#github:nextmoose/argue#${ work-dir }/argue#" \
                            -e "s#github:nextmoose/bash-variable#${ work-dir }/bash-variable#" \
                            -e "s#github:nextmoose/personal#${ work-dir }/personal#" \
                            -e "s#github:nextmoose/script#${ work-dir }/script#" \
                            -e "s#github:nextmoose/shell#${ work-dir }/shell#" \
                            -e "s#github:nextmoose/strip#${ work-dir }/strip#" \
                            -e "s#github:nextmoose/try#${ work-dir }/try#" \
                            -e "s#github:nextmoose/utils#${ work-dir }/utils#" \
                            -e "s#github:nextmoose/visit#${ work-dir }/visit#" \
                            -e "w${ work-dir }/${ dollar "NAME" }/flake.nix" \
                            ${ dollar "DIR" }/flake.nix
                        } &&
                        checkout argue ${ dollar "ARGUE_HOME" } ${ dollar "ARGUE_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout apply ${ dollar "APPLY_HOME" } ${ dollar "APPLY_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout bash-variable ${ dollar "BASH_VARIABLE_HOME" } ${ dollar "BASH_VARIABLE_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout personal ${ dollar "PERSONAL_HOME" } ${ dollar "PERSONAL_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout script ${ dollar "SCRIPT_HOME" } ${ dollar "SCRIPT_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout shell ${ dollar "SHELL_HOME" } ${ dollar "SHELL_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout strip ${ dollar "STRIP_HOME" } ${ dollar "STRIP_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout try ${ dollar "TRY_HOME" } ${ dollar "TRY_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout utils ${ dollar "UTILS_HOME" } ${ dollar "UTILS_COMMIT" } ${ dollar "WORK_DIR" } &&
                        checkout visit ${ dollar "VISIT_HOME" } ${ dollar "VISIT_COMMIT" } ${ dollar "WORK_DIR" } &&
                        # ${ pkgs.nix }/bin/nix flake --override-input nixpkgs github:NixOS/nixpkgs/57eac89459226f3ec743ffa6bbbc1042f5836843 &&
                        ${ pkgs.nix }/bin/nix develop --impure ${ work-dir }/personal
                      ''
                  )
                  (
                    pkgs.writeShellScriptBin
                      "push"
                      ''
                        push ( )
                        {
                          cd ${ builtins.concatStringsSep "" [ "$" "{" "1" "}" ] } &&
                          ${ pkgs.git }/bin/git commit --all --allow-empty --allow-empty-message --message "" &&
                          ${ pkgs.git }/bin/git push origin HEAD &&
                          ${ pkgs.git }/bin/git push origin main
                        } &&
                        push ${ builtins.concatStringsSep "" [ "$" "{" "APPLY_HOME" "}" ] } &&
                        push ${ builtins.concatStringsSep "" [ "$" "{" "ARGUE_HOME" "}" ] } &&
                        push ${ builtins.concatStringsSep "" [ "$" "{" "BASH_VARIABLE_HOME" "}" ] } &&
                        push ${ builtins.concatStringsSep "" [ "$" "{" "SHELL_HOME" "}" ] } &&
                        push ${ builtins.concatStringsSep "" [ "$" "{" "STRIP_HOME" "}" ] } &&
                        push ${ builtins.concatStringsSep "" [ "$" "{" "TRY_HOME" "}" ] } &&
                        push ${ builtins.concatStringsSep "" [ "$" "{" "UTILS_HOME" "}" ] } &&
                        push ${ builtins.concatStringsSep "" [ "$" "{" "VISIT_HOME" "}" ] }
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
          export IMPLEMENTATION=${ implementation } &&
          export TEST=${ test } &&
          ${ pkgs.coreutils }/bin/echo STRUCTURE FLAKE DEVELOPMENT ENVIRONMENT
        '' ;
    }
