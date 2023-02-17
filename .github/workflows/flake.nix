  {
    inputs =
      {
        flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
	nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
      } ;
    outputs =
      { flake-utils , nixpkgs } :
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
			  buildInput =
			    [
			      (
			        pkgs.writeShellScriptBin
				  "versions"
				  ''
				    if [ -f flake.lock ]
				    then
				      ! ${ pkgs.coreutils }/bin/cat flake.lock | ${ pkgs.jq }/bin/jq --raw-output '.root as $root | .nodes | to_entries | map ( select ( .key != $root ) ) | map ( { key : .key , value : .value.original } ) | map ( { value : .key , success : ( .value.type == "github" and ( .value | has ( "owner" ) ) and ( .value | has ( "repo" ) ) and ( .value | has ( "rev" ) ) ) } ) | map ( select ( .success == false ) ) | map ( .value ) | join(",")';
				    fi
				  ''
			      )
			    ] ;
			} ;
		  }
	  ) ;
  }