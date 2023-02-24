 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { } ,
    branch
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
		      TARGET="${ TARGET }" &&
		      ${ pkgs.git }/bin/git rev-parse HEAD &&
		      if [[ "$( ${ pkgs.git }/bin/git rev-parse HEAD )" =~ "${ dollar "TARGET" }" ]]
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
