#!/bin/sh

echo
echo "Creating default admin set..."
bundle exec rails hyrax:default_admin_set:create

echo
echo "Converting default admin set to ActiveFedora..."
bundle exec rails runner '
admin_set = Hyrax.query_service.find_by(id: "admin_set/default")
Hyrax.persister.save(resource: admin_set)
'

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
bundle exec rake oregon_digital:create_admin_sets_and_collection_types
