# Ephemeral Chat

[![Deploy](https://github.com/happyRip/Ephemeral-Chat/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/happyRip/Ephemeral-Chat/actions/workflows/deploy.yml)
[![Website Active](https://github.com/happyRip/Ephemeral-Chat/actions/workflows/status.yml/badge.svg)](https://github.com/happyRip/Ephemeral-Chat/actions/workflows/status.yml)

Real time chat application created with Phoenix framework and deployed on fly.io

## Development

The project's development environment relies on [`Docker`](https://www.docker.com/) and [`docker compose`](https://github.com/docker/compose). To install them please head over to please head over to respective installation guides:
* [`Docker`](https://docs.docker.com/engine/install/)
* [`docker compose`](https://github.com/docker/compose#where-to-get-docker-compose)

When the dependency requirements are met you need to clone the project to your workstation. Notice that neither `Elixir` nor `postgresql` need to be installed on your machine. The whole app is going to be working in a contenerized environment.

```
git clone https://github.com/happyRip/Ephemeral-Chat.git
cd Ephemeral-Chat
```

Then build the containers and setup the project next

```
docker compose build
docker compose run --rm web mix setup
```

All that's left is to run the app

```
docker compose up
```

Now head over to http://localhost:4000/ and check if the app is working correctly.

You can setup an alias to run `mix` commands through the docker container

```
alias mix='docker compose run --rm web mix'
```

If you encounter any problems please [create an issue](https://github.com/happyRip/Ephemeral-Chat/issues/new/choose).

