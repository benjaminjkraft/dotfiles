{ config, pkgs, lib, ... }:

# TODO: organize me

# many thanks to slim, tons of cribbing from
# https://github.com/sliminality/nix-config/blob/main/darwin-configuration.nix

{
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # TODO: unclear if this does anything, actually
  users.users.benkraft = {
    name = "benkraft";
    home = "/Users/benkraft";
    shell = pkgs.bashInteractive;
  };

  system.activationScripts.postActivation.text = ''
    # Actually set shell:
    # https://shaunsingh.github.io/nix-darwin-dotfiles/#orgb26c90e
    chsh -s ${lib.getBin pkgs.bash}/bin/bash ${config.users.users.benkraft.name}
  '';

  networking.computerName = "homotopy";
  networking.hostName = "homotopy";

  # installed for all users
  environment.systemPackages = [
    pkgs.coreutils
    pkgs.gnused
    pkgs.htop
    pkgs.jq
    pkgs.tmux
    pkgs.vim
    pkgs.xcode-install # note: doesn't seem to actually install xcode?
  ];

  # the one, the only, love it, hate it...
  homebrew = {
    enable = true;
    # TODO once I have all the notion stuff in here:
    # cleanup = "zap";
    taps = [
      "homebrew/cask"
    ];
    casks = [
      "alacritty" # nix alacritty doesn't seem to play nice with the dock :(
      "firefox"
      # installed by kandji:
      # "google-chrome"
      # "slack"
      "macvim" # nix macvim requires full xcode :(
      "vlc"
    ];
  };

  # auto-update nix itself(?)
  services.nix-daemon.enable = true;

  # put nix in rc file, I think?
  programs.bash.enable = true;
  programs.zsh.enable = true;

  # make fonts happen (i.e. copy them into a real place)
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    powerline-fonts
  ];

  system.defaults = {
    dock = {
      autohide = true;
      showhidden = true;
      mru-spaces = false;
      show-recents = false;
      launchanim = false;
    };

    finder = {
      AppleShowAllExtensions = true; 
      CreateDesktop = false;
      QuitMenuItem = true;
      _FXShowPosixPathInTitle = true;
    };

    NSGlobalDomain = {
      NSDisableAutomaticTermination = true;

      # Trackpad
      AppleEnableSwipeNavigateWithScrolls = false;

      # Keyboard
      ApplePressAndHoldEnabled = false; # Disable accent popups.
      InitialKeyRepeat = 25;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.keyboard.fnState" = true;

    };
  };

  system.activationScripts.extraActivation.text = ''
    # TODO: how to put these in system.defaults?
    # TODO: 24-hour time, at least, is not actually HUPping the clock, how?
    defaults write -g AppleICUForce24HourTime -bool YES;
    defaults write -g com.apple.sound.uiaudio.enabled -bool YES;
  '';
}
