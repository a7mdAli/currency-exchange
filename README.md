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
# confirm the correct version is active
gem list bundler
bundle -v
# set bundle's path
bundle config set path vendor/bundle
```

## Install gem dependencies (e.g. CocoaPods)
Install gem dependencies through bundler
```zsh
bundle _2.2.3_ install
```

Install dependencies through CocoaPods
```zsh
bundle exec pod install
```

# Project Setup
We use [currencylayer](https://currencylayer.com/documentation)'s API to fetch currency conversion rates.
Therefore, we need an API access key to interact with their APIs.

If you don't already have an account, make one [here](https://currencylayer.com/product).

After you've received your API access key, run the next command from the terminal (from the project's root directory)
```sh
./scripts/create-currencylayer-api-key-plist.sh
# This will ask you for the API access_key
# paste the API access key you've received upon registration with currencylayer.
```
