# source2viewer
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  bash,
  wine64,
  pkgs,
  hicolor-icon-theme,
  makeDesktopItem,
  copyDesktopItems,
}:

let
  version = "20.1";

  # for very nice desktop integration
  mimeFile = pkgs.writeText "source2viewer.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
    	<mime-type type="application/x-source2viewer-vpk">
    		<comment>Valve Pack File</comment>
    		<icon name="source2viewer"/>
    		<acronym>VPK</acronym>
    		<expanded-acronym>Valve Pack File</expanded-acronym>
    		<global-deleteall/>
    		<glob pattern="*.vpk"/>
    		<glob pattern="*.VPK"/>
    	</mime-type>
    </mime-info>
  '';

  srcAsset = fetchFromGitHub {
    owner = "ValveResourceFormat";
    repo = "ValveResourceFormat";
    rev = version;
    sha256 = "sha256-GgDRWrZKqAaWL145r6sAqPA31B8KmqW9XlxG75vzESM=";
  };

  exeSrc = fetchurl {
    url = "https://github.com/ValveResourceFormat/ValveResourceFormat/releases/download/${version}/Source2Viewer.exe";
    sha256 = "sha256-tBsoxuo9kmD3ErmE8DgiWabVfx4N/3xcj7GxdUMvO8s=";
  };
in
stdenv.mkDerivation {
  pname = "source2viewer";
  inherit version;

  src = srcAsset;

  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [
    bash
    wine64
    hicolor-icon-theme
  ];

  installPhase = ''
    runHook preInstall

    # Install the Windows executable into share/source2viewer
    install -Dm644 ${exeSrc} $out/share/source2viewer/source2viewer.exe

    # Install the application icon
    install -Dm644 Misc/Icons/source2viewer.png $out/share/icons/hicolor/512x512/apps/source2viewer.png

    # Install the MIME file
    install -Dm644 ${mimeFile} $out/share/mime/packages/source2viewer.xml

      # Create the launcher script
    mkdir -p $out/bin
    cat << EOF > $out/bin/source2viewer
    #!/usr/bin/env bash
    export PATH="${wine64}/bin:\$PATH"

    # Fallback for HOME if it's unset or invalid
    USER_HOME="\$HOME"
    if [ -z "\$USER_HOME" ]; then
        USER_HOME="/tmp"
    fi

    export WINEARCH=win64
    export WINEPREFIX="\$USER_HOME/.source2viewer/wine"

    if [ ! -d "\$USER_HOME/.source2viewer" ]; then
        mkdir -p "\$USER_HOME/.source2viewer/wine"
        wineboot -u
    fi
    cd "\$USER_HOME/.source2viewer" || exit
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
    export DOTNET_BUNDLE_EXTRACT_BASE_DIR=./
    exec wine $out/share/source2viewer/source2viewer.exe "\$@"
    EOF
    chmod +x $out/bin/source2viewer

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "source2viewer";
      exec = "source2viewer";
      icon = "source2viewer";
      desktopName = "Source 2 Viewer";
      genericName = "Valve's Source 2 resource file format parser";
      categories = [
        "Development"
        "Utility"
      ];
      mimeTypes = [ "application/x-source2viewer-vpk" ];
      extraConfig = {
        PrefersNonDefaultGPU = "true";
      };
    })
  ];

  meta = with lib; {
    description = "Valve's Source 2 resource file format parser, decompiler, and exporter.";
    homepage = "https://github.com/ValveResourceFormat/ValveResourceFormat";
    license = with licenses; [
      mit
      cc-by-25
    ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
