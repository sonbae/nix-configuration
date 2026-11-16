{
  description = "Personal Nix configuration shared across devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      # Every platform this config should work on.
      systems = [
        "aarch64-darwin" # Apple Silicon Macs
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # Build a home-manager configuration for one user on one device.
      mkHome = { system, username }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home
            {
              home.username = username;
              home.homeDirectory =
                if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
            }
          ];
        };
    in
    {
      # One entry per device, named "<user>@<hostname>".
      # `home-manager switch --flake .` picks the entry matching the current
      # user and hostname automatically.
      homeConfigurations = {
        "sonbae@corona" = mkHome {
          system = "aarch64-darwin";
          username = "sonbae";
        };
      };

      # The home-manager CLI, pinned to the version in flake.lock:
      #   nix run .#home-manager -- switch --flake .
      packages = forAllSystems (pkgs: {
        home-manager = home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.home-manager;
      });
    };
}
