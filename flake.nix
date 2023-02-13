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
			  _implementation =
			    if builtins.typeOf implementation == "set" && builtins.hasAttr "lib" implementation && builtins.hasAttr system implementation.lib then builtins.getAttr system implementation.lib
			    else builtins.throw "171cb779-5e01-40da-b52a-0cd26fc1975e" ;
			  _test =
			    if builtins.typeOf test == "set" && builtins.hasAttr "lib" test && builtins.hasAttr system test.lib then builtins.getAttr system test.lib
			    else builtins.throw "08e93433-5518-45d7-9815-499f37b15654" ;
			  _utils = builtins.getAttr system utils.lib ;
			  check =
			    let
			      lambda =
			        track :
				  let
				    test = observer : success : value :
				      let
				        expected = { success = success ; value = value ; } ;
					observed = builtins.tryEval ( observer _implementation ) ;
					in observed == expected ;
				    in track.reduced test ;
			       list = track : builtins.all ( x : x ) track.reduced ;
			       set = track : builtins.all ( x : x ) ( builtins.attrValues track.reduced ) ;
			       undefined = track : builtins.throw "7f74b417-f07a-4d6a-8257-fdeb47ee89ae" ;
			       in _utils.visit { lambda = lambda ; list = list ; set = set ; undefined = undefined ; } _test ;
			  devShell = { devShell = pkgs.mkShell { buildInputs = [ ( pkgs.writeShellScriptBin "check" "" ) ] ; } ; } ;
			  error = builtins.throw "21ad4f91-60d5-4603-a721-2b0037abc004" ;
			  in if check then devShell else error ;
		  }
	  ) ;
  }