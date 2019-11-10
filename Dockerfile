FROM ruby:2.6.1-slim-stretch

# Install packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-ipaexfont \
        libmariadbclient18 \
        libssl1.0-dev  \
        && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Gem
COPY Gemfile Gemfile.lock ./
RUN build_deps=" \
         default-libmysqlclient-dev \
         gcc \
         make \
    " && \
    apt-get update && \
    apt-get install -y --no-install-recommends $build_deps && \
    bundle install && \
    rm -rf \
        $(gem contents wkhtmltopdf-binary | grep -E '_debian_$' ) \
        ~/.bundle/cache \
        "${GEM_HOME}/cache" \
        && \
    apt-get remove -y --purge --autoremove $build_deps && \
    rm -rf /var/lib/apt/lists/*

# Copy Application
COPY . ./
CMD ["ruby", "app.rb"]
