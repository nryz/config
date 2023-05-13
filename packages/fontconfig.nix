{ lib, pkgs, my 
, font}:

pkgs.writeText "fonts.conf" ''
  <?xml version='1.0'?>
  <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
  <fontconfig>
    <!-- Font directories -->
    <dir>${font.package}</dir>

    <!-- Include the system font configs -->
    <include ignore_missing="yes">/etc/fonts/conf.d</include>
    <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
  </fontconfig>
''