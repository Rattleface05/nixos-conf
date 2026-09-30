{ inputs, pkgs, ... }:
{
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    signal-desktop
    croc
    discord
    openssh
    alacritty
    ghostty
    git
    github-cli
    lazygit
    rustc
    cargo
    vscode

    # KDE stuff
    kdePackages.kate
    kdePackages.sddm-kcm
    kdePackages.filelight
    plasma-panel-colorizer

    gcc
    ventoy-full-qt
    valgrind
    fastfetch
    cowsay
    fortune
    inputs.kwin-effects-better-blur-dx.packages.${pkgs.system}.default
    ripgrep
    lua-language-server
    nodejs
    tree
    fzf
    bash-completion
    nix-bash-completions
    nixd
    python3
    bat
    zip
    unzip
    haskell-language-server
    ghc
    statix
    wl-clipboard
    fd
    imagemagick
    (pkgs.writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
      ];
      text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
    })
    imgbrd-grabber
    audacity
    microcode-amd
    bottles
    qbittorrent-enhanced
    haguichi
    logmein-hamachi

    # Fuck this shit
    # gpu-screen-recorder-ui
    # gpu-screen-recorder

    btop
    htop
    btrfs-progs
    btrfs-assistant
    clamav
    cmatrix
    gdu
    gimp
    krita
    godot
    localsend
    tor-browser
    vesktop
    mpv
    vlc
    obsidian
    kid3
    protonplus
    shadps4-qtlauncher
    r2modman
    prismlauncher
    vintagestory
    pipx
    ani-cli
    yt-dlp
    deadlock-mod-manager
    mangohud
    lutris
    pipes-rs
    rar
    obsidian
    stremio-linux-shell
    speedtest-rs
    wtf
    wtfis
    onlyoffice-desktopeditors
    gpu-screen-recorder-ui
    lact
    zellij
    tmux
    wine

    # Nix User Repository pkgs
    nur.repos.forkprince.fluxer-canary-bin

    # YAMIS
    (pkgs.callPackage ./yamis.nix { })
    #AppImage bullshit
    (pkgs.callPackage ./antra.nix { })

    # Source2Viewer
    (pkgs.callPackage ./source2viewer.nix { })
    # VPKMerge
    (pkgs.callPackage ./vpkmerge-gui.nix { })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-qt5-1.1.17"
  ];

}
