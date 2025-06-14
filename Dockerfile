# Use Ruby 3.1.2 with Rails 7.0.0
FROM ruby:3.1.2

# Preload Logger for ActiveSupport
ENV RUBYOPT="-r logger"

# Install OS dependencies, Node.js 16.x, Bundler, Rails, Postgres client, and Chromium+
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
         build-essential libpq-dev curl gnupg wget postgresql-client \
          libnss3 libatk-bridge2.0-0 libatk1.0-0 libcups2 \
          libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 \
          libgbm1 libasound2 libpulse0 libgtk-3-0 fonts-liberation xdg-utils \
    # Node.js 16
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    # Chromium browser and driver for headless system tests
    && apt-get install -y chromium chromium-driver \
    # Ruby gems
    && gem install bundler -v 2.3.26 \
    && gem install rails -v 7.0.0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile(s) and install gems
COPY Gemfile* ./
RUN bundle install --jobs 4 --retry 3

# Copy JS/CSS config and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the Rails application
COPY . ./

# Entrypoint script: handle dev/test migrations and cleanup
RUN printf '#!/bin/bash\nset -e\n\n# Ensure correct DB env when running tests\nif [ "${RAILS_ENV}" = "test" ]; then\n  bundle exec rails db:environment:set RAILS_ENV=test\n  bundle exec rails db:create db:migrate\nelse\n  rm -f tmp/pids/server.pid\n  bundle exec rails db:create db:migrate\nfi\n\nexec "$@"\n' \
     > /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "4001"]