FROM ruby:2.6.1-stretch AS gemfiles

WORKDIR /app

# Install Gem
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
rm -rf \
    $(gem contents wkhtmltopdf-binary | grep -E '_debian_$' ) \
    "${GEM_HOME}/cache"

FROM ruby:2.6.1-slim-stretch

# Install packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-ipaexfont \
        libmariadbclient18 \
        libssl1.0-dev  \
        && \
    rm -rf /var/lib/apt/lists/*

# Take gemfiles
COPY --from=gemfiles /usr/local/bundle/ /usr/local/bundle/

WORKDIR /app

# Copy Application
COPY . ./
CMD ["ruby", "app.rb"]
