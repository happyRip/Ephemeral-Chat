FROM elixir:latest

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    # apt-get install -y nodejs && \
    # curl -L https://npmjs.org/install.sh | sh && \
    mix local.hex --force && \
    mix archive.install hex phx_new --force && \
    mix local.rebar --force

WORKDIR /app

CMD ["mix", "phx.server"]
