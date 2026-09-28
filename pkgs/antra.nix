# Antra music downloader

{
  lib,
  appimageTools,
  fetchurl,
  glib-networking,
}:

let
  pname = "Antra";
  version = "1.1.7";

  src = fetchurl {
    url = "https://github.com/anandprtp/Antra/releases/download/v${version}/Antra-Linux.AppImage";
    hash = "sha256-P1XJhD5NIC8JDQTC3dvwsfqk6oJ0BJyqNN8pTh0RnSk=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [
    pkgs.webkitgtk_4_1
    glib-networking
    pkgs.libsoup_3
  ];

  # PICTURES DON'T SHOW UP WITHOUT THIS
  extraBwrapArgs = [
    "--setenv"
    "GIO_EXTRA_MODULES"
    "${glib-networking}/lib/gio/modules"
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/Antra.desktop \
      $out/share/applications/${pname}.desktop

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-warn "Exec=AppRun" "Exec=${pname}"

    install -m 444 -D ${appimageContents}/Antra.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png
  '';

  meta = {
    description = "An application packaged from an AppImage";
    homepage = "https://github.com/anandprtp/Antra";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "Antra";
  };
}
