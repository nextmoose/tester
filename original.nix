  {
    inputs =
      {
        flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
	implementation.url = "${IMPLEMENTATION}" ;
	nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
	test.url = "${TEST}" ;
	tester.url = "${TESTER}" ;
      } ;
    outputs =
      { flake-utils , implementation , nixpkgs , self , test , tester } :
        flake-utils.lib.eachDefaultSystem
	  (
	    system :
	      let
	        pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
		# in { devShell = pkgs.mkShell { buildInputs = [ ( pkgs.writeShellScriptBin "check" "${ pkgs.coreutils }/bin/echo FOUND" ) ] ; } ; }
		in builtins.getAttr system tester.lib implementation test
	  ) ;
  }