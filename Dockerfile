# syntax=docker/dockerfile:1.0-experimental

FROM ruby:2.6.1-alpine3.9 AS base

# Configure cached apk-file and get index
RUN --mount=type=cache,id=apk,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk update


FROM base AS gemfiles

# Install packages needed build
RUN --mount=type=cache,id=apk,target=/var/cache/apk  \
    apk add \
        build-base \
        mariadb-connector-c-dev

WORKDIR /app

# Install Gem
COPY Gemfile Gemfile.lock ./
RUN --mount=type=cache,id=gem,target=/usr/local/bundle/cache  \
    --mount=type=cache,id=bundle,target=/root/.bundle/cache   \
    bundle install

FROM base

# Install packages
RUN --mount=type=cache,id=apk,target=/var/cache/apk \
   apk add  \
         mariadb-connector-c  \
         wkhtmltopdf 

# Take gemfiles
COPY --from=gemfiles /usr/local/bundle/ /usr/local/bundle/

WORKDIR /app

# Copy Application
COPY . ./
CMD ["ruby", "app.rb"]
