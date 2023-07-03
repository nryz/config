def create_left_prompt [with_git: bool = false] {
    mut home = ""
    try { $home = $env.HOME }

    let dir = ([
        ($env.PWD | str substring 0..($home | str length) | str replace --string $home "~"),
        ($env.PWD | str substring ($home | str length)..)
    ] | str join)

    let path_segment = $"(ansi $base16.base0D)($dir)"
    let duration_segment = (do {||
        let duration_secs = ($env.CMD_DURATION_MS | into int) / 1000
        if ($duration_secs >= 3) {
            $" (ansi yellow)($duration_secs | math round | into string | append "sec" | str join | into duration) "
        } else {
            ""
        }
    })
    let overlay_segment = $" (ansi red)(overlay list | range 1.. | par-each { |it| $' ($it)' } | str join)"

    if $with_git {
        let git_branch_name_command = {(git branch | lines | find "*" | split words | ^echo $in )}
        let git_upstream_branch_name_command = {(git rev-parse --abbrev-ref @{upstream})}
        let git_status_command = {(git status --porcelain | is-empty | if $in {""} else {"*"})}

        let commands = ([ 
            $git_branch_name_command 
            $git_upstream_branch_name_command
            $git_status_command] | par-each { |it| do $it } )

        let git_branch_name_str = $commands.0
        let git_upstream_branch_name_str = $commands.1
        let git_status_str = $commands.2
    
        let git_ahead_behind_str = (git rev-list --left-right --count $"($git_branch_name_str)...($git_upstream_branch_name_str)" | split row "\t" | str trim | $"($in.0)/($in.1)")

        let git_branch_segment = $" (ansi $base16.base03)($git_branch_name_str)"
        let git_status_segment = $" (ansi $base16.base0E)($git_status_str)"
        let git_commit_segment = $" (ansi $base16.base0D)[($git_ahead_behind_str)]"

        [ 
            $path_segment
            $git_branch_segment
            $git_status_segment
            $git_commit_segment
            $overlay_segment
            $duration_segment
            "\n\r"
        ]
        | str join

    } else {
        [ 
            $path_segment
            $overlay_segment
            $duration_segment
            "\n\r"
        ]
        | str join
    }
}

let-env PROMPT_COMMAND = {|| create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = ""

let-env PROMPT_INDICATOR = {|| $"(ansi $base16.base0E)> " }
let-env PROMPT_INDICATOR_VI_INSERT = {|| $"(ansi $base16.base0E)> " }
let-env PROMPT_INDICATOR_VI_NORMAL = {|| $"(ansi $base16.base0E)> " }
let-env PROMPT_MULTILINE_INDICATOR = {|| "::: " }


if true {
let path_from_string = { |s| $s | split row (char esep) | path expand --no-symlink } 
let path_to_string = { |v| $v | path expand --no-symlink | str join (char esep) }
let path_conversion = {
    from_string: $path_from_string
    to_string: $path_to_string
}

let-env ENV_CONVERSIONS = {
    "PATH": $path_conversion 
    "XDG_DATA_DIRS": $path_conversion
    "XDG_CONFIG_DIRS": $path_conversion
    "XCURSOR_PATH": $path_conversion
    "TERMINFO_DIRS": $path_conversion
    "QT_PLUGIN_PATH": $path_conversion
    "QTWEBKIT_PLUGIN_PATH": $path_conversion
    "NIX_PATH": $path_conversion
    "MOZ_PLUGIN_PATH": $path_conversion
    "INFOPATH": $path_conversion
    "GTK_PATH": $path_conversion
    "KDEDIRS": $path_conversion

    "NIX_PROFILES": {
        from_string: { |s| $s | split row (char sp) | path expand --no-symlink } 
        to_string: { |v| $v | path expand --no-symlink | str join (char sp) }
    }
}
}
