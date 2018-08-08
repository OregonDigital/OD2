# Oregon Digital

[![CircleCI](https://circleci.com/gh/OregonDigital/OD2.svg?style=svg)](https://circleci.com/gh/OregonDigital/OD2)

Heading info.  Project info.  Stuff.  Things.

## Docker setup

    docker-compose up -d

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

## Local development

Use Docker!  To expose the app to localhost (so you can just visit
`http://localhost` instead of finding the app's IP address via crazy docker
inspect commands), do this:

    cp docker-compose.override.yml-example docker-compose.override.yml

You can also customize that file to expose ports for things like Solr or
Fedora, Redis, etc.
