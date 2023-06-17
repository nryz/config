{
  pkgs,
  my,
  base16,
  font,
  wrapPackage,
  workspacesScript ? "",
}: let
  iconFont.name = "Material Design Icons";
in
  wrapPackage {
    pkg = pkgs.yambar;
    name = "yambar";

    flags = [
      "--config ${placeholder "out"}/config/yambar.yml"
    ];

    files = {
      "config/yambar.yml" = with base16; ''
        # fonts
        icons: &icons ${iconFont.name}:style=solid:pixelsize=16
        default: &default ${font.name}:style=solid:pixelsize=12

        bar:
          height: 18
          location: top
          background: ${base00}FF
          foreground: ${base05}FF
          border:
            width: 1
            color: ${base01}FF

          left:
            - script:
                path: ${placeholder "out"}/scripts/workspaces
                args: []
                poll-interval: 1
                content:
                  - string: {text: "{tags}", font: *default}
                  - string: {text: "[{client_count}]", font: *default}

          center:
            - clock:
                time-format: "%H:%M"
                date-format: "%A %d %b"
                content:
                  - string: {text: "{date} {time}", font: *default}

          right:
            - script:
                path: ${placeholder "out"}/scripts/volume
                args: []
                poll-interval: 1
                content:
                  - string: {text: "󰕾", right-margin: 3, font: *icons}
                  - string: {text: "{percent}", font: *default}
                  - string: {text: "|", margin: 5, font: *default}
            - cpu:
                interval: 2500
                content:
                  - string: {text: "󰄨", right-margin: 3, font: *icons}
                  - string: {text: "{cpu}%", font: *default}
                  - string: {text: "|", margin: 5, font: *default}
            - mem:
                interval: 2500
                content:
                  - string: {text: "󰍛", right-margin: 3, font: *icons}
                  - string: {text: "{percent_used}%", right-margin: 5, font: *default}
      '';
    };

    shellScripts = {
      "scripts/volume" = ''
        echo "percent|string|$(${pkgs.pamixer}/bin/pamixer --get-volume-human)"
        echo ""
      '';

      "scripts/workspaces" = workspacesScript;
    };
  }
