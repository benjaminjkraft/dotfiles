{ config, pkgs, lib, ... }:

# TODO: organize me

# many thanks to slim, tons of cribbing from
# https://github.com/sliminality/nix-config/blob/main/darwin-configuration.nix

let yabai = pkgs.yabai.overrideAttrs (old: rec {
  src = builtins.fetchTarball {
    url = https://github.com/koekeishiya/yabai/files/7915231/yabai-v4.0.0.tar.gz;
    sha256 = "sha256:0rs6ibygqqzwsx4mfdx8h1dqmpkrsfig8hi37rdmlcx46i3hv74k";
  };
}); in
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
    pkgs.autojump
    pkgs.comby
    pkgs.coreutils
    pkgs.entr
    pkgs.expect      # unbuffer
    pkgs.fx
    pkgs.gh
    pkgs.git
    pkgs.gnugrep     # tfenv requires GNU grep and who can blame them
    pkgs.gnused      # BSD sed is terrible
    pkgs.htop
    pkgs.httpie
    pkgs.jq
    pkgs.lesspipe    # the "read a tar file in less" thing
    pkgs.moreutils
    pkgs.procps      # watch et al.
    pkgs.python310Packages.ipython
    pkgs.tmux
    pkgs.vim
    pkgs.xcode-install # note: doesn't seem to actually install xcode?
    pkgs.zstd

    # from notion setup but generally useful
    pkgs.awscli2
    pkgs.ssm-session-manager-plugin   # some related AWS thing
    pkgs.pandoc
    pkgs.ripgrep
  ];
  environment.pathsToLink = ["/etc/profile.d"]; # autojump puts its init here

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
      "bettertouchtool"
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

  services.yabai = {
    enable = true;
    package = yabai;

    # ugh can I just put this in .yabairc like a normal person?
    extraConfig = ''
      yabai -m config layout bsp
      yabai -m config split_ratio 0.64

      yabai -m config focus_follows_mouse autoraise
    '';
  };

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
