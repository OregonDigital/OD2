# Oregon Digital

[![CircleCI](https://circleci.com/gh/OregonDigital/OD2.svg?style=svg)](https://circleci.com/gh/OregonDigital/OD2)
[![Coverage Status](https://coveralls.io/repos/github/OregonDigital/OD2/badge.svg?branch=master)](https://coveralls.io/github/OregonDigital/OD2?branch=master)

# Development workflow

All of the required services are pre-configured with environment variables injected to the containers during boot. The database, repository, solr index, and redis queue are backed by persistent volumes to maintain data between use.

Start the development server:

    docker-compose up server
    (or, detached)
    docker-compose up -d server

_Open another terminal window (unless you run the previous command `detached`)._

On the first time building and starting the server, Hyrax defaults must be created and loaded. Run the commands on the server container.

    docker-compose run server bash
    ... wait for a shell session to start ...
    bundle exec rails hyrax:default_admin_set:create
    bundle exec rails hyrax:default_collection_types:create
    bundle exec rails hyrax:workflow:load

Visit http://localhost:3000/users/sign_up?locale=en to register an account.

Return to the server container shell session, start Rails console, create an `admin` role, and assign it to the user that was just created.

    bundle exec rails c
    ... wait for the Rails console to start ...
    Role.create(name: 'admin')
    User.last.roles << Role.last

Login to the app, and continue configuration or depositing works using the Hyrax UI.

# Testing workflow

Testing the application amounts to running all of the required services along side an instance of the application and then running the testing framework against those containers. All of the `*-test` services have applicable environment variables injected to the containers during boot.

Start the test server:

    docker-compose up test
    (or, detached)
    docker-compose up -d test

_Open another terminal window (unless you run the previous command `detached`)_

Start a session, and run `rspec` on the test (application) container. _(This method offers a more developer/TDD friendly experience)_

    docker-compose run test bash
    root@8675309jenny:/data# bundle exec rspec

**OR** run `rspec` on the test (application) container directly:

    docker-compose run test rspec

# Additional Notes

## Controlling Workers

Running rake tasks:

    docker-compose exec workers rake -T

When you do anything that changes the filesystem (rake tasks or otherwise), you
may want to pass through your user ID so that on your local filesystem you
still own the files:

    docker-compose exec -u 1000 workers rake -T

(Your user id may or may not be 1000 - use `id -g` or similar to find your
actual user id)

It may behoove you to create an alias for this kind of thing:

    alias dwork='docker-compose exec -u 1000 workers'
    dwork rake -T
    dwork rails generate ...
