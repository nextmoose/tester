  {
    inputs =
      {
        flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
	nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
      } ;
    outputs =
      { flake-utils , nixpkgs , self } :
        flake-utils.lib.eachDefaultSystem
          (
	    system :
	      let
	        pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
		in
		  {
		    devShell =
		      pkgs.mkShell
		        {
			  buildInputs =
			    [
			      (
			        pkgs.writeShellScriptBin
				  "branch"
				  ''
				    ${ pkgs.git }/bin/git --show-current &&
				    TARGET="${CURRENT_BRANCH}" &&
				    if [[ "$( ${ pkgs.git }/bin/git branch --show-current )" =! "${ builtins.concatStringsSep "" [ "$" "${" "TARGET" }" ]]
				    then
				      ${ pkgs.coreutils }/bin/echo The BRANCH is OK
				    else
				      ${ pkgs.coreutils }/bin/echo The BRANCH is NOT OK &&
				      exit 64
				    fi
				  ''
			      )
			    ] ;
			}
		  }
	  ) ;