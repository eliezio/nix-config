{
  description = "My Home Manager configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixvim, ... }:
  let
    mkHome = { username, system, homeDir ? null }: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      extraSpecialArgs = { inherit username system; };

      modules = [
        {
          home.username = username;
          home.homeDirectory = if homeDir != null then homeDir else
            if builtins.match ".*darwin" system != null
            then "/Users/${username}"
            else "/home/${username}";
        }
        nixvim.homeModules.nixvim
        ./home.nix
      ];
    };
  in {
    homeConfigurations = {
      "ubuntu@aarch64-linux" = mkHome {
        username = "ubuntu";
        system    = "aarch64-linux";
      };
    };
  };
}
