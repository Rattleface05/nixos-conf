{ inputs, self, ... }: {
  flake.nixosModules.old_outputs = { pkgs, ... }: {
    # system = "x86_64-linux";

    modules = [
      # Minegrub
      self.minegrub-theme.nixosModules.default

      # Nix-Flatpak
      self.nix-flatpak.nixosModules.nix-flatpak

      # CachyOS kernel overlay
      {
        nixpkgs.overlays = [
          # Use the exact nixpkgs revision as defined in this repo to ensure binary cache hits.
          self.nix-cachyos-kernel.overlays.pinned

          # Alternatively, use nixpkgs from your environment, nixpkgs.config will apply.
          # Note: may not hit binary cache; kernel will need to be built locally.
          # nix-cachyos-kernel.overlays.default

          # Only use one of the two overlays!

        ];

        nix.settings.extra-substituters = [ "https://cache.lantian.pub/lantian" ];
        nix.settings.extra-trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];

      }

      # Anime Team config
      {
        imports = [ self.aagl.nixosModules.default ];
        nix.settings = self.aagl.nixConfig; # Set up Cachix
        programs.anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
        programs.anime-games-launcher.enable = false;
        programs.honkers-railway-launcher.enable = true;
        programs.honkers-launcher.enable = false;
        programs.wavey-launcher.enable = false;
        programs.sleepy-launcher.enable = true;
      }

      # Nix VS Code Extensions
      {
        nixpkgs.overlays = [
          self.nix-vscode-extensions.overlays.default
        ];
      }

      # Deadlock Mod Manager cache
      {
        nix.settings = {
          extra-substituters = [ "https://deadlock-mod-manager.cachix.org" ];
          extra-trusted-public-keys = [
            "deadlock-mod-manager.cachix.org-1:wUjtzL6yN2i9zTq1YrXHBr0mx3LP7tBGsosk3N+/A/M="
          ];
        };
      }

      # Nix User Repo enabling
      self.nur.modules.nixos.default

      # Home Manager
      self.home-manager.nixosModules.default
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          backupFileExtension = "-backup";
          users.dumi = import ./home/_home.nix;

        };
      }

    ];
  };

}
