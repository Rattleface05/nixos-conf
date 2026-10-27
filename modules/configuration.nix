{ ... }: {
  flake.nixosModules.configuration = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      firefox
      thunderbird
      git
    ];

    imports = [
      /etc/nixos/hardware-configuration.nix
    ];
  };
}
