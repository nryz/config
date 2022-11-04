{ lib, pkgs, my 
, editor
, browser
, videoPlayer
, imageViewer
, pdfViewer}:


pkgs.writeText "mimeapps.list" ''
    [Added Associations]

    [Default Applications]
    application/pdf=${pdfViewer.desktop}
    image/*=${imageViewer.desktop}
    text/*=${editor.desktop}
    text/html=${browser.desktop}
    video/*=${videoPlayer.desktop}

    [Removed Associations]
''