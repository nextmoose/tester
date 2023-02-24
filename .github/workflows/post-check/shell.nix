 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { } ,
    url ,
    name
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
		      ${ pkgs.coreutils }/bin/echo ${ dollar "TOKEN" } | ${ pkgs.gh }/bin/gh auth login --with-token &&
		      ${ pkgs.gh }/bin/gh repo clone ${ repository } &&
		      ${ pkgs.findutils }/bin/find . &&
		      ${ pkgs.gh }/bin/gh auth logout
                    ''
                )
              ] ;
      }
