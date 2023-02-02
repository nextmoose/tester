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
                                        equality =
                                          let
                                            visitors =
                                              let
                                                simple = observed : expected : { success = observed == expected ; value = "" ; } ;
                                                in
                                                  {
                                                    bool = simple ;
                                                    int = simple ;
                                                    lambda = observed : expected : { success = false ; value = "lambda" ; } ;
                                                    list =
                                                      observed : expected :
                                                        if builtins.length observed != builtins.length expected then { success = false ; value = "list length" ; }
                                                        else
                                                          let
                                                            eval =
                                                              let
                                                                mapper =
                                                                  index :
                                                                    let
                                                                      eval = equality ( builtins.elemAt observed index ) ( builtins.elemAt expected index ) ;
                                                                      in { success = eval.success ; value = builtins.concatStringsSep "" [ "[" ( builtins.toString index ) "]" eval.value ] ; } ;
                                                                in builtins.map mapper indices ;
                                                            failures = builtins.filter ( eval : ! eval.success ) eval ;
                                                            indices = builtins.genList ( i : i ) ( builtins.length observed ) ;
                                                            in { success = builtins.length failures == 0 ; value = builtins.concatStringsSep "; " failures ; } ;
                                                    null = simple ;
                                                    path = simple ;
                                                    set =
                                                      observed : expected :
                                                        if builtins.attrNames observed != builtins.attrNames expected then { success = false ; value = builtins.concatStringsSep " -\n\n" [ "set attrNames" "observed" ( builtins.concatStringsSep "," ( builtins.attrNames observed ) ) "expected" ( builtins.concatStringsSep "," ( builtins.attrNames expected ) ) ] ; }
                                                        else
                                                          let
                                                            eval =
                                                              let
                                                                mapper =
                                                                  index :
                                                                    let
                                                                      eval = equality ( builtins.getAttr index expected ) ( builtins.getAttr index observed ) ;
                                                                      in { success = eval.success ; value = builtins.concatStringsSep "" [ "{" index "}" eval.value ] ; } ;
                                                                      in builtins.map mapper indices ;
                                                            failures = builtins.filter ( eval : ! eval.success ) eval ;
                                                            indices = builtins.attrNames observed ;
                                                            in { success = builtins.length failures == 0 ; value = builtins.concatStringsSep " , " ( builtins.map ( eval : eval.value ) failures ) ; } ;
                                                    string = simple ;
                                              } ;
                                            in
                                              observed : expected :
                                                if builtins.typeOf observed != builtins.typeOf expected then { success = false ; value = "type mismatch" ; }
                                                else builtins.getAttr ( builtins.typeOf observed ) visitors observed expected ;
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
                                                        equals = builtins.trace ( builtins.concatStringsSep " , " ( builtins.attrNames observed ) ) ( observed == expected ) ;
							observed = builtins.tryEval ( observer ( builtins.getAttr system implementation.lib ) ) ;
                                                        in
                                                          if equals then ""
                                                          else path-to-string track.path ;
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