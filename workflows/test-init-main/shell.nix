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
	    sed = import ./sed.nix pkgs dollar ;
	    expression =
	      let
	        expression =
		  {
		    "61232b8e-1df9-4f7e-8ec5-538cb9b21aaa" =
		      {
		        push = "e7d90318-28cf-4b6f-81de-cd975c20bc03" ;
		      } ;
		    steps =
		      {
		        
		      }
		  } ;
	        in ". + ( ${ builtins.toJSON expression } )";
	    in
              [
                (
                  pkgs.writeShellScriptBin
                    "test-init-main"
                    ''
		      ${ pkgs.coreutils }/bin/echo ${ token } | ${ pkgs.gh }/bin/gh auth logout --hostname github.com &&
		      ${ pkgs.git }/bin/git config user.name "${ committer-email }" &&
		      ${ pkgs.git }/bin/git config user.email "${ committer-email }" &&
		      TEMP=$( ${ pkgs.mktemp }/bin/mktemp ) &&
		      ${ pkgs.coreutils }/bin/cat .github/workflows/test.yaml | ${ pkgs.jq }/bin/jq 'expression' | ${ sed } ${ dollar "TEMP" } &&
		      ${ pkgs.coreutils }/bin/cat ${ dollar "TEMP" } > .github/workflows/test.yaml &&
		      ${ pkgs.coreutils }/bin/rm ${ dollar "TEMP" } &&
		      ${ pkgs.git }/bin/git commit --all --reuse-message ${ dollar "COMMIT_ID" } &&
		      ${ pkgs.gh }/bin/gh pr create --base main --title "INIT" &&
		      ${ pkgs.gh }/bin/gh pr merge &&
		      ${ pkgs.gh }/bin/gh auth logout --hostname github.com
                    ''
                )
              ] ;
      }
