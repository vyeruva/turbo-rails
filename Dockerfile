# Use Ruby 3.1.2 with Rails 7.0.0
FROM ruby:3.1.2

# Ensure std-lib Logger is preloaded for ActiveSupport
ENV RUBYOPT="-r logger"

# Install OS dependencies, Bundler, Rails, Node, and Postgres client
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
         build-essential libpq-dev nodejs npm postgresql-client \
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

# Create entrypoint script outside of /app (so it's not masked by volume mount)
RUN printf '#!/bin/bash\nset -e\nrm -f /app/tmp/pids/server.pid\nbundle exec rails db:create db:migrate\nexec "$@"\n' \
       > /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# Entrypoint and default command
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "4001"]