# Mediawiki Extension PHPUnit Runner

The action is a [composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
that uses the following actions to install an ephemeral MediaWiki instance with Composer and PHP on board and run
PHPUnit tests for your extension repo:

* [shivammathur/setup-php](https://github.com/shivammathur/setup-php)
* [actions/cache](https://github.com/actions/cache)
* [actions/checkout](https://github.com/actions/checkout)

# Usage

```yaml
- uses: actions/mediawiki-phpunit@v1
  with:
    php: 7.4
    mwbranch: REL1_35
    extension: DummyExtension
    testgroup: extension-DummyExtension
```

# Inputs

* `php` - version of PHP to install
* `mwbranch` - MediaWiki branch to install
* `extension` - extension name to test (this should match the desired extension directory)
* `testgroup` - @group of tests to run (this should match your extension group defined on unit tests)

# Example

The below is an example of how to setup your GitHub Actions workflow on extension repository:

`.github/workflows/main.yml`

```yaml
name: Example

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ "*" ]

jobs:
  test:
    name: "PHPUnit: MW ${{ matrix.mw }}, PHP ${{ matrix.php }}"
    strategy:
      matrix:
        include:
          - mw: 'REL1_35'
            php: 7.4
          - mw: 'REL1_36'
            php: 7.4
          - mw: 'REL1_37'
            php: 7.4
          - mw: 'master'
            php: 7.4
    runs-on: ubuntu-latest
    steps:
      # check out the extension repository
      - name: Checkout
        uses: actions/checkout@v3
      # run the action to install MediaWiki, PHP, Composer
      # and run PHPUnit tests for the extension
      - name: Mediawiki PHPUnit
        uses: actions/mediawiki-phpunit@v1
        with:
          php: ${{ matrix.php }}
          mwbranch: ${{ matrix.mw }}
          extension: MyExtension
          testgroup: extension-MyExtension
```

Example of adding a group to your extension tests:

`MyExtension/tests/phpunit/MyExtensionTest.php`

```php
/**
 * @group extension-MyExtension
 */
class MyExtensionTest extends MediaWikiTestCase {
    // ...
}
```
