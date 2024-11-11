{
  description = "aaarrruuu Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.mkalias
          pkgs.stow
          pkgs.fish
          pkgs.discord
          pkgs.docker
          pkgs.vscode
          pkgs.spotify
        ];

      homebrew = {
        enable = true;
        casks = [
          "kitty"
          "nikitabobko/tap/aerospace"
          "font-cascadia-code-nf"
          "dbeaver-community"
          "gimp"
          "devtoys"
          "monitorcontrol"
        ];
        brews = [
          "eza"
          "zoxide"
          "tmux"
          "neovim"
          "pyenv"
          "mas"
          "starship"
          "fisher"
          "bat"
          "ripgrep"
          "fzf"
          "gh"
          "lazydocker"
          "lazygit"
          "tree"
          "rustup"
          "yazi"
          "bun"
          "nvm"
        ];
        taps = [
          "oven-sh/bun"
        ];
        masApps = {
          "Xcode" = 497799835;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';

      system.defaults = {
        dock.autohide = true;
        dock.persistent-apps = [
          "/System/Applications/Calendar.app"
          "/Applications/kitty.app"
          "/Applications/Safari.app"
          "/Applications/Firefox.app"
          "/Applications/Google Chrome.app"
          "/Applications/Brave Browser.app/"
          "/Applications/Microsoft Edge.app"
          "/Applications/Opera GX.app"
          "${pkgs.vscode}/Applications/Visual Studio Code.app"
          "/Applications/Xcode.app"
          "/Applications/GameMaker.app"
          "/Applications/DevToys.app"
          "/Applications/DBeaver.app"
          "/Applications/GIMP.app"
          "${pkgs.discord}/Applications/Discord.app"
          "${pkgs.spotify}/Applications/Spotify.app"
        ];
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
      };
      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      users.users.alpolinar = {
        shell = pkgs.fish;
      };

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mbp14
    darwinConfigurations."mbp14" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "alpolinar";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = true;
            autoMigrate = true;
          };
        }
      ];
    };

    

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."mbp14".pkgs;
  };
}
