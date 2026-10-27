#vpkmerge
{
  stdenv,
  lib,
  makeDesktopItem,
  copyDesktopItems,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,

  hicolor-icon-theme,
  webkitgtk_4_1,
  gtk3,
  glib,
  libayatana-appindicator,
}:
let
  pname = "vpkmerge-gui";
  version = "0.17.1";

  src = fetchurl {
    url = "https://github.com/Slush97/vpkmerge/releases/download/v${version}/vpkmerge_${version}_amd64.deb";
    sha256 = "sha256-lOu+4jh/lnYGoCevDbAKw/CHOnHaWuC+q9h3IIk/35A=";
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    libayatana-appindicator
    glib
    hicolor-icon-theme
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    rm -rf $out/share/doc

    ln -s $out/bin/vpkmerge-gui $out/bin/vpkmerge

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "vpkmerge";
      exec = "vpkmerge";
      icon = "vpkmerge-gui";
      desktopName = "VPKmerge";
      genericName = "Visual VPK merger for Deadlock mods";
      categories = [
        "Development"
        "Utility"
      ];
    })
  ];

  meta = with lib; {
    description = "Combine multiple Valve Pak (.vpk) mods into one (Deadlock modding; desktop app, prebuilt)";
    homepage = "https://github.com/Slush97/vpkmerge";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
