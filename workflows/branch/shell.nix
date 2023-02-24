 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { } ,
    target ? "main"
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
                    "branch"
                    ''
		      TARGET="${ target }" &&
		      ${ pkgs.git }/bin/git branch --show-current &&
		      if [[ "$( ${ pkgs.git }/bin/git branch --show-current )" =~ "${ dollar "TARGET" }" ]]
		      then
		        ${ pkgs.coreutils }/bin/echo GOOD
		      else
		        ${ pkgs.coreutils }/bin/echo BAD &&
			exit 64
		      fi
                    ''
                )
              ] ;
      }
