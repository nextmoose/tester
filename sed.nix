  pkgs : dollar :
    pkgs.writeShellScript
      "sed"
      ''
        ${ pkgs.gnused }/bin/sed \
        -e "s#61232b8e-1df9-4f7e-8ec5-538cb9b21aaa#on#" \
        -e "s#e7d90318-28cf-4b6f-81de-cd975c20bc03##" \
        -e "s#b200830c-8d41-4c5d-964c-5ecaaba35204#with#" \
        -e "w${ dollar "1" }"
      ''
