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
                                                    uuid : observer : success : value :
                                                      if builtins.tryEval ( observer ( builtins.getAttr system implementation.lib ) ) == { success = success ; value = value ; } then ""
                                                      else builtins.trace ( ( builtins.tryEval ( observer ( builtins.getAttr system implementation.lib ) ) ).value ) ( builtins.toString uuid ) ;
                                                  in track.reduced tester ;
                                            list = track : builtins.concatStringsSep "" track.reduced ;
                                            set = track : builtins.concatStringsSep "" ( builtins.attrValues track.reduced ) ;
                                            undefined = track : builtins.throw "60574bba-c6ea-40c5-8510-2f9ae6ae1130" ;
                                            in _utils.visit { lambda = lambda ; list = list ; set = set ; undefined = undefined ; } ( builtins.getAttr system test.lib ) ;
                                        in
                                          pkgs.writeShellScriptBin
                                            "check"
                                            ''
                                              if [ ${ _utils.bash-variable "1" } == "precheck" ] && [ _utils.bash-variable "#" == 1 ] && [[ ${ _utils.bash-variable "GITHUB_REF_NAME" } =~ ^scratch/.*$ ]]
                                              then
                                                ${ pkgs.coreutils }/bin/echo PRECHECK HAPPY / SAD
                                              else if [ ${ _utils.bash-variable "1" } == "precheck" ] && [ _utils.bash-variable "#" == 2 ] && [[ ${ _utils.bash-variable "GITHUB_REF_NAME" } =~ ^implementation/.*$ ]]
                                              then
                                                ${ pkgs.coreutils }/bin/echo PRECHECK INTEGRATION
                                              else if [ ${ _utils.bash-variable "1" } == "check" ] && [ _utils.bash-variable "#" == 1 ] && [[ ${ _utils.bash-variable "GITHUB_REF_NAME" } =~ ^scratch/.*$ ]]
                                              then
                                                ${ pkgs.coreutils }/bin/echo CHECK HAPPY
                                              else if [ ${ _utils.bash-variable "1" } == "check" ] && [ _utils.bash-variable "#" == 2 ] && [[ ${ _utils.bash-variable "GITHUB_REF_NAME" } =~ ^implementation/.*$ ]]
                                              then
                                                ${ pkgs.coreutils }/bin/echo CHECK INTEGRATION
                                              fi &&
                                              if [ "${ result }" == "${ _utils.bash-variable "2" }" ]
                                              then
                                                exit 0
                                              else
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