# Tabs vs Spaces
We're using Tabs instead of spaces in this repository.
It's better for accessibility & easier to adjust for each user's preference.

* To change your GitHub tab-size rendering preference, follow the instructions [here](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-user-account/managing-user-account-settings/managing-your-tab-size-rendering-preference).

* To edit your tab-size rendering preference in Xcode follow these instructions:
    1. Open preferences and navigate to Indentation.
Xcode > Preference > Text Editing > Indentation
    2. Change Tab Width to your liking.

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

> 📝 **Note**
>
> Make sure to set the development team in the project settings if you plan on running the app on an actual device.

# Acknowledgements
* Using the flag assets found [here](https://github.com/transferwise/currency-flags) to make the currencies a bit more glanceable.
* The app icon is from [icons8.com](https://icons8.com/icons/set/currency-exchange).

# A Preview of the App
https://user-images.githubusercontent.com/6136903/149676731-557e90d4-d63c-404a-82c3-aa92a9e94ad2.mov


