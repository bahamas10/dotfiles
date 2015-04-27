#!/usr/bin/env bash
#
# install all files to ~ by symlinking them,
# this way, updating them is as simple as git pull

defaults() {
	echo defaults "$@"
	command defaults "$@"
}

symlink() {
	printf '%40s -> %s\n' "${1/#$HOME/~}" "${2/#$HOME/~}"
	ln -sf "$@"
}

git submodule init
git submodule update

# Link dotfiles
for f in bash_completion bash_profile bashrc gitconfig htoprc jshintrc screenrc tmux.conf vimrc vim; do
	[[ -d ~/.$f ]] && rm -r ~/."$f"
	symlink "$PWD/$f" ~/."$f"
done

# Setup bics
if [[ ! -d ~/.bics ]]; then
	bash <(curl -sSL https://raw.githubusercontent.com/bahamas10/bics/master/bics) init
	rm -r ~/.bics/plugins
	symlink "$PWD/bics-plugins" ~/.bics/plugins
fi

# Keyboard shortcuts for Mac OS X
if [[ -d ~/Library ]]; then
	mkdir -p ~/Library/KeyBindings
	symlink "$PWD/DefaultKeyBinding.dict" ~/Library/KeyBindings/DefaultKeyBinding.dict
fi

# Mac OS X NSUserDefaults modifications
# Some based on https://github.com/mathiasbynens/dotfiles/blob/master/.osx
if defaults read com.apple.finder &>/dev/null; then
	### Global

	# Set a shorter Delay until key repeat
	defaults write -g InitialKeyRepeat -int 15

	# Set a fast keyboard repeat rate
	defaults write -g KeyRepeat -int 2

	# Reenable key repeat for pressing and holding keys
	defaults write -g ApplePressAndHoldEnabled -bool false

	# Disable all window animations
	defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

	# Show all extenions
	defaults write -g AppleShowAllExtensions -bool true

	# Minimize on double click
	defaults write -g AppleMiniaturizeOnDoubleClick -bool true

	# Expand save panel by default
	defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
	defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

	# Expand print panel by default
	defaults write -g PMPrintingExpandedStateForPrint -bool true
	defaults write -g PMPrintingExpandedStateForPrint2 -bool true

	# Save to disk (not to iCloud) by default
	defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false

	# Disable smart quotes as they’re annoying when typing code
	defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

	# Disable smart dashes as they’re annoying when typing code
	defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

	# Show ~/Library in finder
	chflags nohidden ~/Library

	# Disable elastic scroll
	#defaults write -g NSScrollViewRubberbanding -int 0
	# XXX it makes going back weird, enable it for now i guess ugh

	# Trackpad: enable tap to click for this user and for the login screen
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
	defaults write -g com.apple.mouse.tapBehavior -int 1

	# Trackpad: map bottom right corner to right-click
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
	defaults -currentHost write -g com.apple.trackpad.trackpadCornerClickBehavior -int 1
	defaults -currentHost write -g com.apple.trackpad.enableSecondaryClick -bool true

	# Enable full keyboard access for all controls
	# (e.g. enable Tab in modal dialogs)
	defaults write -g AppleKeyboardUIMode -int 3

	# Use scroll gesture with the Ctrl (^) modifier key to zoom
	defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
	defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
	# Follow the keyboard focus while zoomed in
	defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

	# Disable "natural" (Lion-style) scrolling
	#defaults write -g com.apple.swipescrolldirection -bool false

	### Print

	# Automatically quit printer app once the print jobs complete
	defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true

	### LaunchServices

	# Disable the "Are you sure you want to open this application?" dialog
	defaults write com.apple.LaunchServices LSQuarantine -bool false

	### Finder

	# Full POSIX path in finder windows
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

	# Show Status bar in Finder
	defaults write com.apple.finder ShowStatusBar -bool true

	# Show icons for hard drives, servers, and removable media on the desktop
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
	defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
	defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

	### Dashboard

	# Disable dashboard
	defaults write com.apple.dashboard mcx-disabled -bool true

	### Dock

	# Disable the ugly mavericks dock appearance
	defaults write com.apple.dock hide-mirror -bool true

	# Don't automatically rearrange Spaces based on most recent use
	defaults write com.apple.dock mru-spaces -bool false

	# Automatically hide and show the Dock
	defaults write com.apple.dock autohide -bool true

	# Dock on the left
	defaults write com.apple.dock orientation -string left

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
	# Top left / Top Right screen corner → Mission Control
	defaults write com.apple.dock wvous-tl-corner -int 2
	defaults write com.apple.dock wvous-tl-modifier -int 0
	defaults write com.apple.dock wvous-tr-corner -int 2
	defaults write com.apple.dock wvous-tr-modifier -int 0
	# Bottom right screen corner → Start screen saver
	defaults write com.apple.dock wvous-br-corner -int 5
	defaults write com.apple.dock wvous-br-modifier -int 0
	# Bottom left screen corner → Show Desktop
	defaults write com.apple.dock wvous-bl-corner -int 4
	defaults write com.apple.dock wvous-bl-modifier -int 0

	### Spotlight

	# Don't index mounted volumes
	sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array /Volumes

	# Disable autosave for Preview
	defaults write com.apple.Preview ApplePersistence -bool no

	# Fix weird copy+paste with apple terminal
	defaults write com.apple.Terminal CopyAttributesProfile com.apple.Terminal.no-attributes

	killall Dock Finder
fi
