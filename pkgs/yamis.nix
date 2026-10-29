{ stdenvNoCC, fetchurl }:
let
  pname = "yet-another-monochrome-icon-set";
  version = "ba9ce22"; # v1.6.1

  src = fetchurl {
    url = "https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set/get/${version}.tar.gz";
    sha256 = "sha256-YmXVHRG6acR72QvqYWOdmUjZOfdao6UZv3/QyJalCVk=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/YAMIS

    cp -r dirn-typo-yet-another-monochrome-icon-set-*/* $out/share/icons/YAMIS/

    runHook postInstall
  '';

  meta = {
    description = "A monochrome adaptive icon theme for KDE Plasma and desktop environments";
    homepage = "https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set";
    platforms = [
      "any"
      "x86_64-linux"
    ];
  };
}
