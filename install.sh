#!/bin/sh -l

set -o pipefail

EXTENSION_NAME=$1
TYPE=$2
USE_MYSQL=$3
EXTRA_INCLUDE_FILE=$4

if [ "$USE_MYSQL" = "true" ]; then
  DB_TYPE="mysql"
  DB_SERVER="127.0.0.1"
  # We need to start MySQL, but not sqlite
  sudo systemctl start mysql
else
  DB_TYPE="sqlite"
  DB_SERVER="localhost"
fi

# Install composer dependencies
cd mediawiki && composer install

# We can have --dbpass with 'root' for MySQL without breaking SQLite since
# the SQLite installer just clears that, it doesn't use a password
php maintenance/install.php \
  --dbtype $DB_TYPE \
  --dbpass 'root' \
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
else
    echo "wfLoadSkin( '$EXTENSION_NAME' );" >> LocalSettings.php
fi

# Allow extensions to add their own extra configuration
if [ -n "${EXTRA_INCLUDE_FILE}" ]; then
  # Path should be relative to the directory of the extension itself
  if [ "$TYPE" = "extension" ]; then
    INCLUDE_PREFIX="\$IP/extensions/$EXTENSION_NAME"
  else
    INCLUDE_PREFIX="\$IP/skins/$EXTENSION_NAME"
  fi

  INCLUDE_PATH="$INCLUDE_PREFIX/$EXTRA_INCLUDE_FILE"
  echo "require_once \"$INCLUDE_PATH\";" >> LocalSettings.php
fi

# Include everything from `extensions` and `skins` directories
# Plus extensions that were cloned before mediawiki was
cat <<EOT > composer.local.json
{
  "require": {},
  "extra": {
    "merge-plugin": {
      "merge-dev": true,
      "include": [
        "extensions/*/composer.json",
        "skins/*/composer.json",
        "../*/composer.json"
      ]
    }
  }
}
EOT

sed -i 's/"merge-dev": false/"merge-dev": true/' composer.json
