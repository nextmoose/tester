 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { }
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
                    "post-check"
                    ''
		      ${ pkgs.gh }/bin/gh
                    ''
                )
              ] ;
      }
