 {
    pkgs ? import ( fetchTarball "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz" ) { } ,
    token 
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
		      ${ pkgs.coreutils }/bin/cat .github/workflows/test.yaml | ${ pkgs.yq }/bin/yq --yaml-output '. + ( { jobs : ( .jobs + ( { branch : ( .jobs.branch + ( { steps : [ ] } ) ) } ) ) } )' &&
		      ${ pkgs.gh }/bin/gh auth logout --hostname github.com
                    ''
                )
              ] ;
      }
