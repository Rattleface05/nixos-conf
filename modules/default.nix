{ self, inputs, ... }: {
  flake.nixosConfigurations.cratita = inputs.nixpkgs.lib.nixosSystem {

    specialArgs = { inherit inputs; };

    modules = with self.nixosModules; [
      configuration
      old_outputs
    ];
  };
}
