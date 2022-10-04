{ config, pkgs, ... }:

{
  # unclear if this does anything, actually
  users.users.benkraft = {
    name = "benkraft";
    home = "/Users/benkraft";
    shell = pkgs.bashInteractive;
  };

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

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
