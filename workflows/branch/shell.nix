 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { } ,
    expected ? "^main\$"
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
		      OBSERVED=$( ${ pkgs.git }/bin/git branch --show-current ) &&
		      EXPECTED="${ expected }" &&
		      ${ pkgs.coreutils }/bin/echo OBSERVED=${ dollar "OBSERVED" } &&
		      ${ pkgs.coreutils }/bin/echo EXPECTED=${ dollar "EXPECTED" } &&
		      if [[ ${ dollar "OBSERVED" } =~ ${ dollar "EXPECTED" } ]]
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
