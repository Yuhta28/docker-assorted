FROM ruby:2.6.1-stretch

# Install packages
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    fonts-ipaexfont \
    libssl1.0-dev
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Gem
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy Application
COPY . ./
CMD ["ruby", "app.rb"]
