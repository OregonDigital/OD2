# Oregon Digital

[![CircleCI](https://circleci.com/gh/OregonDigital/OD2.svg?style=svg)](https://circleci.com/gh/OregonDigital/OD2)
[![Coverage Status](https://coveralls.io/repos/github/OregonDigital/OD2/badge.svg?branch=master)](https://coveralls.io/github/OregonDigital/OD2?branch=master)

# Docker Setup

## Requirements

The details provided assume that the official Docker daemon is running in the background. Download and install Docker Community Edition from https://www.docker.com/community-edition.

**Suggested:** If using ohmyzsh (http://ohmyz.sh/), add the docker-compose plugin to the .zshrc for better command-line aliases and integration.

**Important:** _By default, docker will run the services in the context of
`RAILS_ENV=development`_, and there is no valid AWS configuration.  You can
copy the included `.env.example` to `.env` and override these things if desired.

## Docker notes

- `$ docker system prune` : A command that will reclaim disk space by deleting stopped containers, networks, dangling images and build cache.
- `$ docker volume ls` : Show a list of named volumes which hold persistent data for containers.
- `$ docker volume rm [VOLUME NAME]` : Remove a named volume, to force the system to rebuild and start that services persistent data from scratch.

## Docker Compose basics

### Build the base application image

Build the app image *with your user id*, otherwise permissions will not work
for development!  1000 is *my* id, but may not be yours.

```bash
docker-compose build --build-arg UID=1000 --build-arg GID=1000 server workers app test dev
```

Rebuilding the image should (usually) not be necessary unless you're changing
the `Dockerfile` or suspect a bad cached build.

# Getting Started

**Important**: Setup a `docker-compose.override.yml` before starting development or testing.

    cp docker-compose.override.yml-example docker-compose.override.yml

# Development workflow

All of the required services are pre-configured with environment variables injected to the containers during boot. The database, repository, solr index, and redis queue are backed by persistent volumes to maintain data between use.

Start the development server:

    docker-compose up server
    (or, detached)
    docker-compose up -d server

_Open another terminal window (unless you run the previous command `detached`)._

Automatic setup
---

On the first time building and starting the server, Hyrax defaults must be created and loaded. Run the commands on the server container.

*"docker-compose exec" only works if the server is running.  The first-run
command only works if the server has already been initialized.  Make sure
migrations have finished running before you do these steps.*

```bash
docker-compose exec server ./build/firstrun.sh
```

This will take a few minutes.  Once it's done, you can visit
`http://localhost:3000/users/sign_in?locale=en` and log in as
"admin@example.org" with the password "admin123".

Manual
---

Or to run the commands manually:

    docker-compose run --entrypoint=bash server
    # ... wait for a shell session to start ...
    bundle exec rails hyrax:default_admin_set:create
    bundle exec rails hyrax:default_collection_types:create
    bundle exec rails hyrax:workflow:load

Visit http://localhost:3000/users/sign_up?locale=en to register an account.

Return to the server container shell session, start Rails console, create an `admin` role, and assign it to the user that was just created.

    bundle exec rails c
    # ... wait for the Rails console to start ...
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
