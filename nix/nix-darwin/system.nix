# macOS system configuration
# Declarative macOS system preferences

{ pkgs, ... }:

{
  # System defaults
  system.defaults = {
    # Dock settings
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.4;
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
      # Hot corners
      # Possible values:
      #  0: no-op
      #  2: Mission Control
      #  3: Show application windows
      #  4: Desktop
      #  5: Start screen saver
      #  6: Disable screen saver
      #  7: Dashboard
      # 10: Put display to sleep
      # 11: Launchpad
      # 12: Notification Center
      # 13: Lock Screen
      wvous-tl-corner = 2;  # Top left: Mission Control
      wvous-tr-corner = 4;  # Top right: Desktop
      wvous-bl-corner = 11; # Bottom left: Launchpad
      wvous-br-corner = 13; # Bottom right: Lock Screen
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf"; # Search current folder
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv"; # List view
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    # Global settings
    NSGlobalDomain = {
      # Keyboard
      AppleKeyboardUIMode = 3; # Full keyboard access
      ApplePressAndHoldEnabled = false; # Key repeat
      InitialKeyRepeat = 15;
      KeyRepeat = 2;

      # Mouse & Trackpad
      AppleShowScrollBars = "WhenScrolling";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # Interface
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    # Trackpad
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # Login window
    loginwindow = {
      GuestEnabled = false;
    };

    # Screencapture
    screencapture = {
      location = "~/Screenshots";
      type = "png";
      disable-shadow = true;
    };
  };

  # Keyboard remapping (optional)
  # system.keyboard = {
  #   enableKeyMapping = true;
  #   remapCapsLockToControl = true;
  # };
}
