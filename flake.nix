  {
    inputs =
      {
        flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
        nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
        utils.url = "github:nextmoose/utils" ;
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
                                        result =
                                          let
                                            lambda =
                                              track :
                                                let
                                                  tester =
                                                    observer : success : value :
                                                      if builtins.tryEval ( observer ( builtins.getAttr system implementation.lib ) ) == { success = success ; value = value ; } then ""
                                                      else builtins.concatStringsSep "/" ( builtins.map builtins.toString track.path ) ;
                                                  in track.reduced tester ;
                                            list = track : builtins.concatStringsSep "" track.reduced ;
                                            set = track : builtins.concatStringsSep "" ( builtins.attrValues track.reduced ) ;
                                            undefined = track : builtins.toString track.reduced ;
                                            in _utils.visit { lambda = lambda ; list = list ; set = set ; undefined = undefined ; } ( builtins.getAttr system test.lib ) ;
                                        in
                                          pkgs.writeShellScriptBin
                                            "check"
                                            ''
                                              if [ "${ result }" == "${ _utils.bash-variable "1" }" ]
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