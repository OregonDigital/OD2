# Oregon Digital

Heading info.  Project info.  Stuff.  Things.

## Docker Stack setup

Docker Stack has some nice built in rake tasks for managing the containers and infrastructure launched, such as resetting the containers, starting, stopping, etc.

Install Docker, Docker-Machine and get it running.. this a CLI for docker running VirtualBox

    brew install docker
    brew install docker-machine
    brew install docker-compose
    docker-machine create default
    docker-machine start default
    eval "$(docker-machine env)"
    # maybe add the eval line to your .zshrc!
    echo $DOCKER_HOST
    # make note of the ip address, likely 192.168.99.100

Launch the docker services configured in `.docker-stack/od2-development/docker-compose.yml`

    bundle exec docker:dev:up

Run the Rails app, if it's not configured as part of the docker-compose already. Export the SOLR_URL and FEDORA_URL if you prefer it that way.

    SOLR_URL=http://192.168.99.100:8983 FEDORA_URL=http://192.168.99.100:8984 bundle exec rails s


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
