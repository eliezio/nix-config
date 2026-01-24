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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixvim, sops-nix, ... }:
  let
    username = "ubuntu";
    system = "aarch64-linux";
  in {
    homeConfigurations = {
      "${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
        };

        modules = [
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
          }
          nixvim.homeModules.nixvim
          sops-nix.homeModules.sops
          ./home.nix
        ];
      };
    };
  };
}
