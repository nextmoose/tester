#!bin/sh

cat flake.lock | jq --raw-output '.root as $root | .nodes | to_entries | map ( select ( .key != $root ) ) | map ( { key : .key , value : .value.original } ) | map ( { key : .key , value : ( .value.type == "github" and ( .value | has ( "owner" ) ) and ( .value | has ( "repo" ) ) and ( .value | has ( "rev" ) ) ) } )'
