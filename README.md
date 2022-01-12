# Environment Setup

## Homebrew
You will need to install `homebrew` first.
Follow the instructions [here](https://brew.sh).

## Ruby
Install `rbenv` to manage ruby versions.
```zsh
brew install `rbenv` ruby-build
# Install ruby version 3.0.0
rbenv install 3.0.0
```

## Bundler
Install bundler version 2.2.3
```zsh
gem install bundler -v 2.2.3
# confirm correct version is active
gem list bundler
bundle -v
```

## CocoaPods
Install CocoaPods through bundler
```zsh
bundle config set path vendor/bundle
bundle _2.2.3_ install
```

Install dependencies through CocoaPods
```zsh
bundle exec pod install
```
