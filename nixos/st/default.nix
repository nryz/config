{ system, inputs, user } : let
  configPath = "/home/${user}/config";
  
  pkgs = import inputs.nixpkgs { inherit system; };
 
in {
  type = "app";
  program = "${pkgs.writers.writePython3 "st" {
    libraries = [ ];
    #just let me write shit ffs
    flakeIgnore = [ "E501" "E302" "E126" "W293" "E303" "E128" "W291"];
  }(''
    from datetime import date
    import subprocess
    import argparse
    import glob
    import sys
    import re
    import os

    config_path = '${configPath}'
    nvd = '${pkgs.nvd}/bin/nvd'
    borg = '${pkgs.borgbackup}/bin/borg'
    doc_cmd = '${pkgs.nix-doc}/bin/nix-doc'
    doc_source = '${inputs.nixpkgs.sourceInfo.outPath}'
  '' + builtins.readFile ./st.py)}";
}
