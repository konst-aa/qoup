# syntax=docker/dockerfile:1
   
FROM elixir:latest
WORKDIR /app
COPY . .
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
CMD ["mix", "run", "--no-halt"]
