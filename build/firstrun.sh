#!/bin/sh

echo
echo 'Checking firstrun status'
count=$( bundle exec rails runner 'puts "ADMINSETCOUNT#{AdminSet.count}"' )
delimiter=ADMINSETCOUNT
realcount=${count#*$delimiter}
if [ $realcount -gt 0 ]
then
  echo
  echo "$realcount AdminSet exist, assuming firstrun is complete. Exiting"
  exit 0
fi

echo
echo 'Executing firstrun'

echo
echo "Creating default admin set..."
bundle exec rails hyrax:default_admin_set:create

echo
echo "Creating default collection types..."
bundle exec rails hyrax:default_collection_types:create

echo
echo "Loading workflow stuff..."
bundle exec rails hyrax:workflow:load

echo
echo "Creating a default admin user"
bundle exec rails runner 'User.create(
  email: "admin@example.org",
  encrypted_password: "$2a$11$AzzYy9sCWJh6JCKu0qjvdeiSDp0e6DS2rdTOtDEHV2UZw/cQ0ltnG",
  preferred_locale: "en",
  roles: [Role.find_by_name("admin")],
  confirmed_at: Time.now
)'

echo
echo "Creating Oregon Digital admin sets"
bundle exec rake oregon_digital:create_admin_sets
