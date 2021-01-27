FROM ruby:3.0-alpine

WORKDIR /cs_managers

# installing and configuring nginx and all deps
RUN apk add --update-cache nginx build-base postgresql-dev && rm -rf /var/cache/apk/*
RUN gem install bundler

# copy nginx file
COPY _infra/nginx/default.conf /etc/nginx/conf.d/default.conf

# copy Gemfile for docker layering cache
COPY Gemfile* /cs_managers/

# installing gems
RUN bundle install --deployment

# copy the app into cs_managers
COPY . /cs_managers

# default command is to run backoffice
CMD bundle exec ruby boot.rb
