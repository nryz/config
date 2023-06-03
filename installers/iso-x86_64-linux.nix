{ additionalStorePaths, outPath, nixosModules, config, pkgs, lib, modulesPath, ...}:

{
  imports = [
    nixosModules.core-profile
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  networking.hostName = "iso-x86_64";

  host-scripts.type = "isoImage";

  nixpkgs.hostPlatform = "x86_64-linux";

  isoImage.storeContents = additionalStorePaths; 
  isoImage.contents = [ {
    source = outPath;
    target = "config";
  } ];

  boot.postBootCommands = ''
    mkdir /home/nixos/config
    cp -r /iso/config/* /home/nixos/config/
    chown -R nixos:users /home/nixos/config
    chmod -R +w /home/nixos/config
  '';

  users.users.nixos = {
    shell = config.mypkgs.zsh;

    packages = with config.mypkgs; [
      joshuto
      helix
    ];
  };
}
