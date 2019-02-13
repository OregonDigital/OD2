#!/bin/sh

bundle exec rails hyrax:default_admin_set:create
bundle exec rails hyrax:default_collection_types:create
bundle exec rails hyrax:workflow:load
bundle exec rails runner 'Role.create(name: "admin")'
bundle exec rails runner 'User.create(email: "admin@example.org", encrypted_password: "$2a$11$AzzYy9sCWJh6JCKu0qjvdeiSDp0e6DS2rdTOtDEHV2UZw/cQ0ltnG", preferred_locale: "en")'
bundle exec rails runner 'User.last.roles << Role.last'
