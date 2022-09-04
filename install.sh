#!/bin/sh -l

set -o pipefail

MW_BRANCH=$1
EXTENSION_NAME=$2
TYPE=$3

# Download wiki release
wget https://github.com/wikimedia/mediawiki/archive/$MW_BRANCH.tar.gz -nv -q

# Extract into `mediawiki` directory
tar -zxf $MW_BRANCH.tar.gz
mv mediawiki-$MW_BRANCH mediawiki

# Install composer dependencies
cd mediawiki && composer install
php maintenance/install.php \
  --dbtype sqlite \
  --dbuser root \
  --dbname mw \
  --dbpath $(pwd) \
  --confpath $(pwd) \
  --pass DummyAdminPassword DummyWikiName DummyAdminUser

# https://www.mediawiki.org/wiki/Manual:$wgShowExceptionDetails
echo '$wgShowExceptionDetails = true;' >> LocalSettings.php
# https://www.mediawiki.org/wiki/Manual:$wgShowDBErrorBacktrace , note this is deprecated in 1.37+
echo '$wgShowDBErrorBacktrace = true;' >> LocalSettings.php
# https://www.mediawiki.org/wiki/Manual:$wgDevelopmentWarnings
echo '$wgDevelopmentWarnings = true;' >> LocalSettings.php

echo "\$wgServer = 'http://localhost';" >> LocalSettings.php

# Loads extension or skin depending on type option provided
if [ "$TYPE" = "extension" ]; then
    echo "wfLoadExtension( '$EXTENSION_NAME' );" >> LocalSettings.php
    echo "{\"require\": {},\"extra\": {\"merge-plugin\": {\"merge-dev\": true,\"include\": [\"extensions/$EXTENSION_NAME/composer.json\"]}}}" >> composer.local.json
else
    echo "wfLoadSkin( '$EXTENSION_NAME' );" >> LocalSettings.php
    echo "{\"require\": {},\"extra\": {\"merge-plugin\": {\"merge-dev\": true,\"include\": [\"skins/$EXTENSION_NAME/composer.json\"]}}}" >> composer.local.json
fi

echo "========================================================"
cat composer.local.json
echo "========================================================"
cat LocalSettings.php
echo "========================================================"

sleep 10

# Include everything from `extensions` and `skins` directories
#cat <<EOT > composer.local.json
#{
#  "require": {},
#  "extra": {
#    "merge-plugin": {
#      "merge-dev": true,
#      "include": [
#        "extensions/**/composer.json",
#        "skins/**/composer.json"
#      ]
#    }
#  }
#}
#EOT
