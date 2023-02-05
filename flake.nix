  {
    inputs =
      {
        flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
        nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
        utils.url = "github:nextmoose/utils?rev=3e5a503a5a639aa6e67e8716c2a4c5dbcd1df60a" ;
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
                        {
                          devShell =
                            pkgs.mkShell
                              {
                                buildInputs =
                                  [
                                    (
                                      let
				        _test = builtins.getAttr system test.lib ;
                                        path-to-string =
                                          let
                                            int = track : builtins.concatStringsSep "" [ "[" ( builtins.toString track.reduced ) "]" ] ;
                                            list = track : builtins.concatStringsSep "" track.reduced ;
                                            string = track : builtins.concatStringsSep "" [ "{" track.reduced "}" ] ;
                                            undefined = track : builtins.throw "4cecdf24-d6ba-4866-abbb-c9bc7984739b" ;
                                            in _utils.visit { int = int ; list = list ; string = string ; undefined = undefined ; } ;
                                        result =
                                          let
                                            lambda =
                                              track :
                                                let
                                                  tester =
                                                    observer : success : value :
                                                      let
						        expected = { success = success ; value = value ; } ;
                                                        equals = observed == expected ;
							observed = builtins.tryEval ( observer ( builtins.getAttr system implementation.lib ) ) ;
                                                        in
                                                          if equals then ""
                                                          else path-to-string track.path ;
                                                  in track.reduced tester ;
                                            list = track : builtins.concatStringsSep "" track.reduced ;
                                            set = track : builtins.concatStringsSep "" ( builtins.attrValues track.reduced ) ;
                                            undefined = track : builtins.toString track.reduced ;
                                            in _utils.visit { lambda = lambda ; list = list ; set = set ; undefined = undefined ; } ( builtins.trace ( builtins.typeOf _test ) ( _test utils ) ) ;
                                        in
                                          pkgs.writeShellScriptBin
                                            "check"
                                            ''
                                              if [ "${ builtins.trace ( builtins.typeOf result ) result }" == "${ _utils.bash-variable "1" }" ]
                                              then
                                                ${ pkgs.coreutils }/bin/echo PASSED &&
                                                exit 0
                                              else
                                                ${ pkgs.coreutils }/bin/echo FAILED &&
                                                ${ pkgs.coreutils }/bin/echo FAILURE=${ result }= &&
                                                exit 64
                                              fi
                                            ''
                                    )
                                  ] ;
                              } ;
                        } ;
                  }
          ) ;
  }