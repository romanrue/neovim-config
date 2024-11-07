{ config, pkgs, ... }:

let
  snacks = pkgs.vimUtils.buildVimPlugin {
    name = "snacks-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "snacks.nvim";
      rev = "6ff28b3a37aa9fd08b84d1ef7aeb5e551c25b763";
      hash = "000000000000000000000000000000000000000000000000000";
    };
  };
in
{
  environment.systemPackages = [
    (
      pkgs.neovim.override {
        configure = {
          packages.myPlugins = with pkgs.vimPlugins; {
          start = [
            vim-go # already packaged plugin
            easygrep # custom package
          ];
          opt = [];
        };
        # ...
      };
     }
    )
  ];
}
