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

FROM base AS fonts

WORKDIR /tmp

# Prepare to install IPAex-fonts
ENV zip_basename=IPAexfont00201
RUN --mount=type=cache,id=src,target=/tmp/src \
  if [ ! -f src/${zip_basename}.zip ]; then \
   wget -q https://ipafont.ipa.go.jp/IPAexfont/${zip_basename}.zip && \
   mv ${zip_basename}.zip src/ ; \
  fi && \
  \
  unzip src/${zip_basename}.zip && \
  mv ${zip_basename} IPAexfont

FROM base

# Install packages
RUN --mount=type=cache,id=apk,target=/var/cache/apk \
   apk add  \
         mariadb-connector-c  \
         wkhtmltopdf

# Install fonts
COPY --from=fonts /tmp/IPAexfont/*.ttf /usr/share/fonts/TTF/
RUN fc-cache

# Take gemfiles
COPY --from=gemfiles /usr/local/bundle/ /usr/local/bundle/

WORKDIR /app

# Copy Application
COPY . ./
CMD ["ruby", "app.rb"]
