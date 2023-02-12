  {
    inputs =
      {
        flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
	nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
	utils.url = "github:nextmoose/utils?rev=062f4376b4e7f55976e754f5ddad767a9a3a365d" ;
      } ;
    outputs =
      { flake-utils , nixpkgs , self , utils } :
        flake-utils.lib.eachDefaultSystem
	  (
	    system :
	      let
		_utils = builtins.getAttr system utils.lib ;
	        pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
		in
		  {
		    lib =
		      implementation : test :
		        let
			  result =
			    let
			      lambda =
			        track :
				  let
				    visitor =
				      observer-function : success : value :
				        let
					  expected = { success = success ; value = value ; } ;
					  observed = builtins.tryEval ( observer-function implementation ) ;
					  in observed == expected ;
				    in track.reduced visitor ; 
			      set = track : builtins.trace ( builtins.concatStringsSep "," ( builtins.attrValues ( builtins.mapAttrs ( name : value : "${ name } = ${ if value then "TRUE" else "FALSE" }" ) track.reduced ) ) ) ( builtins.all ( x : x ) ( builtins.attrValues track.reduced ) ) ;
			      undefined = track : builtins.throw "462820e2-311d-4ef4-a6c7-1a5d875579d2" ;
			      in _utils.visit { lambda = lambda ; set = set ; undefined = undefined ; } ( builtins.getAttr system test.lib ) ;
			  in if result then pkgs.mkShell { buildInputs = [ ( pkgs.mkShellScriptBin "check" "" ) ] ; } else builtins.throw "c7f9523b-d16d-4f79-a893-579d13eba0a2" ;
		  }
	  ) ;
  }