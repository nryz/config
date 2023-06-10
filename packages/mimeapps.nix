{
  lib,
  pkgs,
  my,
  editor,
  browser,
  videoPlayer,
  imageViewer,
  pdfViewer,
}:
pkgs.writeText "mimeapps.list" ''
  [Added Associations]

  [Default Applications]
  application/pdf=${pdfViewer.desktop}
  image/*=${imageViewer.desktop}
  text/*=${editor.desktop}
  text/html=${browser.desktop}
  x-scheme-handler/http=${browser.desktop}
  x-scheme-handler/https=${browser.desktop}
  video/*=${videoPlayer.desktop}

  [Removed Associations]
''
