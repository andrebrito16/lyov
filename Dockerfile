FROM elixir:1.13.1

ENV MIX_ENV prod
ENV SECRET_KEY_BASE="SOME_SECRET_KEY_BASE"

COPY mix.* ./

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix do deps.get --only prod
RUN mix deps.compile
RUN mix phx.gen.secret

COPY . ./

# App Port
EXPOSE 4000

# Default Command
CMD ["mix", "phx.server"]