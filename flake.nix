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
                          lambda =
                            track :
                              let
                                tester =
                                  observer : success : value :
                                  let
                                    expected = { success = success ; value = value ; } ;
                                    observed = builtins.tryEval ( observer implementation ) ;
                                    to-string =
                                      let
                                        int = track : builtins.concatStrings "" [ "[" ( builtins.toString track.reduced ) "]" ] ;
                                        list = track : builtins.concatStrings "," track.reduced ;
                                        string = track : builtins.concatStrings "" [ "{" track.reduced "}" ] ;
                                        undefined = track : builtins.throw "b6e1f9d2-4aee-45c1-83a8-cefd78d3f04b" ;
                                        in _utils.visit { int = int ; list = list ; string = string ; undefined = undefined ; } ;
                                    in if observed == expected then "" else to-string track.path ;
                                in track.reduced tester ;
                          list = track : builtins.concatStringsSep "," track.reduced ;
                          set = track : builtins.concatStringsSep "," ( builtins.attrValues track.reduced ) ;
                          undefined = track : builtins.throw ( builtins.concatStringsSep "-" [ "3010bf32-3404-493e-8951-b2dc423ceaa4" track.type ] ) ;
                          in _utils.visit { lambda = lambda ; list = list ; set = set ; undefined = undefined ; } test ;
		  }
	  ) ;
  }
