{
  inputs,
  pkgs,
  config,
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
    ccHarder = true;

    rt = true;

    # Personal tweaks
    cachyosConfigFile = ./.config.unstable;
  };

  # Apply the v4l2loopback fix to the CachyOS kernel packages
  kernelFixed = (pkgs.linuxKernel.packagesFor kernel).extend (
    final: prev: {
      v4l2loopback = prev.v4l2loopback.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          module_dir="$out/lib/modules/${final.kernel.modDirVersion}"

          rm -f "$module_dir"/modules.alias \
                "$module_dir"/modules.alias.bin \
                "$module_dir"/modules.dep \
                "$module_dir"/modules.dep.bin \
                "$module_dir"/modules.softdep \
                "$module_dir"/modules.symbols \
                "$module_dir"/modules.symbols.bin \
                "$module_dir"/modules.builtin.alias.bin \
                "$module_dir"/modules.builtin.bin \
                "$module_dir"/modules.devname
        '';
      });
    }
  );
in
{
  # Use CachyOS kernel.
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;

  # Xanmod kernel
  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # boot.extraModulePackages = [
  #   config.boot.kernelPackages.v4l2loopback
  # ];

}
