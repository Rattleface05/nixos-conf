{
  osConfig,
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.lazyvim.homeManagerModules.default ];

  home = {
    stateVersion = "26.05";
    username = "dumi";
    homeDirectory = "/home/dumi";
  };

  programs.lazyvim = {
    enable = true;

    extras = {
      lang = {
        nix.enable = true;
        python = {
          enable = true;
          installDependencies = true; # Install ruff
          installRuntimeDependencies = false; # Install python3
        };

        rust = {
          enable = true;
          installDependencies = true;
          installRuntimeDependencies = false;
        };

        cmake.enable = true;
        clangd.enable = true;

        git.enable = true;

        haskell.enable = true;
        docker = {
          enable = true;
          installDependencies = true;
          installRuntimeDependencies = false;
        };
      };

      coding = {
        yanky.enable = true;
        luasnip.enable = true;
      };

      linting.eslint.enable = true;

      lsp.neoconf.enable = true;

      ui.smear-cursor.enable = true;
    };

    plugins = {
      lsp = inputs.lazyvim.lib.lazyConfig {
        plugin = "neovim/nvim-lspconfig";
        opts = {
          servers = {
            nixd = {
              settings = {
                nixd = {
                  nixpkgs = {
                    expr = "import <nixpkgs> { }";
                  };

                  formatting = {
                    command = [ "nixfmt" ];
                  };
                };
              };
            };

            # Prevent the Nix extra from trying to configure nil.
            nil_ls = {
              enabled = false;
            };
          };
        };
      };
      snacks = inputs.lazyvim.lib.lazyConfig {
        plugin = "folke/snacks.nvim";
        opts = {
          picker = {
            hidden = true;
            sources = {
              files = {
                hidden = true;
              };
              grep = {
                hidden = true;
              };
            };
          };
        };

      };
    };

    # Additional packages (optional)
    extraPackages = with pkgs; [
      nixd
      nixfmt

      # Python
      pyright

      # Rust
      rust-analyzer

      # C/C++ & CMake
      llvmPackages.clang-tools
      cmake-language-server

      # Haskell
      haskell-language-server

      # Docker
      dockerfile-language-server

      # Plugins
      vimPlugins.nvim-lspconfig
      vimPlugins.nvim-treesitter.withAllGrammars

    ];

    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      lua
      nix
    ];
  };

  # TLDR tealdeer implementation
  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
    settings.updates.auto_update = true;
  };

  # Lutris
  programs.lutris = {
    enable = true;
    extraPackages = with pkgs; [
      mangohud
      winetricks
      gamemode
      umu-launcher
    ];
    protonPackages = with pkgs; [
      proton-ge-bin
    ];

    steamPackage = osConfig.programs.steam.package;
  };

  # VS Code
  programs.vscode = {
    enable = true;
    profiles.default.extensions =
      (with pkgs.vscode-extensions; [
        # C++ Extension Pack
        ms-vscode.cpptools-extension-pack
        ms-vscode.cpptools
        # ms-vscode.cpp-devtools
        # ms-vscode.cpptools-themes
        ms-vscode.cmake-tools

        ms-azuretools.vscode-containers

        # Java
        vscjava.vscode-java-pack
        redhat.java
        vscjava.vscode-java-debug
        vscjava.vscode-maven
        vscjava.vscode-java-test
        vscjava.vscode-java-dependency
        vscjava.vscode-gradle

        # Jupyter
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow

        # Python
        ms-python.python
        ms-python.vscode-pylance
        ms-python.debugpy
        ms-python.vscode-python-envs

        rust-lang.rust-analyzer
        tomoki1207.pdf
        jnoortheen.nix-ide
      ])
      ++ (with pkgs.nix-vscode-extensions.vscode-marketplace; [
        dtoplak.vscode-glsllint

        # Haskell Extension Pack
        mogeko.haskell-extension-pack
        haskell.haskell
        hoovercj.haskell-linter

        ms-vscode.cpp-devtools
        ms-vscode.cpptools-themes
        slevesque.shader
      ]);
  };

  # BASH
  programs.bash = {
    enable = true;
    shellAliases = {
      "flake-rebuild" = "nh os switch --impure";
      "flake-update" = "sudo nix flake update --flake $HOME/nixos-conf/";
    };
    bashrcExtra = builtins.readFile ./.bashrc;
  };

}
