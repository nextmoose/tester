 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { } ,
    token ,
    committer-user ,
    committer-email
  } :
    pkgs.mkShell
      {
        buildInputs =
	  let
            dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
	    in
              [
                (
                  pkgs.writeShellScriptBin
                    "test-init-main"
                    ''
		      ${ pkgs.coreutils }/bin/echo ${ token } | ${ pkgs.gh }/bin/gh auth login --with-token &&
		      ${ pkgs.git }/bin/git fetch origin main &&
		      COMMIT_ID=$( ${ pkgs.git }/bin/git log origin/main..$( ${ pkgs.git }/bin/git branch --show-current ) --pretty=format:%H | ${ pkgs.coreutils }/bin/tail --lines 1 ) &&
		      ${ pkgs.coreutils }/bin/echo "COMMIT_ID=${ dollar "COMMIT_ID" }" &&
		      ${ pkgs.git }/bin/git checkout -b head/$( ${ pkgs.util-linux }/bin/uuidgen ) &&
		      ${ pkgs.git }/bin/git fetch origin main &&
		      ${ pkgs.git }/bin/git reset --soft origin/main &&
		      ${ pkgs.git }/bin/git config user.name "${ committer-user }" &&
		      ${ pkgs.git }/bin/git config user.email ${ committer-email" } &&
		      ${ pkgs.git }/bin/git commit --all --reuse-message ${ dollar "COMMIT_ID" } &&
		      ${ pkgs.gh }/bin/gh pr create --base main --title "INIT" &&
		      ${ pkgs.gh }/bin/gh pr merge &&
		      ${ pkgs.gh }/bin/gh auth logout --hostname github.com
                    ''
                )
              ] ;
      }
