# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license

{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    "plugins-snacks" = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (inputs.nixCats) utils;
      luaPath = "${./.}";
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;

      extra_pkg_config = {
        allowUnfree = true;
      };

      # see :help nixCats.flake.outputs.overlays
      inherit (forEachSystem (system:
        let
          dependencyOverlays = (import ./overlays inputs) ++ [
            (utils.standardPluginOverlay inputs)
            # add any other flake overlays here.
          ];
        in
        { inherit dependencyOverlays; })) dependencyOverlays;

      # see :help nixCats.flake.outputs.categories and
      # :help nixCats.flake.outputs.categoryDefinitions.scheme
      categoryDefinitions = { pkgs, settings, categories, name, ... }@packageDef: {

        # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

        lspsAndRuntimeDeps = {
          general = with pkgs; [
            universal-ctags
            ripgrep
            fd
          ];
          lint = with pkgs; [
          ];
          debug = with pkgs; {
            go = [ delve ];
          };
          go = with pkgs; [
            gopls
            gotools
            go-tools
            gccgo
          ];
          format = with pkgs; [
          ];
          neonixdev = {
            inherit (pkgs) nix-doc lua-language-server nixd;
          };
        };

        startupPlugins = {
          debug = with pkgs.vimPlugins; [
            nvim-nio
          ];
          general = with pkgs.vimPlugins; {
            always = [
              lze
              vim-repeat
              plenary-nvim
            ];
            extra = [
              oil-nvim
              nvim-web-devicons
	      pkgs.neovimPlugins.snacks
            ];
          };

          # :help nixCats.flake.outputs.categoryDefinitions.scheme
          themer = with pkgs.vimPlugins;
            (builtins.getAttr categories.colorscheme {
              # Theme switcher without creating a new category
              "onedark" = onedark-nvim;
              "catppuccin" = catppuccin-nvim;
              "catppuccin-mocha" = catppuccin-nvim;
              "tokyonight" = tokyonight-nvim;
              "tokyonight-day" = tokyonight-nvim;
            }
            );
        };

        # `:NixCats pawsible` package-names for packadd
        optionalPlugins = {
          debug = utils.catsWithDefault categories [ "debug" ]
            (with pkgs.vimPlugins; [
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
            ])
            (with pkgs.vimPlugins; {
              go = [ nvim-dap-go ];
            });
          lint = with pkgs.vimPlugins; [
            nvim-lint
          ];
          format = with pkgs.vimPlugins; [
            conform-nvim
          ];
          markdown = with pkgs.vimPlugins; [
            markdown-preview-nvim
          ];
          neonixdev = with pkgs.vimPlugins; [
            lazydev-nvim
          ];
          general = {
            cmp = with pkgs.vimPlugins; [
              # cmp stuff
              nvim-cmp
              luasnip
              friendly-snippets
              cmp_luasnip
              cmp-buffer
              cmp-path
              cmp-nvim-lua
              cmp-nvim-lsp
              cmp-cmdline
              cmp-nvim-lsp-signature-help
              cmp-cmdline-history
              lspkind-nvim
            ];
            treesitter = with pkgs.vimPlugins; [
              nvim-treesitter-textobjects
              nvim-treesitter.withAllGrammars
            ];
            telescope = with pkgs.vimPlugins; [
              telescope-fzf-native-nvim
              telescope-ui-select-nvim
              telescope-nvim
            ];
            always = with pkgs.vimPlugins; [
              nvim-lspconfig
              lualine-nvim
              gitsigns-nvim
              vim-sleuth
              vim-fugitive
              vim-rhubarb
              nvim-surround
            ];
            extra = with pkgs.vimPlugins; [
              fidget-nvim
              # lualine-lsp-progress
              which-key-nvim
              comment-nvim
              undotree
              indent-blankline-nvim
              vim-startuptime

              # EXAMPLE flake package imports
              # pkgs.neovimPlugins.hlargs
            ];
          };
        };

        # variable available to nvim runtime (added to LD_LIBRARY_PATH)
        sharedLibraries = {
          general = with pkgs; [
            # <- this would be included if any of the subcategories of general are
            # libgit2
          ];
        };

        # environmentVariables:
        # at RUN TIME for plugins. Available to path within neovim terminal
        environmentVariables = {
          test = utils.catsWithDefault categories [ "test" ]
            {
              CATTESTVARDEFAULT = "It worked!";
            }
            {
              subtest1 = {
                CATTESTVAR = "It worked!";
              };
              subtest2 = {
                CATTESTVAR3 = "It didn't work!";
              };
            };
        };

        extraWrapperArgs = {
          test = [
            '' --set CATTESTVAR2 "It worked again!"''
          ];
        };

        extraPython3Packages = {
          test = (_: [ ]);
        };

        extraLuaPackages = {
          general = [ (_: [ ]) ];
        };
      };




      # packageDefinitions:

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions = {

        nixCats = { pkgs, ... }@misc: {

          # see :help nixCats.flake.outputs.settings
          settings = {
            wrapRc = true;
            configDirName = "nixCats-nvim";
            aliases = [ "vim" "vimcat" ];
            # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
          };

          # see :help nixCats.flake.outputs.packageDefinitions
          categories = {
            markdown = true;
            general = true;
            lint = true;
            format = true;
            neonixdev = true;
            test = {
              subtest1 = true;
            };
            # go = true; # <- disabled but you could enable it with override
            # debug.go = true; # <- disabled but you could enable it with override

            lspDebugMode = false;

            themer = true;
            colorscheme = "onedark";
            nixdExtras = {
              nixpkgs = nixpkgs.outPath;
            };
          };
        };

        regularCats = { pkgs, ... }@misc: {
          settings = {
            wrapRc = false;
            configDirName = "nixCats-nvim";
            aliases = [ "testCat" ];
            # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
          };
          categories = {
            markdown = true;
            general = true;
            neonixdev = true;
            lint = true;
            format = true;
            test = true;
            # go = true; # <- disabled but you could enable it with override
            # debug.go = true; # <- disabled but you could enable it with override
            lspDebugMode = false;
            themer = true;
            colorscheme = "catppuccin";
            nixdExtras = {
              nixpkgs = nixpkgs.outPath;
            };
            theBestCat = "says meow!!";

            theWorstCat = {
              thing'1 = [ "MEOW" '']]' ]=][=[HISSS]]"[['' ];
              thing2 = [
                {
                  thing3 = [ "give" "treat" ];
                }
                "I LOVE KEYBOARDS"
                (utils.mkLuaInline ''[[I am a]] .. [[ lua ]] .. type("value")'')
              ];
              thing4 = "couch is for scratching";
            };
          };
        };
      };

      defaultPackageName = "nixCats";
    in
    forEachSystem
      (system:
        let
          nixCatsBuilder = utils.baseBuilder luaPath
            {
              inherit nixpkgs system dependencyOverlays extra_pkg_config;
            }
            categoryDefinitions
            packageDefinitions;
          defaultPackage = nixCatsBuilder defaultPackageName;

          pkgs = import nixpkgs { inherit system; };

        in
        {
          packages = utils.mkAllWithDefault defaultPackage;

          devShells = {
            default = pkgs.mkShell {
              name = defaultPackageName;
              packages = [ defaultPackage ];
              inputsFrom = [ ];
              shellHook = ''
        '';
            };
          };

        }) // {

      overlays = utils.makeOverlays luaPath
        {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = utils.mkNixosModules {
        inherit defaultPackageName dependencyOverlays luaPath
          categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
      };

      homeModule = utils.mkHomeModules {
        inherit defaultPackageName dependencyOverlays luaPath
          categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
      };
      inherit utils;
      inherit (utils) templates;
    };
}
