{
  description = "NixOS configuration with CachyOS kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/41e143a332d88d45c6149bfea9e62a4aea07bff5?narHash=sha256-33rs%2BOXTYF2PUYULx%2BTN4f4gE6eLiKesIge59V2BZW4%3D";

    kwin-effects-better-blur-dx = {
      url = "github:xarblu/kwin-effects-better-blur-dx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel";
      inputs.nixpkgs.follows = "nixpkgs";

    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minegrub-theme.url = "github:Lxtharia/minegrub-theme";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-cachyos-kernel,
      nix-flatpak,
      nur,
      home-manager,
      lazyvim,
      aagl,
      minegrub-theme,
      ...
    }@inputs:
    {

      nixosConfigurations.cratita = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          # Your normal NixOS configuration
          ./configuration.nix

          # Minegrub
          minegrub-theme.nixosModules.default

          # Nix-Flatpak
          nix-flatpak.nixosModules.nix-flatpak

          # CachyOS kernel overlay
          {
            nixpkgs.overlays = [
              # Use the exact nixpkgs revision as defined in this repo to ensure binary cache hits.
              # nix-cachyos-kernel.overlays.pinned

              # Alternatively, use nixpkgs from your environment, nixpkgs.config will apply.
              # Note: may not hit binary cache; kernel will need to be built locally.
              nix-cachyos-kernel.overlays.default

              # Only use one of the two overlays!
            ];
          }

          # Anime Team config
          {
            imports = [ aagl.nixosModules.default ];
            nix.settings = aagl.nixConfig; # Set up Cachix
            programs.anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
            programs.anime-games-launcher.enable = false;
            programs.honkers-railway-launcher.enable = true;
            programs.honkers-launcher.enable = false;
            programs.wavey-launcher.enable = false;
            programs.sleepy-launcher.enable = true;
          }

          # Nix User Repo enabling
          nur.modules.nixos.default

          # Home Manager
          home-manager.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              backupFileExtension = "-backup";
              users.dumi = import ./home/home.nix;

            };
          }

        ];
      };

    };

}
