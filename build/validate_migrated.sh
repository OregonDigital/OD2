#!/bin/sh

if bundle exec rails db:migrate:status &> /dev/null; then
  bundle exec rails db:migrate
else
  bundle exec rails db:setup
fi
