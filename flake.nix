  {
    inputs =
      {
        flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
	nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
	utils.url = "/home/emory/projects/MGWfXwul"
      } ;
    outputs =
      { self , flake-utils , nixpkgs , utils } :
        flake-utils.lib.eachDefaultSystem
          (
            system :
              let
                pkgs = builtins.getAttr system nixpkgs.legacyPackages	 ;
                in
                    {
                      devShell =
                        pkgs.mkShell
                          {
                            buildInputs =
			      let
			        implementation =
				  {
				    base = "" ;
				    repository = _utils.bash-variable "GITHUB_REPOSITORY" ;
				    change = _utils.bash-variable "GITHUB_REF_NAME" ;
				  } ;
				_utils = builtins.getAttr system utils.lib ;
			        in
                                  [
				    (
				      pkgs.writeShellScriptBin
				        "pre-check"
					''
					''
				    )
                                    (
                                      pkgs.writeShellScriptBin
                                        "check"
                                        ''
					  ${ pkgs.coreutils }/bin/echo UNIMPLEMENTED CHECK 2
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
