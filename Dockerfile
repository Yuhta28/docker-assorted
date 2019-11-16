
FROM ruby:2.6.1-alpine3.9 AS gemfiles

# Install packages needed build
RUN apk add --no-cache \
        build-base \
        mariadb-connector-c-dev

WORKDIR /app

# Install Gem
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf "${GEM_HOME}/cache"

FROM ruby:2.6.1-alpine3.9

# Install packages
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpline/edge/testing/ \
        mariadb-connector-c
RUN apk add --no-cache \
        wkhtmltopdf

# Install Japanese font(IPAex-font)
RUN apk add --no-cache --repository http:dl-cdn.alpinelinux.org/alpline/edge/testing/font-ipa

# Take gemfiles
COPY --from=gemfiles /usr/local/bundle/ /usr/local/bundle/

WORKDIR /app

# Copy Application
COPY . ./
CMD ["ruby", "app.rb"]
