{ self, inputs, ... }: {
  flake.nixosConfigurations.cratita = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      configuration
      old_outputs
    ];
  };
}
