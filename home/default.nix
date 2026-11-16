# Shared home-manager config applied to every device.
{ pkgs, ... }:

{
  imports = [
    ./cloudflared.nix
    ./tmux.nix
    ./vim.nix
  ];

  # Packages with no config to manage. Tools with config get their own file.
  home.packages = with pkgs; [
  ];

  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  # The home-manager release this config was first written against. It keeps
  # stateful defaults stable across upgrades. Don't bump it when updating;
  # read the home-manager release notes first.
  home.stateVersion = "26.11";
}
