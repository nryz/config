export-env {
  if ($env.IS_IN_FLAKE_ENV_OVERLAY? | is-empty) {
    def get-env-variables [name: string = ""] {
      let env_json = (nix print-dev-env $".#($name)" --json | from json) 
      let vars = ($env_json.variables | update cells { |v| $v.value })

      $vars
    }

    # filter new_env and only keep env vars that aren't in the current env
    # manually load/prepend others.
    let new_env_all = (get-env-variables)

    def env_value_empty [name: string] {
      $env | get -i $name | is-empty
    }

    let new_env = (
      $new_env_all
      | transpose name value 
      | where { |x| (env_value_empty $x.name)}
      | transpose -r
      | into record
    )

    load-env $new_env

    # manual

    def path_from_string [s] { 
       $s | split row (char esep) | path expand --no-symlink 
    } 
    let-env PATH = ($env.PATH | prepend (path_from_string ($new_env_all | select -i "PATH" | values).0) | uniq )

    let-env IS_IN_FLAKE_ENV_OVERLAY = 1
  }
}
