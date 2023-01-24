  {
    inputs = { flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" , nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" } ;
    outputs =
      { self , flake-utils , nixpkgs } :
        flake-utils.lib.eachDefaultSystem
          (
            system :
              let
                pkgs = builtins.getAttr system nixpkgs.lib ;
                in
                    {
                      devShell =
                        pkgs.mkShell
                          {
                            buildInputs =
			      let
			        _utils = builtins.getAttr lib utils.lib ;
			        in
                                  [
                                    (
                                      pkgs.writeShellScriptBin
                                        "check"
                                        ''
					  ${ pkgs.coreutils }/bin/echo UNIMPLEMENTED CHECK
                                        ''
                                    )
                                    (
                                      pkgs.writeShellScriptBin
				        "update"
				        ''
				          ${ pkgs.coreutils }/bin/echo UNIMPLEMENTED UPDATE
				        ''
                                    )
                                  ] ;
                          } ;
                    }      
          ) ;
  }
