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
    # chsh -s "${lib.getBin pkgs.bash}/bin/bash" "${config.users.users.benkraft.name}"
    # except that borks something with terminfo. Use system bash for now.
    # TODO: figure out what's up with nix bash.
    chsh -s "/bin/bash" "${config.users.users.benkraft.name}"

    # Allow npm install -g, as a concession to reality
    # (have to sudo to me to avoid permission errors later)
    # XXX: but this doesn't make sense here anymore probably?
    sudo -u ${config.users.users.benkraft.name} mkdir -p "${config.users.users.benkraft.home}/.local"
    # TODO: this is somehow trying to access .Trash which it doesn't have
    # permission to. No idea why; ran it manually for now.
    # npm set prefix "${config.users.users.benkraft.home}/.local"
  '';

  networking.computerName = "homotopy";
  networking.hostName = "homotopy";

  nixpkgs.config.allowUnfree = true;

  # installed for all users
  environment.systemPackages = [
    pkgs.coreutils
    pkgs.gh
    pkgs.gnused      # BSD sed is terrible
    pkgs.htop
    pkgs.lesspipe    # the "read a tar file in less" thing
    pkgs.jq
    pkgs.tmux
    pkgs.vim
    pkgs.xcode-install # note: doesn't seem to actually install xcode?

    # from notion setup but generally useful
    pkgs.awscli2
    pkgs.ssm-session-manager-plugin   # some related AWS thing
    pkgs.pandoc
    pkgs.ripgrep
  ];
  # Needed so that the node package libpq can find the libpq headers (installed
  # by postgresql_13). Might not be needed if I set things up in the proper
  # build env?
  # environment.pathsToLink = ["/include"];

  # the one, the only, love it, hate it...
  homebrew = {
    enable = true;
    # TODO once I have all the notion stuff in here:
    # cleanup = "zap";
    taps = [
      "homebrew/cask"
    ];
    casks = [
      "alacritty"         # nix alacritty doesn't play nice with the dock :(
      "docker"            # TODO: how to get nix docker to start its daemon?
      "firefox"
      # installed by kandji:
      # "google-chrome"
      # "slack"
      "macvim"            # nix macvim requires full xcode :(
      "openvpn-connect"   # nix version doesn't have GUI?
      "stats"
      "vlc"
    ];
  };

  # auto-update nix itself(?)
  services.nix-daemon.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command
  '';

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
      "com.apple.trackpad.scaling" = 2.5;
      "com.apple.sound.beep.volume" = 0.0;
    };
  };

  system.activationScripts.extraActivation.text = ''
    # TODO: how to put these in system.defaults?
    # TODO: 24-hour time, at least, is not actually HUPping the clock, how?
    defaults write -g AppleICUForce24HourTime -bool YES;
    defaults write -g com.apple.sound.uiaudio.enabled -bool YES;
  '';
}
