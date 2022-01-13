# !/bin/sh

# Create file paths
SAMPLE_FILE_PATH=$(pwd)/scripts/CurrencyLayerSample.plist
GENERATED_FILE_PATH=$(pwd)/Generated/CurrencyLayerAPIKey.generated.plist

echo $SAMPLE_FILE_PATH
echo $GENERATED_FILE_PATH

# Take user input
echo "Enter the Currency Layer's API access_key: "
read api_key

# Copy sample file to new location
cp $SAMPLE_FILE_PATH $GENERATED_FILE_PATH

# Insert APIKEY to newly created plist file
plutil -replace access_key -string $api_key $GENERATED_FILE_PATH
