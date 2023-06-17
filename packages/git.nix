{
  pkgs,
  my,
  wrapPackage,
}:
with pkgs.lib; let
in
  wrapPackage {
    pkg = pkgs.git;
    name = "git";

    vars = {
      "GIT_CONFIG_GLOBAL" = "${placeholder "out"}/config/git/config";
    };

    files = {
      "config/git/config" = let
        difftCommand = concatStringsSep " " [
          "${pkgs.difftastic}/bin/difft"
          "--color always"
          "--background dark"
          "--display side-by-side"
        ];
      in ''
         [alias]
         lb = branch -avvv
         lc = log --oneline
         lf = status -sb
         last = log -1 HEAD --stat

         [diff]
        external = ${difftCommand}
         tool = difftastic

         [difftool]
         prompt = false

         [difftool "difftastic"]
         cmd = ${difftCommand} "$LOCAL" "$REMOTE"

         [pager]
         difftool = true

         [user]
         useConfigOnly = true
      '';
    };
  }
