#!/bin/sh

echo Setting up Magento

echo Disabling xdebug for performance
echo '' > ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini

echo Creating configurator database
mysql -e 'CREATE DATABASE IF NOT EXISTS configurator;'

echo Install Magento
git clone https://github.com/magento/magento2
cd magento2

git checkout tags/$1 -b $1

composer require ctidigital/magento2-configurator dev-${TRAVIS_BRANCH}\#${TRAVIS_COMMIT}
composer install

php bin/magento setup:install --admin-email "test@test.com" --admin-firstname "CTI" --admin-lastname "Test" --admin-password "password123" --admin-user "admin" --backend-frontname admin --base-url "http://configurator.dev" --db-host 127.0.0.1 --db-name configurator --db-user root --session-save files --use-rewrites 1 --use-secure 0 -vvv

cd vendor/ctidigital/magento2-configurator/

echo Go to app etc folder
cd ../../../app/etc

echo Copy master.yaml folder
cp ../../../Samples/master.yaml master.yaml

pwd
ls -alh
cat master.yaml

cd ../..
php bin/magento cache:flush
php bin/magento module:status
cd ..

mv Samples/Components configurator