# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  config,
  pkgs,
  ...
}:
let
  # Kernel Customizations
  kernel = pkgs.cachyosKernels.linux-cachyos-latest.override {

    # Customize CachyOS settings
    cpusched = "rt-bore";
    # lto = "thin";
    # autofdo = "true";
    processorOpt = "native";
    hzTicks = "1000";
    bbr3 = true;

    rt = true;

    # Personal tweaks
    cachyosConfigFile = ./kernel/.config;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-import.nix

    # Packages
    ./pkgs/pkgs.nix

    # Nix LD options
    ./nix-ld.nix
  ];

  # DONT Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;

  # gwub
  boot.loader = {

    grub = {
      enable = true;
      configurationLimit = 7;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;
      extraEntries = ''
        menuentry "UEFI Firmware Settings" {
          fwsetup
        }
      '';
    };

    efi.canTouchEfiVariables = true;

  };
  # Use CachyOS kernel.
  boot = {
    # For Non-LTO kernels
    kernelPackages = pkgs.linuxKernel.packagesFor kernel;

    # For LTO kernels, helpers.kernelModuleLLVMOverride fixes compilation for some
    # out-of-tree modules in nixpkgs.
    # kernelPackages =
    #   let
    #     # helpers.nix provides a few utilities for building kernel with LTO.
    #     # I haven't figured out a clean way to expose it in flakes.
    #     helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };
    #   in
    #   helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor kernel);
  };

  # Xanmod kernel
  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Zswap
  boot.zswap = {
    enable = true;
    maxPoolPercent = 25;
    shrinkerEnabled = true;
    compressor = "zstd";
    acceptThresholdPercent = 90;
  };

  networking.hostName = "cratita"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # No firewall,  i like it raw
  networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;

  # Drivers
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable flatpak + use nix-flatpak to declare what flatpaks to install
  services.flatpak = {
    enable = true;
    packages = [ ];
  };

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.plasma-login-manager.enable = true;
  # services.displayManager.plasma-login-manager.settings = {
  #   Autologin = {
  #     Session = "plasma.desktop";
  #     User = "dumi";
  #   };
  # };
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "dumi";
    };

  };
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    kwin-x11
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # ClamAV freshclam
  services.clamav.updater.enable = true;

  # Hamachi
  # services.logmein-hamachi.enable = true;

  # LACT
  services.lact.enable = true;
  hardware.amdgpu.overdrive.enable = true;

  # QBitTorrent
  #services.qbittorrent = {
  #  enable = true;
  #  package = pkgs.qbittorrent-enhanced;
  #};

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # Use the WirePlumber session manager
    #wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."dumi" = {
    isNormalUser = true;
    description = "dumi";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    preferencesStatus = "user";
  };

  # Install steam.
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;

  # Gamemode
  programs.gamemode.enable = true;

  # GPU Screen Recoder
  programs.gpu-screen-recorder.ui.enable = true;
  programs.gpu-screen-recorder.enable = true;

  systemd.services.gpu-screen-recorder.enable = false;
  systemd.user.services.gpu-screen-recorder.enable = false;

  # Appimages
  programs.appimage.binfmt = true;
  programs.appimage.enable = true;

  # Virt Manager
  programs.virt-manager.enable = true;

  # Enable Libvirtd
  virtualisation.libvirtd.enable = true;

  # LazyVim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Nix Helper
  programs.nh = {
    flake = "/home/dumi/nixos-conf";
    enable = true;
  };

  # Droidcam
  programs.droidcam.enable = true;

  # OBS Studio
  programs.obs-studio = {
    enable = true;
    plugins = [ ];
    enableVirtualCamera = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Optimize store
  nix.settings.auto-optimise-store = true;

  # Automatic Garbace Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Max 2 jobs
  # nix.settings.max-jobs = 2;

  # Nix LSP stuff
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Turn off firmware updates
  # services.fwupd.enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "26.05"; # Did you read the comment?
  # no i didn't i can't read sorry
}
