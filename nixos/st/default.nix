args: let
  pkgs = args.pkgs;
  configPath = args.configPath;
 
in {
  type = "app";
  program = "${pkgs.writers.writePython3 "st" {
    libraries = [ ];
    #just let me write shit ffs
    flakeIgnore = [ "E501" "E302" "E126" "W293" "E303"];
  }(''
    import subprocess
    import argparse
    import glob
    import sys
    import re
    import os

    config_path = '${configPath}'
    nvd = '${pkgs.nvd}/bin/nvd'
  '' + builtins.readFile ./st.py)}";
}
