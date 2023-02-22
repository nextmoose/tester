  {
    inputs =
      {
        flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
	implementation.url = "${IMPLEMENTATION}" ;
	test.url = "${TEST}" ;
	tester.url = "github:nextmoose/tester" ;
      } ;
    outputs =
      { flake-utils , implementation , self , test , tester } :
        flake-utils.lib.eachDefaultSystem
	  (
	    system :
	      let
		in builtins.getAttr system tester.lib implementation test
	  ) ;
  }